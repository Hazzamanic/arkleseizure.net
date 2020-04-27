---
title: Losing Images in your Website
tags:
- Adblock
date: 2015-03-24
---
At work we are currently building a system that involves advert management. I'm only playing a small role in this project currently, but sat down with the lead developer for a while last week to try and fix a strange issue where some of the advert images were not being loaded onto the page.

The lead developer worked it out. Turns out, [AdBlockPlus][1] was blocking any images with "adv" in the title. It's pretty crazy, I thought it just had a list of domains that it blocks adverts from but it actually does far more than that. [Here][2] is a link to their filter cheat sheet. Although this doesn't seem to cover everything as they also block images with common ad dimensions in the file name too, and probably more sneaky ways to protect us from pesky ads.  


  [1]: https://adblockplus.org/
  [2]: https://adblockplus.org/en/filter-cheatsheet