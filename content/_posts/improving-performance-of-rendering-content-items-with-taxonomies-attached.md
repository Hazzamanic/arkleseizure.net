---
title: Improving performance of rendering content items with taxonomies attached
tags:
- orchard
- performance
date: 2017-08-22
---
If you are using taxonomies but not displaying them in your summary shapes for example, Orchard will still need to load all the related data because it (un)helpfully adds an alternate to the Content shape to allow you to customize it based on the taxonomy terms associated with the content item. So on pages with a significant number of items being displayed, it can add quite a lot of additional redundant database calls as linked taxonomies are lazily loaded. If you aren't using this feature at all, you can just comment it out. The relevant code is in `Orchard.Taxonomies.Shapes.cs`:

    builder.Describe("Content")
        .OnDisplaying(displaying => {
    
            // add specific alternates for customizing a Content item when
            // it is associated to a term or taxonomy
    
            var shape = displaying.Shape;
            var metadata = displaying.ShapeMetadata;
    
            // use TermsPart to detect if the content item has a TermPart attached
            // in conjunction with its field name
            ContentItem contentItem = shape.ContentItem;
            var termsPart = contentItem.As<TermsPart>();
    
            if (termsPart == null) {
                return;
            }
    
            var taxonomy = displaying.Shape.Taxonomy as TaxonomyPart;
    
            // Content__[ContentType]__[Field]__[Slug]
            // Content-Image-MainColor-Blue.cshtml
            // Content-Image-MainColor-Blue-Light-Blue.cshtml
    
            // Content_[DisplayType]__[ContentType]__[Field]__[Slug]
            // Content-Image-MainColor-Blue.Summary.cshtml
            // Content-Image-MainColor-Blue-Light-Blue.Summary.cshtml
    
            foreach (var termContentItem in termsPart.TermParts) {
                var field = termContentItem.Field;
                var termPart = termContentItem.TermPart;
    
                foreach (var parent in GetHierarchyAlternates(termPart).Reverse()) {
                    var formatted = FormatAlternate(parent);
    
                    metadata.Alternates.Add(String.Concat("Content__", contentItem.ContentType, "__", field, "__", formatted));
                    metadata.Alternates.Add(String.Concat("Content_", metadata.DisplayType, "__", contentItem.ContentType, "__", field, "__", formatted));
                }
            }
        });