---
title: Orchardizer version 0.3 released
tags:
- orchardizer
date: 2016-02-29
---
I'm pleased to announce that after a year of procrastinating I've finally released a new version of [Orchardizer][1] with a couple of new features and more importantly, support for Visual Studio 2015. There may be a few issues because I don't have nearly as much time as I'd like to dedicate to making it all work beautifully (gotta concentrate on the important things in life, you know, like getting my 2.0 K/D in Call of Duty). So, what's new?

Generate content fields
-----------------------
You can create your own fields now by just entering a few values into some text boxes. Easy! By default it will add your fields to the indexes used by search and projections, which you can easily change in your new fields driver. To use right click on your project -> Add -> New Scaffolded Item... -> Installed -> Common -> Orchard -> Orchard Field, which will bring up the dialog box. 

## Generate layout elements ##
So in 1.9 (?) Orchard introduced the awesome [Layouts][2] feature, built by the wonderful dudes over at [IDeliverable][3]. They've recently introduced parameterized snippets, which are pretty sweet, but if you need more control over your elements you may want to make your own, which requires code. Enter Orchardizer! Generate the boilerplate element stuff so you can get down to the important bit, making your elements look epic. To use right click on your project -> Add -> New Scaffolded Item... -> Installed -> Common -> Orchard -> Orchard Layout Element, which will bring up the dialog box. 

## Constructor Injection ##
You probably recognise this kind of code

    private readonly IOrchardServices _services;
    
    public MyClass(IOrchardServices services) {
    	_services = services;
    }

Total pain in the butt to write that stuff out all the time right? No more. If you are in Visual Studio 2015 you can hover over _services and inject it automatically into the constructor; it will even generate the constructor for you if you haven't created one yet! 

To do all this cool stuff I'm using [Roslyn][4], which is the new C# compiler built in... C#! It's really cool. I don't understand any of it but it is fascinating code to gloss over if you're bored. And brings you so much power, hopefully we'll see even more cool features built with Roslyn soon. 

Note: I realise after discussing this with several other developers, a more common usage would be you add the property you want injected into the constructor then it will create a readonly variable etc. So look out for future versions with this way of doing it.

## Orchard Snippets ##
No one likes boilerplate code. And Orchardizer does some pretty handy stuff to reduce it, but what if you want to edit existing classes and views, not create new ones? Enter snippets. Snippets are nice ways of chucking in code, anywhere really. I've prefixed all my snippets with o for Orchard, for super easy access. And they should all be hiding under an Orchard folder if you open the snippet viewer.

I've added several snippets so far and will add more soon as I find use cases. An up-to-date list of done and planned snippets can be found on my [Trello board][5]. 

----------

So there we have it, new version. All for free! And it's free because it's just not really that great. As always, let me know on [GitHub][6] if anything is totally broken or you want something added. Enjoy!


  [1]: https://visualstudiogallery.msdn.microsoft.com/6408f2a0-ddb0-4fa1-938e-eef0f3ff73a3
  [2]: http://www.ideliverable.com/blog/orchard-layouts
  [3]: http://www.ideliverable.com/
  [4]: https://github.com/dotnet/roslyn
  [5]: https://trello.com/c/NOflICva/57-create-snippets
  [6]: https://github.com/Hazzamanic/orchardizer