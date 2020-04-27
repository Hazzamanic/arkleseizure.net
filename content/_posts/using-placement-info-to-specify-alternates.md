---
title: Using Placement.info to specify alternates
tags:
- Orchard
- Orchard Themes
date: 2015-03-24
---
<p>A little used feature of Orchard&#39;s Placement.info is the ability to define custom alternates to be used within it.</p>

<p>A previous developer at my company needed a part to be formatted slightly differently based on the DisplayType. To this end he wrote a class that generated alternates for parts based on the current DisplayType. This may have seemed like a good idea at the time but in practise, it generates a huge number of useless alternates that will only be of use in one scenario, which does not seem particularly efficient. The simpler solution would have been to use the placement file.</p>

<p>Within your &lt;place&gt; tags you can add extra arguments after the standard location and priority. So let&#39;s take a look at what this would look like.</p>

<pre>
&lt;Match ContentType=&quot;Page&quot;&gt;
  &lt;Place Parts_Title=&quot;Header:1&quot;/&gt;
  &lt;Match DisplayType=&quot;Detail&quot;&gt;
    &lt;Place Parts_Title=&quot;/PageTitle:3;Alternate=Parts_Title__Detail&quot;/&gt;
  &lt;/Match&gt;
&lt;/Match&gt;</pre>

<p>So as you can see, when we match a content type of &quot;Page&quot; and a display type of &quot;Detail&quot;, we will offer an alternate of Parts_Title__Detail, which we can create in our theme, either manually or via Shape Tracing.</p>

<p><img alt="Shape Tracing Image" src="/Media/blog/Images/ShapeTracing.png" /></p>

<p>As you can see, the alternates corresponding file name is <var>Parts.Title-Detail.cshtml</var>, one underscore (_) becomes a dot (.) and two underscores (__) becomes a dash (-). Another interesting thing to note is the use of the forward slash (/) in front of PageTitle in this line:</p>

<pre>
 &lt;Place Parts_Title=&quot;/PageTitle:3;Alternate=Parts_Title__Detail&quot;/&gt;</pre>

<p>PageTitle is a custom zone I have defined in my <var>Layout.cshtml</var> (and added to the list of zones in the Module.txt!)</p>

<pre>
    @if (Model.PageTitle != null) {
        &lt;header id=&quot;page-title&quot;&gt;
            &lt;div class=&quot;container&quot;&gt;
                @Zone(Model.PageTitle)
            &lt;/div&gt;
        &lt;/header&gt;
    }</pre>

<p>So using the forward slash (/) pushes parts into Layout Zones, not in Content Zones, which can come in pretty handy.</p>
