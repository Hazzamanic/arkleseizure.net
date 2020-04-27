---
title: Even titles Getting started with Statamic on Window's IIS Express
tags:
- statamatic
- php
- iis express
date: 2018-03-21
---
A friend of mine recently pointed me in the direction of [Statamic][1], a flat file CMS written on the awesome Laravel PHP framework. I thought it looked pretty cool and they have a local free trial so I decided to give it a try. 

I'm a windows boy and the folks over at Statamic... aren't. I'm also definitely one for the path of least resistance so I thought I'd share how I got there.

Step one, we need PHP. Quickest way to get it is to run the Web Platform Installer, search for PHP and install `PHP 7.1.7 (x86) for IIS Express`. Once this is installed, head over to the installation at `C:\Program Files (x86)\IIS Express\PHP\v7.1` and find the `php.ini` file. Open that (you'll need to be in administrator mode to edit this file), scroll to the bottom and in the `[ExtensionList]` section add: `extension=php_fileinfo.dll` to the end of the list.

Now we need Statamic itself, which you can get [here][2] (you need to enter your email). Unzip the zip and go to root of the Statamic installation, it should look like this:

    statamic
    |-- assets
    |-- local
    |-- site
    |-- statamic
    |-- index.php
    |-- please
    |-- robots.txt
    |-- sample.gitignore
    |-- sample.nginx.conf
    |-- sample.htaccess
    |-- sample.web.config

IIS Express runs at the user permissions level so you shouldn't need to worry about permissions. We do need to set up some url rewriting because otherwise every URL would need index.php on the front. Silly PHP. They do provide a sample web.config but it didn't work for so I made my own:

    <configuration> 
      <system.webServer>
          <rewrite>
              <rules>
                  <rule name="Redirect" stopProcessing="true">
                      <match url=".*" />
                      <conditions>
                          <add input="{REQUEST_FILENAME}" matchType="IsFile" negate="true" />
                          <add input="{REQUEST_FILENAME}" matchType="IsDirectory" negate="true" />
                      </conditions>
                      <action type="Rewrite" url="/index.php" />
                  </rule>
              </rules>
          </rewrite>
      </system.webServer>
    </configuration>

Add this to a web.config file. Now we just need to run our application. Open an administrator command prompt (unfortunately yes, it does need administrator privileges...) and navigate to your Statamic installation e.g.

    cd C:\Users\{YourUser}\Downloads\statamic-2.8.8\statamic

Then run the command

    runphp.cmd

This should fire up the site at a port specified somewhere in all that scrolling command-line text (else check your tray for the IIS Express light blue stacked bricks icon and right click to see the URL). Navigate to this url (if it is port 8080 the url will be `http://localhost:8080`) and you should see the homepage running. To complete the installation go to `/installer.php` and follow the wizard to get set up.

Then enjoy!

  [1]: https://statamic.com/
  [2]: https://statamic.com/try