---
title: Regex to get the Twitter Tweet Id from a status embed link
tags:
- regex
date: 2018-01-04
---
This regex will grab the tweet id from a Twitter embed url with some example C# code.

    var regex = new Regex(@"twitter\.com\/.*\/status(?:es)?\/([^\/\?]+)", RegexOptions.IgnoreCase);
    var match = regex.Match(href);
    if (match.Success) {
    	return match.Groups[1].Value;
    }

