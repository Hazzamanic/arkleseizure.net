---
title: Retrieving the full HTML from AngleSharp, including the Doctype
tags:
- AngleSharp
date: 2017-11-20
---
[AngleSharp][1] is a pretty sweet document parser for .NET. I was parsing some HTML and making some modifications. All good. Then retrieving the full, modified HTML at the end had me stuck. All the examples I could see said to do it like this: `document.DocumentElement.OuterHtml`. This worked, except it was missing the Doctype. The correct way to do it is to add a reference to `AngleSharp.Extensions` and then you get a nice extension `.ToHtml()`, which is perfect.

I did find this in the docs after I dug into the source code, it is under Getting Single Elements in the examples section. Which makes no sense to me but hey, I guess I was just having one of those days.


  [1]: https://github.com/AngleSharp/AngleSharp