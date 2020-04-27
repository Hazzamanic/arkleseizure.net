---
title: What are Stereotypes in Orchard
tags:
- Orchard
date: 2015-03-24
---
<p>I&#39;ve recently been digging a little deeper into how and why Orchard does the things it does, and one of the things I didn&#39;t quite know the point of was Stereotypes.</p>

<p>You&#39;ve probably noticed when editing or creating a content type there is an option to set the &quot;Stereotype&quot;. This setting is used by widgets and menu items, amongst others, to provide some useful features. Firstly, it is used to populate the list of available Widgets and Menu items in their respective UI&#39;s and secondly, where it is most useful, is for adjusting the type of shape that Orchard will render. By default Orchard uses Content as the shape type, which is why you can create alternates like <var>Content.Page.cshtml</var> and <var>Content-Detail.cshtml</var> etc. However, if you have specified a Stereotype &quot;MyFirstStereotype&quot;, for example, then Orchard will look for a view <var>MyFirstStereotype.cshtml</var> to render the content item. The same applies for editors, so when editing your content type Orchard will look for a view <var>MyFirstStereotype.Edit.cshtml</var>.</p>

<p>I can imagine this potentially coming in pretty handy. I&#39;m currently working on a small customizable dashboard module for Orchard and may utilize content items combined with stereotypes to render items on the dashboard.</p>
