---
title: Extending Search with Settings
tags:
- Orchard
date: 2015-03-24
---
<p>This post will look into extending some core features of Orchard with custom settings. In this example, we will extend the default search with a setting to change the default display to use for search results. By default the search uses the Summary display view. This is fine in most situations, but Summary view is baked into some of our modules and we needed to be able to use a different view for the Search results.</p>

<p>So the first thing we need to do is create a module. We will use the code generation features provided by Orchard. Head to the dashboard and enable Code Generation. To use Code Generation, you need to fire up the Orchard command line application. This is located in \src\Orchard.Web\bin and called orchard.exe. We are going to create a module called Mod.Search with the following command:</p>

<blockquote>
<p>&nbsp;<em>codegen module Mod.Search</em></p>
</blockquote>

<p>You can go ahead and add this to your solution. We now need to change how the search displays content. This could be done by directly editing the source code but this can present problems updating in the future and is generally a bad practise. So instead we will just overwrite the controller with our own. To do this, first we will create a folder in our module called Controllers, copy the SearchController from Orchard.Search and paste it into our own module, changing the namespace etc. to your own. To make Orchard use our controller instead of the original we will simply create a route with a higher priority and point it to our controller instead of the original one. So create a Routes.cs file in the root of our module with the following route:</p>

<pre>
public IEnumberable&lt;RouteDescriptor&gt; GetRoutes()
{
 yield return
  new RouteDescriptor
  {
   Priority = 100,
   Route = new Route(
    &ldquo;Search&rdquo;,
    new RoutevalueDictionary() {
     {&ldquo;area&rdquo;, &ldquo;Mod.Search&rdquo;},
     {&ldquo;controller&rdquo;, &ldquo;search&rdquo;},
     {&ldquo;action&rdquo;, &ldquo;index&rdquo;}
    },
    null,
    new RouteValueDictionary {
     {&ldquo;area&rdquo;, &ldquo;Mod.Search&rdquo;}
    },
    new MvcRouteHandler()
   )
  };
 yield break;
}
</pre>

<p>Now we need to change what display is used in our controller. This is controlled by the following line:</p>

<pre>
var foundItems = _contentManager.GetMany&lt;IContent&gt;(foundIds, VersionOptions.Published, new QueryHints()).ToList();
foreach (var contentItem in foundItems)
{
 list.Add(_contentManager.BuildDisplay(contentItem, &quot;SummaryItem&quot;));
}
searchHits.TotalItemCount -= foundIds.Count() - foundItems.Count();</pre>

<p>So by default it uses the &quot;Summary&quot; view. We could now change that to whatever view we want, but we may want to have a different display view later. To give us this flexibility, we will create a site scope setting for it.</p>

<p>&quot;Site&quot; is actually a content type, so attaching settings to it is very easy. We will use the excellent code generation features provided by Szmyd. This module is on the gallery and called Code Generation Extensions. Once you have installed this module, we can use it to generate all the bits and bobs we need for our site settings.</p>

<p>Open the Orchard command line again and then type the following command:</p>

<blockquote>
<p>&nbsp;<em>codegen part Mod.Search SearchSiteSettings /Properties:DisplayType:string /AttachTo:Site</em></p>
</blockquote>

<p>This should have created the handler, driver, models and views. Next on the list of things to do is to create the migrations that will turn our models into tables in the database. You can write all this migrations code into the Migrations.cs file itself, but I tend to break it up into separate sections so I can keep track of the migrations more easily. We will also need to set a default value, for our display type. Orchard does appear to have this functionality with the .WithDefault() function but this didn&#39;t seem to work for me so we will write an update feature to manually set the value ourselves.</p>

<p>Firstly, let&#39;s create a folder called MigrationTasks in our module and add a new class to it called SearchSettings. The class will be an internal class because we don&#39;t want any silly people to come along and try to use it somewhere else. So the code is as follows.</p>

<pre>
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Orchard.ContentManagement;
using Orchard.Data.Migration.Schema;
using Mod.Search.Models;

namespace Mod.Search.MigrationTasks
{
    internal static class SearchSettings
    {
        internal static string SearchSiteSettingsRecord = typeof(SearchSiteSettingsRecord).Name;

