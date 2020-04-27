---
title: Respecting EXIF metadata in Orchard images
tags:
- Orchard
- ImageResizer
date: 2017-02-22
---
I bought my first camera recently and have been snapping [many][1] [awful][2] [snaps][3] as I bumble around the world. Now, when you take a photo in portrait mode, the camera doesn't do any expensive rotating or anything, it just adds a little tag in to say that this photo should be displayed like this. Naturally that is a pretty dumbed down version of the EXIF metadata but that's the gist of it. So when you open the photo in your photo viewer on the laptop, bam, it looks great. Upload to Orchard? Damn all my photos are sideways. I had no clue what was going on at first but after reading a blog post about what an EXIF tag is, deeming myself an expert, I set about fixing it.

Orchard has the Media Processing module, and it is awesome. I made two implementations, one adds a new a filter that will rotate an image based on the EXIF tag and one that modifies the existing resize filter to rotate the image as it is resized (I figured one pass would be more efficient and good enough for most cases). So how is the actual rotation done? Turned out to be super easy, it is all inbuilt into [ImageResizer.NET][4], a superb library that Orchard already uses for image resizing. I had a moment of confusion when I got the version of ImageResizer that was being used totally wrong and hence couldn't work out why my code wasn't working, but after cursing my stupidity and adding a line of code (autorotate comes with ImageResizer v3 but you need to manually load it in, v4 has it included by default) it worked perfectly. 

So the first implementation overrides how the default ResizeFilter applies it's filter by simply adding the autorotate option. Here is the full class.

    using System;
    using System.Drawing;
    using System.IO;
    using ImageResizer;
    using ImageResizer.Configuration;
    using ImageResizer.Plugins.Basic;
    using Orchard.Environment.Extensions;
    using Orchard.Localization;
    using Orchard.MediaProcessing.Descriptors.Filter;
    using Orchard.MediaProcessing.Services;
    
    namespace Mod.OddJobules.Providers.Filters {
        [OrchardSuppressDependency("Orchard.MediaProcessing.Providers.Filters.ResizeFilter"), OrchardFeature("Mod.OddJobules.AutorotateResizeFilter")]
        public class ResizeFilter : IImageFilterProvider {
            public ResizeFilter() {
                T = NullLocalizer.Instance;
            }
    
            public Localizer T { get; set; }
    
            public void Describe(DescribeFilterContext describe) {
                describe.For("Transform", T("Transform"), T("Transform"))
                    .Element("Resize", T("Resize"), T("Resizes using predefined height or width."),
                             ApplyFilter,
                             DisplayFilter,
                             "ResizeFilter"
                    );
            }
    
            public void ApplyFilter(FilterContext context) {
                new AutoRotate().Install(Config.Current);
    
                int witdh = context.State.Width;
                int height = context.State.Height;
                string mode = context.State.Mode;
                string alignment = context.State.Alignment;
                string padcolor = context.State.PadColor;
    
                var settings = new ResizeSettings {
                    Mode = FitMode.Max,
                    Height = height,
                    Width = witdh
                };
    
                switch (mode) {
                    case "max": settings.Mode = FitMode.Max; break;
                    case "pad": 
                        settings.Mode = FitMode.Pad; 
                        settings.Scale = ScaleMode.Both; 
                        break;
                    case "crop": settings.Mode = FitMode.Crop; break;
                    case "stretch": settings.Mode = FitMode.Stretch; break;
                }
    
                switch (alignment) {
                    case "topleft": settings.Anchor = ContentAlignment.TopLeft; break;
                    case "topcenter": settings.Anchor = ContentAlignment.TopCenter; break;
                    case "topright": settings.Anchor = ContentAlignment.TopRight; break;
                    case "middleleft": settings.Anchor = ContentAlignment.MiddleLeft; break;
                    case "middlecenter": settings.Anchor = ContentAlignment.MiddleCenter; break;
                    case "middleright": settings.Anchor = ContentAlignment.MiddleRight; break;
                    case "bottomleft": settings.Anchor = ContentAlignment.BottomLeft; break;
                    case "bottomcenter": settings.Anchor = ContentAlignment.BottomCenter; break;
                    case "bottomright": settings.Anchor = ContentAlignment.BottomRight; break;
                }
    
                if (!String.IsNullOrWhiteSpace(padcolor)) {
                    if (padcolor.StartsWith("#")) {
                        settings.BackgroundColor = ColorTranslator.FromHtml(padcolor);
                    }
                    else {
                        settings.BackgroundColor = Color.FromName(padcolor);
                    }
                }
    
                settings.Add("autorotate", "true");
    
                var result = new MemoryStream();
                if (context.Media.CanSeek) {
                    context.Media.Seek(0, SeekOrigin.Begin);
                }
                ImageBuilder.Current.Build(context.Media, result, settings, true);
                context.Media = result;
            }
    
            public LocalizedString DisplayFilter(FilterContext context) {
                string mode = context.State.Mode;
    
                switch (mode) {
                    case "pad": return T("Pad to {0}x{1}", context.State.Height, context.State.Width);
                    case "crop": return T("Crop to {0}x{1}", context.State.Height, context.State.Width);
                    case "stretch": return T("Stretch to {0}x{1}", context.State.Height, context.State.Width);
                    default: return T("Resize to {0}x{1}", context.State.Height, context.State.Width); 
    
                } 
            }
        }
    }

And this class will add a new filter called autorotate that can be added independently of the resize filter. Beware that when resizing, it will strip all metadata from the image so trying to autorotate after resizing wont work. I'm not really sure how useful this is by itself but hey, you never know. 

    using Orchard.MediaProcessing.Descriptors.Filter;
    using Orchard.MediaProcessing.Services;
    using ImageResizer;
    using ImageResizer.Plugins.Basic;
    using System.IO;
    using Orchard.Localization;
    using Orchard.Environment.Extensions;
    using ImageResizer.Configuration;
    
    namespace Mod.OddJobules.Providers.Filters {
        [OrchardFeature("Mod.OddJobules.MediaProcessingExtensions")]
        public class AutoRotateFilter : IImageFilterProvider {
            public AutoRotateFilter() {
                T = NullLocalizer.Instance;
            }
    
            public Localizer T { get; set; }
            public void Describe(DescribeFilterContext describe) {
                describe.For("Transform", T("Transform"), T("Transform"))
                    .Element("Rotate", T("Rotate"), T("Rotates an image based on EXIF metadata tags"),
                             ApplyFilter,
                             DisplayFilter
                    );
            }
    
            public void ApplyFilter(FilterContext context) {
                new AutoRotate().Install(Config.Current);
    
                var result = new MemoryStream();
                if (context.Media.CanSeek) {
                    context.Media.Seek(0, SeekOrigin.Begin);
                }
                var settings = new ResizeSettings {
                    MaxHeight = 3200,
                    MaxWidth = 3200
                };
    
                settings.Add("autorotate", "true");
                
                ImageBuilder.Current.Build(context.Media, result, settings, true);
                context.Media = result;
            }
    
            public LocalizedString DisplayFilter(FilterContext context) {
                return T("Rotate the image based on EXIF metadata");
            }
        }
    }


  [1]: http://travellingwrong.com/elephant-nature-park-chiang-mai
  [2]: http://travellingwrong.com/intrepid-explorers-of-the-full-moon-party
  [3]: http://travellingwrong.com/pantip-market-koh-pha-ngan
  [4]: https://imageresizing.net/