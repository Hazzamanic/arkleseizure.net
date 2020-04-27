---
title: Customizing the tags in the Orchard list shape
tags:
- Orchard
date: 2016-04-15
---
Orchard has shapes. And shapes are awesome. Pretty much anything that renders a list of content in Orchard uses the List shape. This shape basically takes a list of shapes and renders them. It does handy things like paging etc. It also renders items with html list markup, which makes sense, being a list and all. But what if you want to render items using Bootstraps grids? Turns out, this isn't a problem. 

The list shape is rendered from a method in Orchard.Core.Shapes.CoreShapes#695. Methods decorated with the `[Shape]` attribute will be picked up by Orchard's shape harvester. This method lets you override the tag each content item will be rendered in. So let's say `Model.ContentItems` in our list shape that has been created by our controller or driver and we want to override this in our theme.

    @{
    	Model.ContentItems.Tag = "div";
        Model.ContentItems.Classes.Add("row");
        Model.ContentItems.ItemTag = "div";
        Model.ContentItems.ItemClasses.Add("col-md-4");
    }
    
    @Display(Model.ContentItems)

And now we should have a pretty list of items rendered in Bootstrap columns.