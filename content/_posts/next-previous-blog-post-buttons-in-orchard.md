---
title: Next/Previous Blog Post Buttons in Orchard
tags:
- Orchard
date: 2017-01-26
---
So I'm currently building a little blog, nothing too fancy, but I wanted next and previous buttons, which don't come out of the box. First thing I did, like the good little developer that I am, was google it. I forgot to put "OrchardCMS" in the first time so just got a bunch of posts on Wordpress forums complaining that they couldn't add said buttons. Not particularly helpful. So I amended my query and what did I find? A module that called [Mod.NextPreviousItem][1], that I wrote back in 2013! Random. Anyway, so this module is old and more complicated than I needed for my simple next/previous blog post. So I stole a few lines of code and tada, next/previous buttons.

I added a new driver for the blog post part to return my fancy new links.

    using System.Linq;
    using Orchard.Blogs.Models;
    using Orchard.ContentManagement;
    using Orchard.ContentManagement.Drivers;
    using Orchard.Core.Common.Models;
    
    namespace Travail.Drivers {
        public class BlogPostPartDriver : ContentPartDriver<BlogPostPart> {
            private readonly IContentManager _contentManager;
    
            public BlogPostPartDriver(IContentManager contentManager) {
                _contentManager = contentManager;
            }
    
            protected override DriverResult Display(BlogPostPart part, string displayType, dynamic shapeHelper) {
                return ContentShape("Parts_NextPreviousBlogPost", () => {
                    var createdDate = part.As<CommonPart>().CreatedUtc;
    
                    var next = _contentManager.Query(VersionOptions.Published, "BlogPost")
                        .Join<CommonPartRecord>()
                        .Where(cr => cr.Container.Id == part.BlogPart.Id)
                        .Where(common => common.CreatedUtc > createdDate)
                        .OrderBy(cr => cr.CreatedUtc)
                        .Slice(0, 1).FirstOrDefault();
    
                    var previous = _contentManager.Query(VersionOptions.Published, "BlogPost")
                        .Join<CommonPartRecord>()
                        .Where(cr => cr.Container.Id == part.BlogPart.Id)
                        .Where(common => common.CreatedUtc < createdDate)
                        .OrderByDescending(cr => cr.CreatedUtc)
                        .Slice(0, 1).FirstOrDefault();
    
    
                    return shapeHelper.Parts_NextPreviousBlogPost(Next: next, Previous: previous);
                });
            }
        }
    }

I added this to my theme (naughty, I know) but you could add it to a module for better reusability. Next we just need a simple view called *Parts.NextPreviousBlogPost.cshtml* that you can pop into your Views folder.

    @using Orchard.ContentManagement;
    
    @{
        ContentItem next = Model.Next;
        ContentItem previous = Model.Previous;
    }
    
    <div class="clearfix">
        @if (next != null) {
            @Html.ItemDisplayLink("Up next: " + Html.ItemDisplayText(next), next, new { @class= "next-post"})
        }
        @if (previous != null) {
            @Html.ItemDisplayLink("Previously: " + Html.ItemDisplayText(previous), previous, new { @class = "previous-post" })
        }
    </div>
    <hr />

And if you need it, a bit of css to make it look pwetty.

    .next-post {
        float: right;
    }
    
    .previous-post {
        float: left;
    }

When I wrote "and a bit of css to make it look pwetty", I didn't realise I had literally written two lines. Not very pretty at all. A bit pathetic really.

Anyway, hope this helps!

  [1]: https://modnextprevious.codeplex.com/