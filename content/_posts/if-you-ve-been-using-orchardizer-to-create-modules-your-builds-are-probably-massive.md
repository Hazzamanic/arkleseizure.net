---
title: Orchardizer causes modules to generate redundant DLLs
tags:
- orchard
- orchardizer
date: 2018-01-02
---
Orchardizer, my extension for Orchard CMS, has an option to create a module for you. Unfortunately, it sets the CopyLocal value for Orchard.Framework to true, which means a huge number of redundant dlls will be added to the bin folder of your module when it is built. The fix is simple, just change the CopyLocal value of Orchard.Framework to false in all your modules. I'm looking into how to change Orchardizer to make that value false by default so hopefully I'll release a fix soon. Ish.