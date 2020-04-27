---
title: Replacing orchard layout's use of the http session with the cache
tags:
- Orchard
date: 2017-02-15
---
The Orchard Layout's module uses the http session to store data as you edit elements. This isn't great when it times out and you lose everything you've been working on. An easy solution would be to simply extend the session timeout in the web.config but I looked at the code and it doesn't just implement the http session directly, this is orchard, it's abstracted out of course. Clearly someone thought session might not be ideal. Maybe they were thinking more along the lines of web farms and sessionless set ups but whatever. 

I implemented the *IObjectStore* using *ICacheService* and I haven't used it much but it seems to be working a lot better. 

    public class CacheObjectStore : IObjectStore {
        private readonly ICacheService _cacheService;

        public CacheObjectStore(ICacheService cacheService) {
            _cacheService = cacheService;
        }

        public string GenerateKey() {
            return Guid.NewGuid().ToString();
        }

        public object Get(string key, Func<object> defaultValue = null) {
            Argument.ThrowIfNull(key, "key");
            return _cacheService.Get(key) ?? (defaultValue != null ? defaultValue() : null);
        }

        public void Remove(string key) {
            _cacheService.Remove(key);
        }

        public void Set(string key, object value) {
            Argument.ThrowIfNull(key, "key");
            _cacheService.Put(key, value);
        }
    }

It is really simple. I just copied the session based implementation and replaced the http session with calls to *ICacheService*