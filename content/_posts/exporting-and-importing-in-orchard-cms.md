---
title: Exporting and Importing a Content Item Relation in Orchard CMS
tags:
- Orchard
date: 2015-04-25
---
The feature we use the most at work is Orchards awesome [import and export][1] ability. You can take any content on your site, export it into an XML file and then import it into another site. It allows you to get a site up and running in a heartbeat. In the [previous post][2] we added token support for our site setting. Our site setting stores a plain Id for a content item in the database. This is okay, but when we import our content the Id's will most likely all be different. To support this scenario, Orchard offers the concept of a content item identity. Bertrand Le Roy again provides an excellent [explanation][3] of Identity in Orchard, but in short it is just a combination of unique identifiers such as a randomly generated guid, or a pages alias. So we want to export this identity instead of the Id value stored in the database and convert the identity into an Id during the import. 

Import and Export are handled in the driver, with one method for each. Let's start with the export. In your driver, go ahead and add the following method declaration.

    protected override void Exporting(CurrentEventSettingsPart part, ExportContentContext context) {}

This method takes in the part (our site setting) and the ExportContentContext which is basically just an XElement that will be added to the export document. So let's first try and export just the plain old content Id. 

    var partDefinitionName = part.PartDefinition.Name;
    if (part.ContentId != 0) {
    	context.Element(partDefinitionName).SetAttributeValue("ContentId", part.ContentId.ToString());
    }

So here we are just getting the name of our part (which will be the name of the Element and setting an attribute of "ContentId" with the value from the database. Simples. To change that Id to the content items identity is fairly simple, so we'll change what's in the if statement above to:

    context.Element(partDefinitionName).SetAttributeValue("ContentId", _contentManager.GetItemMetadata(_contentManager.Get(part.ContentId)).Identity.ToString());

Here we are getting the content item, then getting the metadata relevant to that content item. The metadata contains various information about a content item such as the display route, the edit route, and also the Identity. All these properties are populated from the content handler by the `GetContentItemMetadata` method. Now when we export we should get something like this:

    <CurrentEventSettingsPart ContentId="/alias=my-event/Identifier=8aead476c03e4e56b554da515069b261" />

The *Identifier* property here comes by adding the IdentityPart. This is worth noting because if you don't have any parts on your content type that provide an identifier (such as the AutoRoutePart) it will be blank, so adding the IdentityPart is the default way to get this.

Now to import our identity and resolve the Content Id we can use the following code:

    protected override void Importing(CurrentEventSettingsPart part, ImportContentContext context) {
    	var contentId = context.Attribute(part.PartDefinition.Name, "ContentId");
    	if (contentId != null) {
    		var contentIdItem = context.GetItemFromSession(contentId);
    		if (contentIdItem != null)
    			part.ContentId = contentIdItem.Id;
    	}
    }

This is very simple and all it is doing is resolving a content Id from the identity. Orchard is actually doing quite a lot of hard work behind the scenes to make this happen. It stores a dictionary of all the identities mapped to the relevant content id it will be using for that content item. To deal with batched imports (that are run across sessions) it lumps all relevant identifiers together so that the dependencies can all be managed within the same transaction.

Orchard, full of all the cool shit.

**UPDATE**: I have actually noticed that this makes the recipe fail, although so long as settings is at the end it will complete fine, also running all the settings imports. It fails with the error

> Recipe execution with id 2b01a2d64e44473fa143539538a24c85 was cancelled because the "Settings" step failed to execute. The following exception was thrown: Input string was not in a correct format.. Refer to the error logs for more information.

Which is weird because it all seems to be working fine. I will have to dig around. 



  [1]: http://docs.orchardproject.net/Documentation/Making-a-Web-Site-Recipe
  [2]: http://arkleseizure.net/custom-tokens-in-orchard-cms
  [3]: http://weblogs.asp.net/bleroy/identity-in-orchard-import-export
