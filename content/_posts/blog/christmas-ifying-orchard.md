---
title: Christmas-ifying Orchard
tags:
- Orchard
- Widgets
- Javascript
date: 2015-03-24
---
<p>So it is Christmas, a time to be merry, break out into song for no good reason and drink copious amounts of sickingly warm wine. But it is also when super nerds can make their blogs...snow! Exciting, I know. You should hopefully be able to see my blog snowing at the top. Not very impressively, and although I am no expert, I&#39;m fairly certain snow doesn&#39;t fall in perfect circles but hey, I&#39;m lazy. I thought I would write a quick post on how I went about making this pathetic little weather system.</p>

<p>I decided to make it as a widget so that I didn&#39;t have to mess around in the theme. It will also make it easy to remove the snow later. So let&#39;s go ahead and create a module using the command line:</p>

<pre>
codegen module Hazza.Christmas</pre>

<p>Next we&#39;ll create a part that will be attached to a widget and create our snow. Again we will use the command line because nobody can be bothered to remember how to write Orchard parts. You will need the exceptional Code Generation Extensions module by <a href="http://www.szmyd.com.pl/blog">http://www.szmyd.com.pl/blog</a></p>

<pre>
codegen part Hazza.Christmas ChristmasPart</pre>

<p>We are just going to create a blank part with no properties. If you wanted to add your properties from the command line, you can! Check it out:</p>

<pre>
codegen part Hazza.Christmas ChristmasPart /Properties:Santa:string,Milk:bool,Cookies:int</pre>

<p>Anyway, getting sidetracked there. We now have a part, but what we really want is a widget. We&#39;ll create a widget in our migrations. The code will look like this:</p>

<pre>
public int Create() {
 SchemaBuilder.CreateTable(&quot;ChristmasPartRecord&quot;, table =&gt; table
  .ContentPartRecord()
 );

 ContentDefinitionManager.AlterPartDefinition(&quot;ChristmasPart&quot;, builder =&gt; builder.Attachable());
 return 1;
}

public int UpdateFrom1()
{
 ContentDefinitionManager.AlterTypeDefinition(&quot;ChristmasWidget&quot;, cfg =&gt; cfg
  .WithPart(&quot;ChristmasPart&quot;)
  .WithPart(&quot;WidgetPart&quot;)
  .WithPart(&quot;CommonPart&quot;)
  .WithSetting(&quot;Stereotype&quot;, &quot;Widget&quot;));

 return 2; 
}</pre>

<p>Basically we are creating an empty part (using the .ContentPartRecord() setting, don&#39;t forget it when creating parts!) and making it attachable in the Create() method. We are then running a new migration and creating a new Content Type called &quot;ChristmasWidget&quot;. The two important things we are doing to our Content Type to make it a widget is attaching the WidgetPart and setting the Stereotype of our Content Type to &quot;Widget&quot;. This lets Orchard know that it should show up in the Widgets section. And probably some other important stuff.</p>

<p>Okay so the snow, I decided not to try to explain the JavaScript code on here, but in comments within the code itself. <a href="https://hazzachristmas.codeplex.com/">Here</a> is a link to the file on CodePlex where you can have a look through it. Can also download the entire source code there.</p>

<p>There are few little bits and bobs in the CSS. You may have to adapt the module a little for your theme. I&#39;m pretty much using the excellent Wise Words theme, though I think it also worked with TheThemeMachine. I used !important (dangerous, I know) so that I didn&#39;t have to mess around in the theme at all. Always nice</p>

<p>So I think that is pretty much it. I doubt I will see many snowy Orchard blogs out there, but would be cool to let me know if you did use it!</p>
