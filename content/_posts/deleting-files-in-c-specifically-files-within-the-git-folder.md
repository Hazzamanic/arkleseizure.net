---
title: Deleting files in C# (specifically, files within the .git folder)
tags:
- c#
- git
date: 2018-01-08
---
I wanted to delete an entire directory so I called `Directory.Delete(path, true)` and all was well and everything was deleted. I then wrote some code to initialize git within said folder, which when I tried to delete using the aforementioned `Directory.Delete` things went pear-shaped and all was not well and nothing was deleted. After some unsuccessful google searches involving weird combinations of git, .git, delete and c#, I finally noticed that the files causing me grief were marked with the attributes RA, with R being Read-only and A being Archive. I never really checked which one was the offender but based on my experience of other OS's where read-only is (rightly) treated as something you should check before deleting (Windows Explorer just goes right ahead and deletes it, no problem), I assume read-only was the problem. Hence the following:

        private void DeleteDirectory(string d) {
            foreach (var sub in Directory.EnumerateDirectories(d)) {
                DeleteDirectory(sub);
            }
            foreach (var f in Directory.EnumerateFiles(d)) {
                var fi = new FileInfo(f);
                fi.Attributes = FileAttributes.Normal;
                fi.Delete();
            }
            Directory.Delete(d);
        }

Yay for recursion.