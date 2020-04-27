---
title: Christmas-ifying Orchard - 2017 edition
tags:
- Orchard
- Christmas
date: 2017-12-06
---
Over four years ago I wrote a [blog post][1] about how you could make your blog snow. The code is still available on Codeplex. Yikes. I thought it was time to update it a little. The snow is now responsive and I improved the performance a little. The snow is automatically injected onto the page when you enable the module. As always when I make anything in Orchard, I ran into a few oddities. Firstly, I needed to display my shape at the beginning of the body tag. Shapes in Orchard can have a position, but if it is null, it defaults to before, so you cant put anything, well, before it. So to get a shape in front we need to insert the shape into the list manually.

    context.Layout.Body.Items.Insert(0, snowShape);

The next issue I had was that scripts and styles I was including in the head of the document were not being rendered. I'm not exactly sure why this was, something to do with the order Orchard renders shapes and how I was inserting shapes into the middle of it from a `ResultFilter` I'm guessing. Unfortunately I didn't have the time to dig into the reason behind it, just a fix, which was to include the script and style using the resource manager directly from my filter.

The code is available on [GitHub][2]. Merry Christmas!


  [1]: http://arkleseizure.net/blog/christmas-ifying-orchard
  [2]: http://context.Layout.Body.Items.Insert%280,%20snow%29;