---
title: Speeding up the content type settings page in old Orchard sites
tags:
- Orchard
- Performance
date: 2015-09-17
---
Sadly, I maintain several legacy Orchard sites that are still running on older versions of Orchard. Quite a lot of development went into these sites and we just don't have the time nor resources to move these sites to a newer version of Orchard. One of Orchard's greatest pain points is querying. It is far too easy to fuck it up (though I guess you could pretty much say that about any system to be fair). Looking through some of this old code, a lot of our custom modules, gallery modules and even core modules suffer from queries written like this:

    _contentManager.Query<MyPart>().List();

This code works perfectly... until you have some content items. Then it just dies. The fix is simple:

    _contentManager.Query<MyPart, MyPartRecord>().List();

And bam, your code will perform like a beast. So what does this have to do with the content type settings you may be thinking. Well, if you are using Taxonomies (the original version, before it was merged into the core) then everything. And if you're not, this probably isn't going to help you much. Sorry.

So Taxonomies loads all the Taxonomies you have created so you can select them in the fields settings section which, you guessed it, calls that crap query above. So go to *Contrib.Taxonomies.Services.TaxonomyService* and find the *GetTaxonomies* method and change it to:

    return _contentManager.Query<TaxonomyPart, TaxonomyPartRecord>().List();

You should now be able to edit your site settings to your hearts delight.

If you have a lot of performance problems, it's definitely worth checking for these types of queries in Visual Studio by pressing ctrl+shift+F and using this search `Query<.*Part>()`, expanding Find options so you can check the Use Regular Expressions tick box. Also worth only looking at *.cs file types.