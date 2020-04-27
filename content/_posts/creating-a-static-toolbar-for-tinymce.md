---
title: Creating a static toolbar for TinyMCE
tags:
- Orchard
- TinyMce
date: 2017-02-22
---
Ever tried to edit a post that has more lines than your text area in TinyMCE? Scroll down and poof the toolbar is lost. You cant do anything! It is terrible. Here is a simple extension for Orchard to make the toolbar static (the JavaScript should work fine on any old TinyMCE installation).

The script:

    $(function ($, tinymce) {
        function myTimeoutFunction()
        {
            if ($('.mce-toolbar-grp')) {
                clearInterval(timerId);
                var selector = $('.mce-toolbar-grp');
                var bottom = $(".mce-statusbar");
                var toolbarTop = selector.offset().top;       
    
                $(window).scroll(debounce(function () {                  
    
                    var currentScroll = $(window).scrollTop(); 
    
                    if (currentScroll >= toolbarTop && currentScroll < bottom.offset().top) {           
                        selector.css({                      
                            position: 'fixed',
                            top: '0'
                        });
                    } else {                                   
                        selector.css({ 
                            position: 'static'
                        });
                    }
    
                }));
            }
        }
    
        // from underscore.js
        function debounce(func, wait, immediate) {
            var timeout;
            return function () {
                var context = this, args = arguments;
                var later = function () {
                    timeout = null;
                    if (!immediate) func.apply(context, args);
                };
                var callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func.apply(context, args);
            };
        };
    
        var timerId = setInterval(myTimeoutFunction, 1500);    
    })(jQuery,tinymce);

Then we just need to register this script and include it with the body. 

    [OrchardFeature("Mod.OddJobules.FixedTinyMceToolbar")]
        public class TinyMceFixedResourceManifest : IResourceManifestProvider {
            public void BuildManifests(ResourceManifestBuilder builder) {
                Orchard.UI.Resources.ResourceManifest manifest = builder.Add();
    
                manifest.DefineScript("FixedTinyMce").SetUrl("tinymce.fixed.js").SetDependencies("OrchardTinyMce");
    
                
            }
        }

    [OrchardFeature("Mod.OddJobules.FixedTinyMceToolbar")]
        public class TinyMceShapeDisplayEvent : ShapeDisplayEvents {
            private readonly IResourceManager _resourceManager;
    
            public TinyMceShapeDisplayEvent(IResourceManager resourceManager) {
                _resourceManager = resourceManager;
            }
    
            public override void Displaying(ShapeDisplayingContext context) {
                if (String.CompareOrdinal(context.ShapeMetadata.Type, "Body_Editor") != 0) {
                    return;
                }
    
                if (!String.Equals(context.Shape.EditorFlavor, "html", StringComparison.InvariantCultureIgnoreCase)) {
                    return;
                }
                
                _resourceManager.Require("script", "FixedTinyMce").AtFoot();
            }
        }

I have an awfully named module as you can see that contains all my weird little helper features... So just add the feature to your module.txt and enjoy the fixed tinymce toolbar. 


----------

EDIT: I accidentally clicked the fullscreen button in TinyMce and learnt that when in fullscreen mode, the TinyMce toolbar is fixed at the top. Doh! So I guess this kind of makes this whole thing redundant.