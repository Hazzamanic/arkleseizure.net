---
title: Exporting enabled features in Orchard
tags:
- Orchard
date: 2015-10-16
---
**Update 16/10/2015:** [Sipke][1] has stolen my thunder and told me that this is already in Orchard's core, in the dev branch, so go check it out there!

I was surprised to discover no OOTB way to allow you to export enabled features. I'm pretty lazy and anything that makes it easier to recreate a website is a good thing in my book. So I wrote a little bit of code, a year or so ago now, to allow you to export features, hopefully I'll chuck up the code as a module or some such soon.

Orchard offers some handy extensions to the ImportExport module to make including custom export steps trivial. To register a new custom export step we just need to implement the `ICustomExportStep` event handler:

    public class FeaturesCustomExportStep : ICustomExportStep
    {
    	public void Register(IList<string> steps)
    	{
    		steps.Add("Features");
    	}
    }

Then we need to make this step actually do something by implementing the `IExportEventHandler`.

    public class FeaturesExportEventHandler : IExportEventHandler {
    	private readonly IFeatureManager _featureManager;
    	private readonly ShellDescriptor _shellDescriptor;
    
    	public FeaturesExportEventHandler(IFeatureManager featureManager, ShellDescriptor shellDescriptor)
    	{
    		_featureManager = featureManager;
    		_shellDescriptor = shellDescriptor;
    	}
    
    	public void Exporting(dynamic context) { }
    
    	public void Exported(dynamic context)
    	{
    		if (!((IEnumerable<string>)context.ExportOptions.CustomSteps).Contains("Features"))
    		{
    			return;
    		}
    
    		var features = _featureManager.GetAvailableFeatures()
    			.Where(f => !DefaultExtensionTypes.IsTheme(f.Extension.ExtensionType))
    			.Where(f => _shellDescriptor.Features.Any(sf => sf.Name == f.Id))
    			.Select(x => x.Id);
    
    		var featureString = string.Join(",", features);
    		var featureElement = new XElement("Feature");
    		context.Document.Element("Orchard").Add(featureElement);
    		featureElement.Add(new XAttribute("enable", featureString));
    	}
    }

This code is pretty simple, it just finds all features that are not themes and are active and selects the id. It then joins these in a comma separated list and adds a new Feature element to export document. The features will be exported towards the end of the xml so you may need to jig your export around if you want to use it, though I've found that is often necessary when importing and exporting in Orchard.


  [1]: https://twitter.com/sfmskywalker