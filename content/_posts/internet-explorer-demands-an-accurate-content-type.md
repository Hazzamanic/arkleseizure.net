---
title: Internet Explorer demands an accurate Content Type
tags:
- internet explorer
- metadata
- html5 video
date: 2015-01-30
---
<p>If you regularly use HTML5 video and S3 (or any other provider I suppose) to deliver the content, you have probably seen this message: &quot;Error: <em>Unsupported</em> audio <em>type</em> or invalid <em>file</em> path&quot;. So you have your code like so:</p>

<pre>
&lt;video preload=&quot;none&quot; controls=&quot;controls&quot;&gt;
 &lt;source src=&quot;https://mysite.com/video.mp4&quot; type=&quot;video/mp4&quot;&gt;
&lt;/video&gt;</pre>

<p>Looks good? Works fine in all browsers except IE. Delve into the dev tools and you will see the content-type that the mp4 file is being delivered under is &quot;application/octet-streaming&quot;, which IE doesn&#39;t like. Hosting files on your own server usually wont bring up this kind of problem since the content-type will default to that of the file extension. S3, however, requires you explicitly set it yourself. For some reason.&nbsp;</p>

<p>So if you go into your AWS Console, select the file, then its properties and expand the Metadata section, you should see a dropdown list where you can type in your content-type, &quot;video/mp4&quot;.</p>
