---
title: Actually using Orchard for blogging
tags:
- Orchard
date: 2017-02-22
---

suck my cock

I've been developing with Orchard on and off for over five years but in all that time I've never really used it. You know, properly created lots of content; used the CMS side. Recently I decided to take a break from work and go see the world. And I have a little travel blog/diary. So I've been using it a fairly regularly and although it's still early days and everything has teething issues, I've found a few basic features quite frustrating.

 - Respecting EXIF metadata on images and rotating these images for you. It is a total nightmare uploading images from your camera into Orchard when it does nothing to respect the rotation of the images. [Use ImageResizer's autorotate function!][1]
 - No way to utilize the media profiles within html elements/body. I mean, really? I feel like I'm the only one on Orchard with pictures to upload.
 - The media uploader just doesn't work very well. Especially on a slow internet connection. I have lots of crappy photos of me standing on a hill that I want to put on the internet but when I have to upload each photo individually because dragging more than three in breaks the whole goddamn thing, makes me not want to bother.
 - Dragging selected files into a folder in the folder tree in the media manager has silently failed on more than one occasion leaving me with half my files in one place and half where they were before.
 - No tokens for media profiles. Really? [I'd somehow forgotten that I already added these!][2]
 - I love the layout editor but way too often it has fucked me over. Session timeouts when editing content. Whaaaaat? I'm slow. Don't fucking rush me. [Use the cache, Luke!][3]
 - Has anyone ever written more than five lines in TinyMce? No sticky toolbar means the amount of scrolling is just absurd. [Use this magic jQuery script (or just press the fullscreen option in TinyMce)][4]
 - The media picker pop up box loads the entire admin page and then hides the surrounding elements (e.g. the menu etc.). Being stuck on uber slow WiFi connections in the backend of nowhere teaches you to appreciate when developers have taken time to optimize the delivery of the site and be pissed when they haven't. Plenty of focus on frontend speed but no one cares about the admin :( 


I had the pleasurable company of a fellow traveller who has a WordPress blog and boasts a plentiful number of views per month, who recently had to take his blog down because it was redirecting to nasty websites. A vulnerability in some plugin or other. Standard affairs for WordPress I suppose. I wanted to feel smug that my obscure blog on an obscure platform was running just fine but having spent the previous few hours battling with the media uploader then being given a nice fat null reference exception by the layouts module and lost all my work, I kinda wished I had picked WordPress too...

----------

I'm sure I sound bitchy but your blogging platform should inspire you to write some blog posts, not make you dread it like some sort of ordeal. I know Orchard isn't a blogging platform per se, but it is a content management system and creating content should be its bread and butter. But honestly, I really don't feel like it is.


  [1]: http://arkleseizure.net/respecting-exif-metadata-in-orchard-images
  [2]: http://arkleseizure.net/media-profile-tokens-for-orchard-cms
  [3]: http://arkleseizure.net/replacing-orchard-layout-s-use-of-the-http-session-with-the-cache
  [4]: http://arkleseizure.net/creating-a-static-toolbar-for-tinymce