---
title: Building a Visual Studio Extension
tags:
- Visual Studio
- EnvDTE
date: 2015-03-24
---
In late 2014 I got sick of writing [parts][1] for Orchard. Like, super bored. Previously I had used [Piotr's][2] exceptional [Code Generation Extensions][3] module for Orchard to take away some of that hassle. However, I never much liked having to go into the command line. I always wrote the commands wrong or had to go and look up the syntax because it had to be just right else it would fail. I'm just command line retarded. It also required a reload in Visual Studio, which, with my PC at the time, was an absolute nightmare. And, unfortunately, it has never been updated to work with 'The Shift', so does not generate the latest, sexiest syntax. I have also been hanging around on the side lines of the Orchard community for a while now, answering a few questions here and there, but never really getting involved. So I thought, why not finally contribute something worthwhile?

So, if you didn't know, I released [Orchardizer][4] a little while back, it's had a few downloads. And I've found it very helpful, so it has at least one happy customer. I originally planned to write this post as soon as I had finished the extension but being the lazy bastard that I am, six months have passed. 

Before getting started on the extension I had a little look into what I was getting myself into. I read quite a few articles that talked about how simple it was to build an extension for Visual Studio. So, with my spirits high, I dived in.  

I want to say that I enjoyed it. I want to write an upbeat blog post about how awesome it all was and show everyone what a great coder I am, how up for a challenge I am. Convince you guys the only thing you should do is build your own Visual Studio extension. But really I just remember being exceedingly frustrated by EnvDTE (the assembly-wrapped COM library containing the objects and members for Visual Studio core automation) development. I wanted this to be simple. This was my spare time, I didn't want to have to trawl the internet looking for some documentation or example of how to achieve something that seemed so simple but EnvDTE turned into some convoluted ridiculous mess. I know using famously overused quotes is pretty lame but...

> I choose a lazy person to do a hard job. Because a lazy person will find an easy way to do it - *Bill Gates*

I'm outrageously lazy. And EnvDTE made being me difficult. So as I continued plucking away, I read as much as I could, as many blog posts as I could find on the subject. I remember reading one blogger who mentioned a talk by Mads Kristensen that aimed to remove the stigma surround Visual Studio extension development, how it was no longer just for the big boys, the staff working at Jetbrains or the Microsoft employees of the world. But for all this talk, these bloggers all copied code from existing open source extensions. And who could blame them? The underlying COM stuff is ugly and dealing with the code model that EnvDTE gives you access to is fiddly; limited in its ability to emit code or glean information from the code; buggy; and unintuitive.

Another problem I had was the total lack of support from the online community, not that I blame them, I guess no one really cares about Visual Studio development. It's for the big boys after all. The multitude of queries I posted all went unanswered. These were mostly regarding improving the stability of my code or its performance, situations where an expert would have been a godsend to improve my hacky-but-functional code.

Was it all bad? Of course not. When I wasn't dealing with Visual Studio and just writing pure C#-y stuff I was happy again. And I admit I wasn't entirely truthful when I said my online queries went unanswered. Several times I got the unhelpful comment: use Roslyn.

So, Roslyn. I didn't use Roslyn because Roslyn isn't really out. It's in the Visual Studio 2015 preview. But I did have a play with it. And my god it is nice. Currently, VS has access to the compiler. Obviously. You and I, little developers wanting to build something cool for VS, get the file code model (EnvDTE.Project.CodeModel). Which sucks. But, you might say, there are cool extensions for VS, like [ReSharper][5]! Ha, they don't use the code model, they have a Roslyn-esque model under the hood that builds the syntax trees for offering all their awesome refactoring's etc. So what will change with Roslyn? You, I and Visual Studio will all be using the same API to make VS do its sexy thang. And that is what will really make building Visual Studio extensions for the little fish in the pond too.


  [1]: http://docs.orchardproject.net/Documentation/Writing-a-content-part
  [2]: http://www.szmyd.com.pl/
  [3]: https://gallery.orchardproject.net/List/Modules/Orchard.Module.Szmyd.CodeGeneration
  [4]: http://arkleseizure.net/introducing-orchardizer-a-visual-studio-extension-for-orchard-developers
  [5]: http://www.jetbrains.com/resharper/