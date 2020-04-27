---
title: Making your Driver Display Methods Perform Better
tags:
- Orchard
date: 2015-04-28
---
Orchard is blazingly fast out of the box. I mean, I started at v0.9 and it was well, pretty crappy. But now? It is an absolute beast. However, it is all too easy to completely screw up the performance. How many times do you read messages on Codeplex or Stackoverflow along the lines of: "Orchard admin really slow when I have my module enabled", "Homepage really slow with custom content type" etc. etc. Quite a lot right? I find that when I write a particularly pathetic method that cocks up performance, it usually stems from my lack of understanding about the guts of Orchard. Take Drivers for example. You may have seen code like this. 

    protected override DriverResult Display(MyPart part, string displayType, dynamic shapeHelper)
    {
    	// do loads of computations
    
    	// return the shape
    	return ContentShape("Parts_MyPart", () => shapeHelper.Parts_MyPart());
    }

Looks fine, right? No, not fine. Naughty. The problem with this stems from how Orchard displays content. When a piece of content is displayed in Orchard it goes something like this. The default Content shape is built and several standard properties for the shape are set (the content item, the layout and the display type). It then runs through all the `IContentHandlers`, calling the `BuildDisplay` method. There are two particularly important handlers, and those are the ones that call all the driver Display methods for Parts and Fields. After it has collected all the driver results, the placement checks are done to decide whether or not a driver should actually return a shape. What this means is that if you have code contained within the Display method that is not in the Func type returned in ContentShape, it will be run even if it the part is not actually going to be displayed. Which doesn't sound too great if you ask me. So to improve the above method, all we need to do is...

    protected override DriverResult Display(MyPart part, string displayType, dynamic shapeHelper)
    {
    	// return the shape
    	return ContentShape("Parts_MyPart", () => {
    		// do loads of computations
    		
    		return shapeHelper.Parts_MyPart();
    	});
    }

What we have done is moved the "do loads of computations" section into the ContentShape result, so it will only be run if our shape is indeed being displayed. Super speedy.