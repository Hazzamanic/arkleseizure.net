---
title: What the Hell is an Item Template?
tags:
- Orchard
- Orchard Themes
date: 2015-03-24
---
<p>Theming in Orchard is a pretty vast subject. In the docs on theming for Orchard, <a href="http://docs.orchardproject.net/Documentation/Anatomy-of-a-theme">http://docs.orchardproject.net/Documentation/Anatomy-of-a-theme</a> , it covers a&nbsp;lot of content. A good overview but if you are still trying to wrap your head around whatis going on in Orchard, a bit overwhelming. A few people have found all the different ways of overriding displays a tough one so this post will try, and possibly fail, to address one aspect of templating: Item Templates.</p>

<blockquote>
<p><strong>tl;dr;</strong> Item Templates are the master views for content items.</p>
</blockquote>

<p>So let&#39;s go into a little more detail. Say we have a ContentType, Movie, with three parts attached to it.</p>

<ul>
	<li>Movie</li>
	<li>TitlePart</li>
	<li>DirectorPart</li>
	<li>StudioPart</li>
</ul>

<p>We will use the Placement file to control what is displayed on the page. In this case we want all the parts displayed in the Detail view and only the TitlePart displayed in the Summary view (Detail view in the display type used when you navigate directly to a content item and Summary is displayed, for example, in the search results).</p>

<pre>
&lt;Match ContentType=&quot;Movie&quot;&gt;
  &lt;Match DisplayType=&quot;Summary&quot;&gt;
    &lt;Place Parts_TitlePart=&quot;Summary:1&quot; /&gt;
    &lt;Place Parts_DirectorPart=&quot;-&quot; /&gt;
    &lt;Place Parts_StudioPart=&quot;-&quot; /&gt;
  &lt;/Match&gt;
  &lt;Match DisplayType=&quot;Detail&quot;&gt;
    &lt;Place Parts_TitlePart=&quot;Content:1&quot; /&gt;
    &lt;Place Parts_DirectorPart=&quot;Movie:1&quot; /&gt;
    &lt;Place Parts_StudioPart=&quot;Movie:2&quot; /&gt;
  &lt;/Match&gt;
&lt;/Match&gt;</pre>

<p>The placement file basically defines which content parts will be displayed and where they will go. Summary, Content and Movie are &quot;zones&quot; within a content item that you assign parts to so they can be displayed. So let&#39;s go ahead and define our Content and Movie zones in a file called <strong>Content-Movie.Detail.cshtml</strong>.</p>

<pre>
@using Orchard.Utility.Extensions;
&lt;article class=&quot;content-item&quot;&gt;
&nbsp; &lt;div class=&quot;content&quot;&gt;
&nbsp;&nbsp;&nbsp; @Display(Model.Content)
&nbsp; &lt;/div&gt;
&nbsp; &lt;div class=&quot;content&quot;&gt;
&nbsp;&nbsp;&nbsp; @Display(Model.Movie)
&nbsp; &lt;/div&gt;
&lt;/article&gt;
</pre>

<p>And one for Summary, <strong>Content-Movie.Summary.cshtml</strong></p>

<pre>
@using Orchard.Utility.Extensions;

&lt;article class=&quot;content-item&quot;&gt;
   &lt;div class=&quot;content&quot;&gt;
      @Display(Model.Summary)
   &lt;/div&gt;
&lt;/article&gt;</pre>

<p>These would both be Item Templates. If we wanted to change how the title was being displayed, we could create a Part Template eg. Parts.Title.cshtml</p>

<p>Hopefully that helped you out a little, if you have any questions, don&#39;t hesitate to ask</p>
