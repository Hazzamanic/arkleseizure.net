---
title: Adjusting the Base Url on a per request basis in Orchard CMS
tags:
- orchard
date: 2017-12-23
---
This is a rather obscure requirement that, surprisingly, I have needed on two separate occasions. Hence the blog post, just in case any other poor sod out there needs it.

Most recently I needed it to generate a static based website, where the url of the generated static pages would be different to my Orchard installations base url. I could have just changed the base url but it did break a few parts of Orchard that I could have easily lived with but I'm a stickler for doing things "right". 

[OrchardSuppressDependency("Orchard.Core.Settings.Services.SiteService")]
    public class StaticGeneratorSiteService : ISiteService {
        private readonly IContentManager _contentManager;
        private readonly ICacheManager _cacheManager;
        private readonly IWorkContextAccessor _wca;

        public StaticGeneratorSiteService(
            IContentManager contentManager,
            ICacheManager cacheManager, IWorkContextAccessor wca) {
            _contentManager = contentManager;
            _cacheManager = cacheManager;
            _wca = wca;
        }

        public ISite GetSiteSettings() {
            var siteId = _cacheManager.Get("SiteId", true, ctx => {
                var site = _contentManager.Query("Site")
                    .List()
                    .FirstOrDefault();

                if (site == null) {
                    site = _contentManager.Create<SiteSettingsPart>("Site").ContentItem;
                }

                return site.Id;
            });

            var realSite = _contentManager.Get<ISite>(siteId, VersionOptions.Published);
            if (!_wca.GetContext().GetState<bool>("requestingStatic")) {
                return realSite;
            }

            string baseUrl = "mynewurl";
            return new FakeSiteSettings(realSite, baseUrl);
        }
    }

So after you grab the site settings from the content manager, you will have to do whatever check you need to decide whether you need to change the base url for the given request. I was checking for specific parameter in the url and setting a state on the WorkContext in a filter.

The `FakeSiteSettings` class looks like this.

public class FakeSiteSettings : ISite {
        private readonly ISite _site;
        private readonly string _baseUrl;

        public FakeSiteSettings(ISite site) {
            _site = site;
            _baseUrl = "";
        }

        public FakeSiteSettings(ISite site, string baseUrl) {
            _site = site;
            _baseUrl = baseUrl;
        }

        public string BaseUrl
        {
            get
            {
                return string.IsNullOrWhiteSpace(_baseUrl) ? _site.BaseUrl : _baseUrl;
            }
        }

        public ContentItem ContentItem
        {
            get
            {
                return _site.ContentItem;
            }
        }

        public string HomePage
        {
            get
            {
                return _site.HomePage;
            }

            set
            {
                _site.HomePage = value;
            }
        }

        public int Id
        {
            get
            {
                return _site.Id;
            }
        }

        public int MaxPagedCount
        {
            get
            {
                return _site.MaxPagedCount;
            }

            set
            {
                _site.MaxPagedCount = value;
            }
        }

        public int MaxPageSize
        {
            get
            {
                return _site.MaxPageSize;
            }

            set
            {
                _site.MaxPageSize = value;
            }
        }

        public int PageSize
        {
            get
            {
                return _site.PageSize;
            }

            set
            {
                _site.PageSize = value;
            }
        }

        public string PageTitleSeparator
        {
            get
            {
                return _site.PageTitleSeparator;
            }
        }

        public ResourceDebugMode ResourceDebugMode
        {
            get
            {
                return _site.ResourceDebugMode;
            }

            set
            {
                _site.ResourceDebugMode = value;
            }
        }

        public string SiteCalendar
        {
            get
            {
                return _site.SiteCalendar;
            }

            set
            {
                _site.SiteCalendar = value;
            }
        }

        public string SiteCulture
        {
            get
            {
                return _site.SiteCulture;
            }

            set
            {
                _site.SiteCulture = value;
            }
        }

        public string SiteName
        {
            get
            {
                return _site.SiteName;
            }
        }

        public string SiteSalt
        {
            get
            {
                return _site.SiteSalt;
            }
        }

        public string SiteTimeZone
        {
            get
            {
                return _site.SiteTimeZone;
            }
        }

        public string SuperUser
        {
            get
            {
                return _site.SuperUser;
            }
        }

        public bool UseCdn
        {
            get
            {
                return _site.UseCdn;
            }

            set
            {
                _site.UseCdn = value;
            }
        }
    }

Pretty long, but it is basically just a wrapper around Orchard's default site settings class. The only difference is if the `_baseUrl` has been set it will return that rather than the one from the stored site settings.