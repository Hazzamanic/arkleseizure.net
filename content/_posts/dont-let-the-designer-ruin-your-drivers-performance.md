---
title: Don't let the Designer Ruin your Driver's Performance
tags:
- Orchard
date: 2015-05-16
---
I remember when I clocked onto how to make my drivers in Orchard [a bit less crap][1], I was very proud of myself. Feeling all chuffed with my website now not performing at snail speed, I went onto design my theme. What did I do? Fucked up performance of course. How? I was lazy and removed ContentZones from [Item Templates][2]. Sure, it looked pretty, but Orchard still thought it was going to be displaying a bunch of parts that weren't actually being displayed because that is what the placement said for it to do. Hence, all those damn drivers fired. Sad times.

It is one of those caveats you have to watch out for in Orchard's dynamic dispatching of content, awesome but sneaky. So just to clarify, always make sure what your placement says to be displayed matches what your views are allowing to be displayed. Take the following placement file.

    <Match ContentType="CoolContent">
     <Place Parts_CoolPart="CoolZone:1"
    		Parts_AwesomePart="AwesomeZone:1" />
    </Match>

Looks okay, we are saying for the content type *Cool Content*, the **CoolPart** will be displayed in the **CoolZone** and the **AwesomePart** will be displayed in the **AwesomeZone**. Now let's look at the view, *Content-CoolContent.cshtml*.

    <div>
    	@Display(Model.CoolZone)
    </div>

All this is displaying is the **CoolZone**, the **AwesomeZone** isn't there, but because the placement is saying to create the **AwesomePart** in the **AwesomeZone**, Orchard will still create that part and send it to that zone, even though it wont ultimately be displayed.

I think that's enough of the word 'displayed' for a little while...


  [1]: http://arkleseizure.net/making-your-driver-display-methods-perform-better
  [2]: http://arkleseizure.net/what-the-hell-is-an-item-template