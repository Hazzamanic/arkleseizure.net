---
title: Visual Studio Failed to initialize the PowerShell Host
tags:
- Visual Studio
date: 2015-03-24
---
<p>You may see this when you are creating a new project in Visual Studio and several packages fail to install. The error is fairly self explanatory, Visual Studio cant control PowerShell! Googling it may possibly give you the answer, which is basically to allow scripts to run by running PowerShell as Administrator:</p>

<pre>
set-executionpolicy RemoteSigned</pre>

<p>However, if this doesn&#39;t work, it may be because you have two copies of PowerShell, 32bit and 64bit, and you need to change the execution policy for the other one. PowerShell is located:</p>

<pre>
C:\Windows\SysWOW64\WindowsPowerShell\v1.0
C:\Windows\System32\WindowsPowerShell\v1.0</pre>

<p>So change both execution policies, restart Visual Studio and you should be good to go.</p>
