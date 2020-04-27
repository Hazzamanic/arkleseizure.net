---
title: Media Profile Tokens for Orchard CMS
tags:
- Orchard
date: 2016-09-29
---
Orchard has an awesome (although seemingly undocumented) feature called Media Profiles that allow you to dynamically modify media items at runtime (e.g. resize images). I have found it to be a really elegant solution. However, it seems the author forgot to tie it in with Orchard's equally awesome Token feature and provide media profile tokens. Let's fix that.


    public class MediaProcessingTokens : Component, ITokenProvider {
    	private readonly IImageProfileManager _imageProfileManager;
    	private static string Token = "MediaProfile:";
    	private static int Length = 13;
    
    	public MediaProcessingTokens(IImageProfileManager imageProfileManager) {
    		_imageProfileManager = imageProfileManager;
    	}
    
    	public void Describe(DescribeContext context) {
    		context.For("Url", T("Url"), T("Tokens for Urls"))
    			.Token("MediaProfile:*", T("MediaProfile:<profile name>"), T("Processes a url using the given profile"), "Url");
    	}
    
    	public void Evaluate(EvaluateContext context) {
    		context.For<string>("Url")
    			   .Token(
    					token => {
    						if (!token.StartsWith(Token, StringComparison.OrdinalIgnoreCase))
    							return null;
    
    						token = token.Substring(Length);
    						return token;
    					},
    					Process
    				)
    				.Chain(ChainToken, "Url", Process);
    	}
    
    	private static Tuple<string, string> ChainToken(string token) {
    		var dot = token.IndexOf('.');
    		return token.StartsWith(Token, StringComparison.OrdinalIgnoreCase) && dot > Length
    			? new Tuple<string, string>(token.Substring(Length, dot - Length), token.Substring(dot + 1))
    			: null;
    	}
    
    	private string Process(string profileName, string url) {
    		ContentItem item = null;
    		return _imageProfileManager.GetImageProfileUrl(url, profileName, null, item);
    	}
    }

So we have one token here, MediaProfile:*, where * is the name of your media profile (as created in the admin), providing both the token and a chained Url token. This was especially important for us. Tokens in Orchard relies on the implementer of a provider to allow for tokens containing arguments to be chained. I believe this to be an oversight really, hopefully Orchard 2.0 will provide a more robust way of dealing with token parameters.