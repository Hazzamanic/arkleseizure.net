---
title: Custom Layer Rule in Orchard CMS
tags:
- Orchard
date: 2015-05-06
---
I sometimes question the usage of Orchard at work, where we often use it for small, one-time use webcast sites and using a fully-fledged CMS seems a bit overkill. However, when it comes down to it, Orchard is perfect because it is so damn flexible. 

We run live webcast events from Orchard and during the course of an event the homepage is changed depending on the status of the event. Currently we have a page with a list of the different homepages and a button where the client can easily set the active homepage. We wanted a little more flexibility with widgets and not requiring a separate page to manage the homepage. So I set about creating a slightly different solution to what we have now that we could use if needed.

Unfortunately, I cant provide the full source code because there is a lot of work stuff there but it should give you a decent shove in the right direction. We'll cover:

 - Creating a site setting
 - Creating a custom layer rule

The first thing we will need is [Orchardizer][1], a Visual Studio extension that will generate most of the code here for us. You can install it from within Visual Studio, and once that is set up, right click your module and select **New Scaffolded Item**

![Creating a new scaffolded item][2]

You should now see a screen where you can select **Orchard Content Part**

![Creating Orchard Content Part][3]

We are going to create a new site setting part called "CurrentEventSettingsPart" with one property ContentId of type int, as you can see in the picture below

![Creating an Orchard Content Part][4]

Easy. Once that has done its thing you should have a content part attached to the site content (a site setting!). Our site setting basically contains a link to a content item. In my scenario I have a custom content part that stores the status of that content item, which is out of the scope of this blog post. So I wanted to create a layer that would only show widgets that match the current status, something like:

    EventStatus("live")

I had never written a layer rule before but as with all these things, Orchards source code provided all the answers and it turned out to be simple.

    public class EventStatusRuleProvider : IRuleProvider {
    	private readonly IOrchardServices _services;
    
    	public EventStatusRuleProvider(IOrchardServices services) {
    		_services = services;
    	}
    
    	public void Process(RuleContext ruleContext) {
    		if (!String.Equals(ruleContext.FunctionName, "currentevent", StringComparison.OrdinalIgnoreCase)) {
    			return;
    		}
    
    		var contentId = _services.WorkContext.CurrentSite.As<CurrentEventSettingsPart>().ContentId;
    		if (contentId == 0)
    			return;
    
    		var contentItem = _services.ContentManager.Get(contentId);
    		if (contentItem == null)
    			return;
    
    		var part = contentItem.As<ModEventPart>();
    		if (part == null)
    			return;
    
    		ruleContext.Result = String.Equals(part.CurrentEventStatus.ToString(), Convert.ToString(ruleContext.Arguments[0]), StringComparison.OrdinalIgnoreCase);
    	}
    }

A few things are going on here, with most of the code being checks for nulls etc. The first thing we are doing is implementing the *IRuleProvider* interface and injecting *IOrchardServices* into our class. *IRuleProvider* requires us to implement one method called *Process*, which takes in one parameter of type *RuleContext*. This just holds the function that needs to be evaluated, an array of arguments, and the result. All we do then is check whether we need to evaluate the function, get our content id from the site settings, get that content item, check its status versus the status sent in from the layers argument and set the result property of the *RuleContext* to true or false.

Orchards layers allow you to easily combine different rules together. So my layer looks like this:

    EventStatus("live") and url('~/') and authenticated

This layer will trigger on the homepage, when the event is live and the user is authenticated. Perfect. 

In the next post we'll look at exposing our site setting as a token.

  [1]: http://arkleseizure.net/introducing-orchardizer-a-visual-studio-extension-for-orchard-developers
  [2]: /Media/Arkleseizure/Images/scaffold3.png
  [3]: /Media/Arkleseizure/Images/scaffold4.png
  [4]: /Media/Arkleseizure/Images/scaffold5.png