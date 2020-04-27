---
title: Custom Tokens in Orchard CMS
tags:
- orchard
- tokens
date: 2015-03-24
---
In the [previous][1] post we created a site setting and a custom layer rule for widgets. We are now going to look at exposing our setting as a token so it can be used in workflows. Tokens are pieces of text within Orchard that can be dynamically substituted with a value. There is not much by the way of official documentation on tokens but, as always, Bertrand supplies an excellent [two][2] [part][3] introduction to tokens and the basics of how to use them.

The first thing we are going to do is create a class with the *ITokenProvider* interface and the class implementing it. So something like this:

    public interface ITokenProvider : IEventHandler
    {
    	void Describe(dynamic context);
    	void Evaluate(dynamic context);
    }
    
    public class CurrentEventTokens : ITokenProvider {}

What are we doing here? We have basically copied the *ITokenProvider* interface from Orchard.Tokens into our own module and implemented that instead of referencing Orchard.Tokens and implementing their interface. How can we do this? We are inheriting here from *IEventHandler*. This is a specific implementation of IDependecy which, when injected and a method on it called, it will send that message to the event bus, where every implementation of the same interface and method name will be called. This is what allows us to decouple our module from Orchard.Tokens. If you want to know more about IEventHander (and how to use it yourself), I encourage you to read [Sipke's excellent overview][4].

We now must implement the two methods, *Describe* and *Evaluate*. The *Describe* method will provide the description for the tokens, as seen in the image above. The *Evaluate* method will actually parse our token into the desired value.

![Site setting tokens][5]


As we can see above, there is currently a group of tokens for Site Settings, so it would make sense that our tokens could be contained within that too. 

    public void Describe(dynamic context) {
    	context.For("Site", T("Site Settings"), T("Tokens for Site Settings"))
    		.Token("CurrentEvent", T("Current Event"), T("Tokens for the current event"));
    }

So here we are just adding our new token, *CurrentEvent*, to the **Site Settings** group. 

    public void Evaluate(dynamic context) {
    	context.For<CurrentEventSettingsPart>("Site", (Func<CurrentEventSettingsPart>)(() => _orchardServices.WorkContext.CurrentSite.As<CurrentEventSettingsPart>()))
    		.Token("CurrentEvent", (Func<CurrentEventSettingsPart, object>)(part => part.ContentId))
    			.Chain("CurrentEvent", "Content", (Func<CurrentEventSettingsPart, object>)(part => _contentManager.Get(part.ContentId)));
    }

This is where it gets a little more complicated. We can split this up into three distinct parts.

**The Context**
This is the default, global data that our tokens will be accessing. This gets the current site content item and gets our part data. This data is just the default, as it can be overridden if an object with the name of Site is passed into the tokenizer. In the main settings token implementation, an object of type ISite is the default object. This could be a little dangerous because we are sharing the Site token group and if a different object was passed in, it would likely be an object of type ISite, so our code would not work. An example would be:

    var text = _tokenizer.Replace("{Site.CurrentEvent} - {Site.SiteName}", new { Site = WorkContext.CurrentSite });

But I'm sure we will be fine.

**The Token**
This is our token (yay!). Here we say we have a token called *CurrentEvent* that will be evaluated as the property *ContentId* of the data we get from the Context.

**The Chain**
This isn't required, but it is probably the most powerful bit of tokens. Chaining tokens allows us to pass more data on to be processed further in the token chain (did that make sense?). So in our case we produce a Content token from the content id stored in the site setting. This is then passed on and we can access all the contents properties using content tokens. How awesome is that?! 

I'm using this token in a countdown widget, so if the events time is ever changed, there is no need to make a change to the countdown widget as well.

Since we are storing a plain old content id in the database (probably a bit naughty really), the next post will look at importing and exporting our site settings.

  [1]: http://arkleseizure.net/custom-layer-rule-in-orchard-cms
  [2]: http://weblogs.asp.net/bleroy/future-orchard-part-1-introducing-tokens
  [3]: http://weblogs.asp.net/bleroy/future-orchard-part-2-more-tokens
  [4]: http://www.ideliverable.com/blog/ieventhandler
  [5]: /Media/Arkleseizure/Images/sitetokens.png
