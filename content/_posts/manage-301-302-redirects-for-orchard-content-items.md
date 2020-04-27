---
title: Manage 301/302 redirects for Orchard content items
tags:
- orchard
- redirect
date: 2017-12-15
---
I had some problems earlier this year with Google complaining that there were a few links around the internet that pointed to non-existent URLs on my blog, blocking me from getting an AdSense account. So I threw together a tiny module that allows 301 and 302 redirects to be configured from a content items edit page. 

The module is available on [GitHub][1]. Once it is enabled, there is a new part RedirectRoutes available to be attached to your content items that will add a new tab to the editor page called Redirects, where you can add a new alias that will redirect to the current route. If the AutoroutePart is attached, it will redirect to this URL. For each alias you can choose if it should be a 301 permanent redirect, or a 302 temporary redirect.

As always, report any bugs on GitHub and share if you found it useful. If you found it really useful, a small donation to help me keep things afloat is always appreciated. 
<script type='text/javascript' src='https://ko-fi.com/widgets/widget_2.js'></script><script type='text/javascript'>kofiwidget2.init('Buy Me a Beer', '#46b798', 'K3K16MLC');kofiwidget2.draw();</script> 

  [1]: https://github.com/Hazzamanic/Hazza.Routes