---
title: Thoughts on making Orchard themes a dream to customize and develop
tags:
- Orchard
- Themes
date: 2017-11-14
---
A project I am currently working on needs configurable theming options. I resurrected a demo I made a while ago for Orchard CMS and stole a few bits and bobs. It reminded me that I started writing a blog post about it that was just sitting unfinished and unpublished from years ago. So here it is, a little late.

I remember when I made my first theme and my boss told me we needed to be able to change the header colour. Easy. So I added a site settings part with a property header colour. Then I added a shape to the Layout that picked up my settings and rendered some style tags to change the header colour. Then we needed a font picker because, of course the theme should support different fonts. New property on my part. Excellent. Then we needed different font pickers for headers, menu, body. But they needed to inherit if none was displayed. Okay, some funny logic and more properties to my settings part. A bunch more properties later and a boatload of CSS in style tags the theme settings were now doing things they really shouldn't have been doing. You could add featured images, logos, tag lines, contact information etc. It was starting to look like an unwieldy WordPress theme, doing anything and everything. But if I had had my 'Orchard' way, everything would be buried in their own modular settings screen, widget page etc. We needed a marriage between the two, an easy place for users to go to find settings but not all managed by one lumbering giant, horrible-to-maintain theme. 

To this end, several years ago now, I created a small demo. Here are a few thoughts behind it.

![less editor][1]

 - **LESS**. Adding lots of CSS to the page in style tags is not ideal, both in terms of page performance and in manual work required to code different properties. Individual CSS properties are also rather limiting. When you change certain properties you may want that colour to propagate across to multiple properties. The module provides a pipeline for generating CSS using LESS. This would likely be made extensible to support other pre-processors like SASS and CSS variables.
 - **Extensible editor**. Of course, this is Orchard. Different types of editor can be created and used by settings e.g. colour picker, text etc.
 - **No code required**. I like the idea of quickly creating themes in Orchard, not having to create a project. Unfortunately, I've found myself having to make my theme a project so I can add code for certain features. Theme settings are defined via JSON. An example is defined below:

         {
            "Version": "1.0",
            "SchemaVersion": "1.0",
            "Settings": [
                {
                    "Type": "LessVariables",
                    "Properties": {
                        "VariablesPath": "~/Themes/Mod.Bootstrap/Styles/Bootstrap/less/variables.less",
                        "Compiler": "~/Themes/PaperChaser/ThemeSettings/main.cshtml",
                        "Root": "Themes/PaperChaser/Styles"
                    }
                }
            ],
            "Groups": [
                {
                    "Name": "Layout",
                  "Settings": [
                    {
                      "EditorType": "Color",
                      "Type": "LessVariable",
                      "Properties": {
                        "Name": "@bg-color",
                        "DisplayName": "Background Color",
                        "Default": "#fff",
                        "Description": "This is the background color"
                      }
                    },
                    {
                      "EditorType": "Color",
                      "Type": "LessVariable",
                      "Properties": {
                        "Name": "@bg-xxx",
                        "DisplayName": "xxx Color",
                        "Default": "#000",
                        "Description": "This is the xxx color"
                      }
                    }
                  ]
                }
            ]
        }

 - **Not required**. Orchard has suffered terribly from a lack of themes and adding another roadblock by making themes require a theme settings framework would be unlikely to help the situation. Themes work just fine without this module, they are just enhanced by it as it allows them to be customized.
 - **Adhoc usage**. Allow theme developers to access settings directly in views. Unfortunately this would likely break the point above, but it is flexible.

<pre><code>@Html.GetThemeSetting<string>("setting_key")</code></pre>


Unfortunately the company I worked with at the time began to step back from Orchard so I never took it further but the roadmap included:

 - **Extensible settings**. Right now it only really supports LESS generation and accessing settings directly within views. But it would be trivial to make certain settings manipulate placement (e.g. to hide/show certain zones/parts), register alternates, change the layout view etc.
 - **Based On**. This is currently a bit of a problem, working out how themes that are based on other themes that use theme settings behave. Should all settings be displayed? Should the child theme decide which settings it will inherit from the base theme?
 - **Hub**. Allow other things that may affect the theme be either configurable from the same editor (e.g. social icons provided by a module) or linked to (e.g. homepage widgets)
 - **More editors**. I believe I only implemented basic text (also the fallback if the specified editor is not found) and colour picker. Examples could be: file upload, google font picker, drop downs.
 - **More than site settings**. The module shouldn't be limited to just site wide changes, but also provide individual content items with the ability to select the alternate to be used for summary and detail shapes, for example.
 - **Live preview**. I had to add customization options to a WordPress theme a while back and to add live preview functionality you had to write jQuery to manually update CSS. The end result was, admittedly, pretty cool. But it was definitely painful. I think (naturally) that adding live previewing to this would be trivial since LESS can be generated clientside using less.js (in fact I already do this to provide updates to variable values). SASS is also js based, and though I haven't looked into CSS variables, I'm sure there must be ways to regenerate the CSS on-the-fly. Some other settings may require page refreshes to see changes but this shouldn't really be a huge issue.
 - **Multi theme support**. For scenarios where you have a mobile theme and want to manage settings for that too.

This is definitely not perfect, but I think exposing a framework from which theme authors can easily add customization options and integrate modules organically, would greatly improve the theme scene (I really wanted to say that) within Orchard.

Clearly it took me a little too long (over three years in fact) to get off my ass and actually write this blog post and it is probably too late for poor old Orchard now. Here's hoping Orchard Core will fair a little better and we'll see some sexy themes built.

If anyone wants the source code I can send it. Fair warning, it ain't pretty. Or guaranteed to work haha.


  [1]: /Media/Arkleseizure/Images/less_editor.gif