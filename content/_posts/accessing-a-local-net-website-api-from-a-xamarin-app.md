---
title: Accessing a local .NET website (API) from a Xamarin app
tags:
- xamarin
- iis express
- .net
date: 2018-07-19
---
The Android emulator has a nifty feature to allow apps to access the host computers local address, 127.0.0.1, by using `http://10.0.2.2:*port*`. If you are trying to connect to a .NET api you're developing running at `http://localhost:60765` let's say, you'd put `http://10.0.2.2:60765`. Unfortunately this wont work because IIS Express binds to localhost not 127.0.0.1. Fortunately the fix is simple. Open the folder containing your .NET solution and navigate to `.vs\config\applicationhost.config` (note `.vs` is a hidden folder) then search for the port you are running on, you should find something like this within the `<sites>` tag.

    <site name="MySite" id="2">
    	<application path="/" applicationPool="Clr4IntegratedAppPool">
    		<virtualDirectory path="/" physicalPath="C:\Users\..." />
    	</application>
    	<bindings>
    		<binding protocol="http" bindingInformation="*:60765:localhost" />
    	</bindings>
    </site>

Change `localhost` to `127.0.0.1` and voila, it should now be accessible from your app.