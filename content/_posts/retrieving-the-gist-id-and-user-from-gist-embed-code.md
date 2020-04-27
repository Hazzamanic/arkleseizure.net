---
title: Retrieving the gist id and user from gist embed code
tags:
- gist
date: 2017-11-27
---
Gist embed code is very simple, just a script tag with a link to your gist.

    <script src="https://gist.github.com/carlwoodhouse/05b2a62c53625b483fce94e85de934b8.js"></script>

This super simple regex expression will match the user (group 1) and the gist id (group 2)

    gist\.github\.com\/(\w*)\/(\w*)