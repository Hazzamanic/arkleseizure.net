---
title: Set a project to automatically start when debugging a Visual Studio Extension
tags:
- Visual Studio
- VSIX
date: 2017-04-18
---
When you're developing a visual studio extension you will likely have a test project that you test with. Well, I do anyway. And I quickly got sick of having to open it over and over. Your debug properties for your VSIX project probably look something along the lines of this.

![no start up project][1]

If you simply add the path to your solution, it will be loaded automatically and save you one or two clicks.

![enter image description here][2]

Obvious in retrospect...

  [1]: /Media/Arkleseizure/Images/noproj.PNG
  [2]: /Media/Arkleseizure/Images/projadded.PNG