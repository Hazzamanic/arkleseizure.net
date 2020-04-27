---
title: Display comment information for a blog on Orchard CMS sites with multiple blogs
tags:
- orchard
date: 2017-09-28
---
**Update (13/09/2017)** Someone made a pull request where there is a much simpler way to do this than my mad HQL queries as Comments contain a field with the id of the container (e.g. the blog). Grab the pull request [here][1]

I manage a website with multiple blogs and this [issue][2] brought to my attention that on the admin summary for a blog (not a blog post) it displays comment information that doesn't actually work. To be honest, I had never even noticed that it displays any comment information at all. After initially flicking this off as a useless feature and we should remove the broken code from the comments module (I still am leaning toward this not being needed for core), I actually figured that this could actually be a pretty cool feature so I threw together a little module for it. You can grab the source on [GitHub][3].

The use enable the feature 'Blog Comment Count' and attach the ContainerCommentsCountPart to your Blog type. 

The module stores the comment counts as aggregates in a new part so there should hopefully be no performance loss when rendering the admin summary shapes for a blog. The counts are calculated in the background when a comment is created or moderated for a blog. I had to dust off my HQL skills because I needed the SUM keyword, which Orchard's query API does not expose (that I could see anyway). It also hides the broken comment count display that comes from Orchard.Comments. 


  [1]: https://github.com/OrchardCMS/Orchard/pull/7847
  [2]: https://github.com/OrchardCMS/Orchard/issues/7838
  [3]: https://github.com/Hazzamanic/Hazza.Blogging