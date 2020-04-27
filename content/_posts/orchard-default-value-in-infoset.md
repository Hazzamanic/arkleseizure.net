---
title: Orchard Default Value in InfoSet
tags:
- Orchard
date: 2015-03-24
---
<p>Orchard 1.8 recently opened up InfoSet storage, which was previously used by fields and content type settings, to parts as well, meaning you don&#39;t need to worry about any pesky migrations. So I have been playing around with this and have converted many of my site setting parts to use the InfoSet storage. Much of the time I want to assign a default value to my site settings. This was simple using migrations with the old record storage system.</p>

<pre>
.Column&lt;string&gt;(&quot;ExcludedColumns&quot;, column =&gt; column.NotNull().WithDefault(&quot;UserPart.HashAlgorithm&quot;))</pre>

<p>However, it wasn&#39;t immediately obvious to me if this was possible with the new InfoSet storage and since Orchard 1.8 was released relatively recently, there is not a lot of documentation. But, of course, the gurus who make Orchard had catered for all us lovers of default properties and there is an optional property on the retrieve method called &quot;defaultValue&quot;. The default value will appear in your site setting views for editing, so it isn&#39;t just a silent default.</p>

<pre>
public string ExcludedColumns
{
 get { 
  return this.Retrieve(x =&gt; x.ExcludedColumns, &quot;UserPart.EmailStatus&quot;); 
 }
 set
 {
  this.Store(x =&gt; x.ExcludedColumns, value);
 }
}</pre>

<p>So there we have it, simples.</p>
