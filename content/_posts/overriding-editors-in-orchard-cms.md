---
title: Overriding editors in Orchard CMS
tags:
- Orchard
date: 2018-01-28
---
To override all part or field editors it is very easy. For example, to override the editor for the enumeration field you just drop a file into your views folder: `EditorTemplates/Fields/Enumeration.Edit.cshtml`. But what if you want to override one specific enumeration field editor but leave the rest as the default? Orchard is full of alternates for different shapes and you'd expect there to be alternates for these editor shapes. Unfortunately, the editors don't work like this. For the editors in Orchard to work in the MVC style we are accustomed to, it employs a simple trick to bind the models and add the html prefixes. To do this it renders a generic shape, `EditorTemplate` that renders the specified template. Usually this would be fine, except when you need to use alternates to override a specific editor (for example, a named field). Say you want to override the editor for the Enumeration field with the name FieldName, you'd expect to be able to put a view in your EditorTemplates folder called `Fields.EnumerationField-FieldName` because the alternates are added to the `EditorTemplate` shape. So we can use this and add a view called EditorTemplate-FieldName.cshtml with the contents:

    @{ 
        var m = (Orchard.Fields.Fields.EnumerationField)Model.Model;
    }
    
    @Html.Partial("MyNewEditor", m, new ViewDataDictionary {
        TemplateInfo = new TemplateInfo { HtmlFieldPrefix = Model.Prefix }
    })

Then add another view called MyNewEditor.cshtml with the overrides you want for your editor. All these views should go in the root of your Views folder. You can add a more specific alternate if you have a field with the same name on two content types and only want to override the field editor on one, like so: `EditorTemplate-ContentType-FieldName`.
