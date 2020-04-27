---
title: Reclaiming Screen Real Estate in Orchard's Admin Area
tags:
- Orchard
date: 2015-07-03
---
Orchard's admin area is pretty standard, left sidebar with loads of menu items and content taking up the rest of the screen. This works great, easy to navigate and links to other admin sections is easily within reach. However, there are times when you want to make use of the entire screen but still want to be in the admin area. Taking a look at some of the admin themes available from marketplaces, they all seem to feature collapsible side menus, so hopefully this is something we will see in Orchard when the admin theme is revisited. Until then, for our own admin pages, we can do something like this.

First we will need a button.

    <button id="expand">Expand to fit</button>

And to make this button expand the content screen we just need some simple jQuery

    @using (Script.Foot())
    {
        <script type="text/javascript">
            $(function () {
                var expand = function () {
                    $("#expand").text("Shrink to fit");
                    $('#main').css({ position: "absolute", "z-index": "1000", width: "inherit" })
                        .animate({ left: 0, "margin-left": 0 });
                };
    			
                var shrink = function () {
                    $("#expand").text("Expand to fit");
                    $('#main').css({ position: "relative", width: "auto" })
                        .animate({ "margin-left": "260px" });
                };
    
                $("#expand").toggle(expand, shrink);
            });
        </script>
    }

I'm slightly embarrassed to admit that we have some sites running fairly old Orchard codebases, which are still using jQuery pre 1.8. So when I just copied the code I had been using to expand the screen into my brand spanking new Orchard 1.9 codebase, it error'd because the `.toggle()` method no longer exists (as it used to) in jQuery, and I cried a bit. To fix this, you can either load jQuery migrate, which comes with Orchard (`Script.Require("jQueryMigrate")`), or just add a little replacement method (that I stole from [here][1])

    $.fn.toggleClick = function () {
    	var functions = arguments, iteration = 0;
    	return this.click(function () {
    		functions[iteration].call();
    		iteration = (iteration + 1) % functions.length;
    	});
    }

Then just change `toggle` to `toggleClick`, like so.

    $("#expand").toggleClick(expand, shrink);

The result?

![shrunk][2]

![expanded][3]


  [1]: http://stackoverflow.com/a/25150375/1037489
  [2]: /Media/Arkleseizure/Images/shrunk.PNG
  [3]: /Media/Arkleseizure/Images/expanded.PNG