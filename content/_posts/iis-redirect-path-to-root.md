---
title: IIS Redirect Path to Root
tags:
- IIS
date: 2015-08-26
---
We have been migrating quite a few sites at work recently so thought I'd just note down a simple iis rule for redirecting a path to the root of your site.

    <system.webServer>
    	<rewrite>
    		<rules>
    			<rule name="redirect to root" stopProcessing="true">
    				<match url="^test[/]?$" />
    				<action type="Redirect" url="/" />
    			</rule>
    		</rules>
    	</rewrite>
    </system.webServer>

The regex matches /test/ and /test then redirects to the root. Note that when you are playing around with redirects it appears browsers cache them so you need to clear your browsers cache each time you change your redirect rules