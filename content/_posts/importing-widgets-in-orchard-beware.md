---
title: "Importing Widgets in Orchard: Beware"
tags:
- Orchard
- Widgets
date: 2015-03-24
---
<p>This post is a sort of warning to developers planning to import widgets into their site.<br />
<strong>&nbsp;&nbsp;&nbsp;&nbsp; Make sure you import the layers first!</strong><br />
If you don&#39;t, like I didn&#39;t...three times in a row, you will end up with a horrible error screen in the widgets section. It is because it tries to reference a layer by its Id, so even if you import the layers later it still will not work properly. Would be cool if Orchard checked to see if the layer existed before adding the widget.<p>
<p>
So anyway, if you do find yourself in this situation, it is easily fixed by just deleting the widget. So go into your database and find the content item id of your widget. Can find it in the WidgetPart table. Then head over to the content list and use FireBug or some other dev tools to inspect the delete link for a random piece of content. Edit that link by replacing the ContentItemId with your widgets one. Click the link and bob&#39;s your uncle, the offending widget is gone. Then import your layers (!) and then re-import your widgets.</p>
