---
title: Using the C# scripting workflow activity in Orchard 1.10 and below
tags:
- Orchard
date: 2016-06-30
---
This workflow activity is pretty awesome. You can write C# then set a number of different outcomes based on your own custom logic. Pretty sweet. However, Orchard tokenizes your input prior to execution and since tokens are defined using `{mytoken}`, your C# code will probably get messed up. The solution is to let Orchard's token engine know you need curly braces left alone by adding `// #{}`. This tells Orchard that tokens should be in the format `#{mytoken}`.