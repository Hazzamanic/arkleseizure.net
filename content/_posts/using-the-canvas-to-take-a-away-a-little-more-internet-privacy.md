---
title: Using the canvas to take away a little more internet privacy
tags:
- Privacy
date: 2015-03-24
---
<p><strong>UPDATE:</strong></p>

<p>You can of course blanket block all this stuff using <a href="https://adblockplus.org">AdBlock</a>, which I was apparently too slow to realise.</p>

<p>Today I read about a novel way of tracking unique users even when they&nbsp;have&nbsp;cookies disabled. Now, we all know there are many ways to track users beyond the standard cookies, generally referred to as evercookies (probably named after this <a href="https://github.com/samyk/evercookie">library </a>created by Samy?), using a wide variety of methods such as Flash objects and various HTML5 storages. However, this slightly different method, which was <a href="http://www.w2spconf.com/2012/papers/w2sp12-final4.pdf">discovered</a> in 2012 by a group researchers, is pretty fucking cool and a slight bit more canny. It collects a bunch of data unique to that user from their computer (operating system etc.), then writes this information onto the browsers canvas. It then instructs the browser to read this image back, generating what is effectively a unique fingerprint. So when a user visits a different site, that same fingerprint can be created and matched to build a profile on that user. I imagine it also does something clever and extracts a unique section of the image generated by the browser to send back to its servers so it doesn&#39;t have to store a shitload of data.</p>

<p>So is this being used out in the wild? A group of researchers at KU Leuven and Princeton University have done a massive <a href="https://securehomes.esat.kuleuven.be/~gacar/persistent/index.html">study</a> and discovered that a whopping one in eighteen of the top 100,000 websites are using this technique. And even more astounding, it can all be traced back to a single company: <a href="http://www.addthis.com/">AddThis</a>. Well, we never really suspected them to be a bastion of morality, did we? (I bring up morals here&nbsp;because there is little a user can do to block this kind of tracking, even if they have disabled cookies in an effort not to be tracked).</p>

<p>I say little, you can use Tor browser, which does have functionality to stop this tracking. I do remember seeing it prompt me long ago that the website I was on was trying to read image data from my canvas and having no clue why I should care about that. Ignorance isn&#39;t always bliss. However, using Tor browser&nbsp;to look&nbsp;at pictures of cats is a bit of a mission.</p>

<p>So ultimately, what does all this mean? Nothing. Websites are tracking as much as they can about you in as many ways as they can. And can we blame them? Data is money, and most of these sites can only stay in operation because of advertising displayed on their sites. Companies will only pay for adverts if they know that everything possible is being done to target their potential customers.</p>

<p>But regardless of where you stand on privacy on the internet (there is only one place you should stand though really, privacy matters), this is a cool way to destroy internet privacy.</p>

<p>&nbsp;</p>