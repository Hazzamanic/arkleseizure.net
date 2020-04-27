---
title: Creating a copy of a database
tags:
- SQL
- Database
date: 2015-08-06
---
If I'm honest, I've always been a little bit of a worry wart, especially when it comes to making big changes to live databases. So I have quite a few test environments where I go and break stuff. Copying a database in SQL is pretty easy, there are just about a thousand ways you can do it and they all seem to be slightly different. This way is for people who want to keep the original database intact and running, not interrupt any backup schedules, basically leave the database we are copying alone. This is just a sort of reference for myself of the easiest way to do it, because I'm forgetful. 

So open SQL Server Management Studio, right click on the database you are want to copy, expand the *Tasks* and select *Back Up...* Keep Backup type as full, and check the *Copy-only Backup* checkbox. Select where you want to store your new .bak file, by default it likes to select an unhelpful location. I generally leave the other Options section as they are, mainly because I don't understand them.

![Back Up Database Screen][2]

![File Location][1]

We should now have our .bak file on the server. If you have a different test environment, ftp it over and then get ready to create your brand new test database, where you can break all the shit.

In SQL Management Studio, right click on the Databases folder in the Object Explorer and select *Restore Database*. As the source select Device then navigate to wherever your .bak file is. This should populate the Database dropdown with the database you want to copy. In the Destination section type the name of the **new** database you want to create, e.g. MyDatabase_Test. This should populate the Backup sets to restore section. Next go to the Files page (from the navigation pane on the left). You'll want to rename the files where the database is actually stored, so rename the .mdf in the Restore As column to the name of your new database (it'll default to the name of the original database). You should be good to go now, click OK and you will shortly have a new database you can go and fuck up.


  [1]: /Media/Arkleseizure/Images/location.PNG
  [2]: /Media/Arkleseizure/Images/backup.PNG