        /// &lt;summary&gt;
        /// Creates the search settings record.
        /// &lt;/summary&gt;
        /// &lt;param name=&quot;schemaBuilder&quot;&gt;The schema builder.&lt;/param&gt;
        internal static void CreateSearchSettingsRecord(SchemaBuilder schemaBuilder)
        {
            schemaBuilder.CreateTable(SearchSiteSettingsRecord, table =&gt;
                table
                    .ContentPartRecord()
                    .Column&lt;string&gt;(&quot;DisplayType&quot;, c =&gt; c.WithDefault(&quot;Summary&quot;)));
        }

        /// &lt;summary&gt;
        /// Sets the default display type for search to &quot;Summary&quot;
        /// &lt;/summary&gt;
        /// &lt;param name=&quot;schemaBuilder&quot;&gt;The Work Context&lt;/param&gt;
        internal static void SetDefaultValueForSettings(Orchard.WorkContext workContext)
        {
            var settings = workContext.CurrentSite.As&lt;Models.SearchSiteSettings&gt;();
            settings.DisplayType = &quot;Summary&quot;;
        }
    }
}</pre>

<p>This creates the table in the database then will set the value in this table to Summary. Now we just need to create the actual migrations file and we should have a table.</p>

<pre>
private Work&lt;WorkContext&gt; workContext;

public Migrations(Work&lt;WorkContext&gt; workContext)
{
 this.workContext = workContext;
}

public int Create()
{
 MigrationTasks.SearchSettings.CreateSearchSettingsRecord(this.SchemaBuilder);

 return 1;
}

public int UpdateFrom1()
{
 MigrationTasks.SearchSettings.SetDefaultValueForSettings(this.workContext.Value);

 return 2;
}</pre>

<p>An interesting thing to note here is the use of Work&lt;T&gt;. This basically lets us inject dependencies that are appropriate to the current requests context.</p>

<p>Next we need to actually make use of this setting and inject it into the search controller. So let&#39;s create a variable at the top of the Index method called searchSettings to retrieve the search setting.</p>

<pre>
public ActionResult Index(PagerParameters pagerParameters, string q = &quot;&quot;)
{
 var searchSettings = Services.WorkContext.CurrentSite.As&lt;Models.SearchSiteSettings&gt;();
 var pager = new Pager(_siteService.GetSiteSettings(), pagerParameters);
 var searchSettingPart = Services.WorkContext.CurrentSite.As&lt;SearchSettingsPart&gt;();</pre>

<p>Then use this instead of the default.</p>

<pre>
var foundItems = _contentManager.GetMany&lt;IContent&gt;(foundIds, VersionOptions.Published, new QueryHints()).ToList();
foreach (var contentItem in foundItems)
{
 list.Add(_contentManager.BuildDisplay(contentItem, searchSettings.DisplayType)); //&quot;SummaryItem&quot;));
}
searchHits.TotalItemCount -= foundIds.Count() - foundItems.Count();</pre>

<p>All that is left is to clean it all up a little. Our module depends on Orchard.Search so let&#39;s edit the Module.txt.</p>

<p>IMAGE!!!!</p>

<p>We could leave it here but currently our site settings are mixed into the general settings section. It would make sense to have them in the same section as the other search settings. To achieve this we just need to edit the driver a little.</p>

<pre>
protected override DriverResult Editor(SearchSiteSettings part, dynamic shapeHelper)
{
 return ContentShape(&quot;Parts_SearchSiteSettings&quot;,
     () =&gt; shapeHelper.EditorTemplate(
      TemplateName: TemplateName,
      Model: part,
      Prefix: Prefix))
      .OnGroup(&quot;search&quot;);
}</pre>

<p>So we have just added .OnGroup(&quot;search&quot;); to the end of the editor shape. This group is defined by the Orchard.Search module so we don&#39;t need to explicitly do it ourselves. However, if you did want to define your own group, it is done in the handler like so.</p>

<pre>
protected override void GetItemMetadata(GetContentItemMetadataContext context)
{
 if (context.ContentItem.ContentType != &quot;Site&quot;)
  return;
 base.GetItemMetadata(context);
 context.Metadata.EditorGroupInfo.Add(new GroupInfo(T(&quot;Search&quot;)));
}</pre>

<p>And there we have it, site settings to extend a core Orchard feature. Part of this code was written by Matthew Green, and you can find more of his awesome work at <a href="http://www.breakoutdeveloper.com/">http://www.breakoutdeveloper.com/</a></p>
