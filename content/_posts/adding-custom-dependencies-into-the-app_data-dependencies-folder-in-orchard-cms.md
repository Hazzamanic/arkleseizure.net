---
title: Adding custom dependencies into the App_Data/Dependencies folder in Orchard CMS
tags:
- orchard
date: 2017-12-21
---
Because of Orchard's decoupled nature, the standard bin folders don't quite work for Orchard because no project has a reference to all the other projects included in the solution. What this means is that Orchard needs to copy all the dlls from the modules bin folders into another folder, the Dependencies folder in App_Data. This all just works out of the box generally, however if you have a weird dependency requirement this can all fall apart. Several times I have had a folder of dlls that I require in the bin folder that isn't being copied into the Dependencies folder, because it doesn't support this scenario. This means that things fall apart at runtime when I try to access code that requires this folder of dlls exist. I tried for several (stupidly wasted) hours to use an Orchard hook to add this folder. I know that I wanted to use the `IExtensionLoader` interface but I couldn't work out a way to inject my dependency. I think I know what I needed, which is to add the dependency manually into the Host.config file (this XML file contains autofac config stuff) and add a reference to my module in Orchard.Web. But this seemed a bit long. So I wrote a dirty hack.

	try {
		var repo = new Repository();
		return true;
	} catch (Exception ex) {
		var lib = HostingEnvironment.MapPath("~/Modules/Hazza.StaticGenerator/bin/lib");
		var dependencies = HostingEnvironment.MapPath("~/App_Data/Dependencies/lib");
		if (Directory.Exists(dependencies)) {
			return false;
		}
		var source = new DirectoryInfo(lib);
		var target = new DirectoryInfo(dependencies);
		CopyAll(source, target);

		try {
			var repo = new Repository();
			return true;
		} catch(Exception ex2) {
			// log
			return false;
		}
	}    

It is pretty self explanatory, it tries to access the troublesome code, if it fails, it probably means the Dependencies folder is missing the required dlls, so it copies them over and tries again, if it fails again, it gives up and I cry a little inside. Note: the `//log` comment obviously doesn't log anything but it does serve to remind me and everyone how uselessly lazy I am.