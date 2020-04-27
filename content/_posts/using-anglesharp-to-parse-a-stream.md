---
title: Using AngleSharp to parse a stream
tags:
- AngleSharp
date: 2017-11-23
---
You can parse a Stream with AngleSharp by just passing it into the HTML parser. However, AngleSharp doesn't set the stream position to zero so you get an empty output if you've been writing to a stream and it took me way longer to clock onto that than it should really have done.