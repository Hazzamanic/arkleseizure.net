---
title: Upgrading to Windows 10 Anniversary Edition disables IIS
tags:
- windows 10
date: 2016-09-22
---
My PC at work randomly over the weekend decided it needed to update to Windows 10 Anniversary Edition. Normally I'd just huff and puff a little about how I have to reload all the shit I like to clutter my screens with. Not this time though. The upgrade to the Anniversary Edition of Windows 10 decided to give me a giant finger and disable IIS. Enabling IIS is always a pain as you always need to manually check a bunch of random checkboxes in the "Turn Windows Features on or off" screen that are not automatically enabled when enabling IIS (I missed *Internet Information Services > World Wide Web Services > Application Development Features > ASP.NET 4.6*, which is particularly annoying because you get no error message, just a blank page). So once you have enabled everything and you launch IIS, you'll find all your websites etc. have gone. Great. I couldn't get them back so I've spent the morning trying to remember all the different dev sites I had set up. Not fun. 

I browsed Reddit and there are people complaining about this (some people also seem to have had MVC and .NET versions uninstalled too, though luckily that didn't happen to me) so if you haven't got the Anniversary Edition (I would say don't bother but Microsoft will force it on you whether you like it or not), back up your shit! All the IIS config stuff is stored in the *%WinDir%\System32\inetsrv\config* folder.