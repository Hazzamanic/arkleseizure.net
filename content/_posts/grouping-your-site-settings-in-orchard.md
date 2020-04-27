---
title: Grouping your Site Settings in Orchard
tags:
- Orchard
date: 2015-03-24
---
<p>I&#39;m slightly OCD when it comes to organising my settings in Orchard, of which I seem to have a vast amount. And luckily, Orchard has a nifty way of doing this for you and it is beautifully simple to implement.</p>

<p>So to start with you are going to need to have some site settings, which I have covered in <a href="http://arkleseizure.net/extending-search-with-settings">this post</a>. Once you have built your site setting, you are going to need to create a menu item that will be displayed in an expandable list under the Settings menu item in the Orchard dashboard, which will be done in the handler.</p>

<pre>
public class UniTownSiteSettingsPartHandler : ContentHandler
{
 public UniTownSiteSettingsPartHandler(IRepository&lt;UniTownSiteSettingsPartRecord&gt; repository)
 {
  Filters.Add(StorageFilter.For(repository));
  Filters.Add(new ActivatingFilter&lt;UniTownSiteSettingsPart&gt;(&quot;Site&quot;));

  T = NullLocalizer.Instance;
 }

 public Localizer T { get; set; }

 protected override void GetItemMetadata(GetContentItemMetadataContext context)
 {
  if (context.ContentItem.ContentType != &quot;Site&quot;)
   return;
  base.GetItemMetadata(context);
  context.Metadata.EditorGroupInfo.Add(new GroupInfo(T(&quot;Statistics&quot;)));
 }
}</pre>

<p>The important method here is GetItemMetadata, which I have used to add a new group &quot;Statistics. Next you need to actually place your site settings into that group via the Editor method in your driver.</p>

<pre>
protected override DriverResult Editor(UniTownSiteSettingsPart part, dynamic shapeHelper)
{
 return ContentShape(&quot;Parts_UniTownSiteSettingsPart&quot;,
  () =&gt; shapeHelper.EditorTemplate(TemplateName: TemplateName,
   Model: part,
   Prefix: Prefix))
  .OnGroup(&quot;Statistics&quot;);
}</pre>

<p>So all we are doing is appending .OnGroup(&quot;Statistics&quot;) to our return statement. Simple!</p>
