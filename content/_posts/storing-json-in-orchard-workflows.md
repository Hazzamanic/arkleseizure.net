---
title: Storing JSON in an Orchard workflow activity
tags:
- Orchard
date: 2017-07-09
---
When Orchard executes a workflow activity, it evaluates any tokens stored in the data for that activity before sending it to the activity. Because JSON is recognised as a token by Orchard (both use curly braces!), Orchard will attempt to evaluate it, fail and replace it with an empty string. So in your activity, you will have nothing! 

To solve this I opted for the simple option to modify the data before it was saved using the form validation to replace the curly braces with double brackets (and vice versa) in JS because I didn't have time to fiddle with it. Hacks for the win...?

I have created an issue regarding this because I think the behaviour is limiting and a little unexpected: https://github.com/OrchardCMS/Orchard/issues/7759