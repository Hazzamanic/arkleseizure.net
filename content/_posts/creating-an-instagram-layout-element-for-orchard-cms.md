---
title: Creating an Instagram layout element for Orchard CMS
tags:
- Orchard
- Instagram
date: 2017-09-12
---
A sweet feature in orchard is the layouts module, that lets you create complex page layouts from a drag and drop editor. It had also been well thought out with little extras. One is the ability to create layout elements, complete with configuration options, by simply creating the display shape in your theme and including Snippet at the end of your view name. Let's give it a whirl.

For our travelling blog, we wanted to include some pictures from Instagram. I'm so fairly sure Instagram has some embed option. But Instagram also have an API. And I like wasting time on random stuff. So off I went. I grabbed a [slider][1] from the Internets and a sweet little js library called [Instafeed.js][2]. And that was pretty much that. My view is called `InstagramFeedSnippet.cshtml`.

    @using Orchard.Layouts.Helpers
    
    @{ 
        Style.Include("flickity.min.css");
    
        Script.Include("instafeed.min.js").AtFoot();
        Script.Require("flickity.pkgd.min.js").AtFoot();
        //@Html.SnippetField
    }
    <div id="instafeed">
    </div>
    
    @using (Script.Foot()) {
        <script type="text/javascript">
            var isMobile = window.matchMedia("only screen and (max-width: 760px)");
            var wdth = '320';
            var reso = 'low_resolution';
            if (isMobile.matches) {
                wdth = '150';
                reso = 'thumbnail';
            }
    
            var feed = new Instafeed({
                get: 'user',
                userId: '@Html.SnippetField("tag").DisplayedAs(T("User Id"))',
                accessToken: '@Html.SnippetField("accessToken").DisplayedAs(T("Access Token")).WithDescription(T("Register your application within instagram to obtain your access token"))',
                template: '<a style="width: ' + wdth + 'px; height: ' + wdth + 'px;" href="{{link}}"><img style="width:100%" src="{{image}}" /></a>',
                resolution: reso,
                after: function () {
                    var flkty = new Flickity('#instafeed', {
                        wrapAround: true,
                        cellAlign: 'left',
                        prevNextButtons: false,
                        pageDots: false
                    });
                }
            });
            feed.run();
        </script>
    }

Check it out at the bottom of my [travel blog][3]. Snippets are so sexy, so thanks to Sipke and everyone else involved in making them happen!

Oh, and you'll need a client id for Instagram, [google it][4]!

To learn more about Orchard Layouts check out the [eBook][5] by the dudes who made it! 


  [1]: https://flickity.metafizzy.co/
  [2]: http://instafeedjs.com/
  [3]: http://travellingwrong.com
  [4]: https://google.com/search?q=How%20to%20get%20an%20instagram%20client%20id
  [5]: http://www.ideliverable.com/products/books/mastering-orchard-layouts