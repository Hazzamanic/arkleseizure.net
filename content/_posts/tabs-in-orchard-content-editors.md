---
title: Tabs in Orchard Content Editors
tags:
- Orchard
date: 2015-10-21
---
> I will update this post with a full code download shortly

So for years there has been talk about tabs in Orchard's content editors but the functionality has never appeared. I always meant to take a look at it but it was never a priority. However, we've been overhauling some of our Orchard sites lately and several editors have become pretty huge and unmanageable. So recently I took the time to tackle the issue.

The first thing I wanted to do was create a solution that didn't require me to make any additions to Orchard's core. There are smarter people than me working on this problem ([see the GitHub discussion][1]) so hopefully I will be able to replace mine with theirs at some point in the future and we have several legacy sites with hacks in the Orchard code and upgrading them drove me up the wall. I don't want to put whoever comes after me (or future me) through that. The second thing I wanted was for it to be managed from the admin panel. Using Placement.info could be a neat feature, but I only really want to utilize tabs in cases where the editor is large enough to warrant such. 

I remembered [Sebastien][2] mentioning that the placement had support for # after the zone where tabs could be defined. I had a quick look, but although this functionality is indeed built in it would need more work to actually surface it. I believe [Znowman][3] did some work on this. I took a look at his fork and decided he'd made a lot of changes that I couldn't view because Codeplex is so slow so... I gave up looking into his work. Thus, armed with the knowledge that there wasn't any code I could copy from the internet, I set to work.

> I meant to write this blog post as soon as I built the feature so it
> would all be fresh in my mind and I could astound you all with my in
> depth knowledge of Orchard's internal workings. Unfortunately, a month
> or more has gone by and I have totally forgotten what in Orchard makes
> all this tick. Instead I shall make vague, slightly unhelpful
> statements (read: guesses) about what is happening.

I started out by getting my own content edit view. I tried to create a `Content.Edit.cshtml` in the Views folder but this didn't seem to override the default view located within Orchard.Core. So I changed the Stereotype to Tabs and created a view called `Tabs.Edit.cshtml`. Hacked! Now currently editors basically only support rendering part/field editors within the Content zone. These "zones" are dynamic properties on the content editor shape that contain all the editors. Under the hood, these are basically stored within a dictionary, in a property called `Properties`. So instead of having to write @Display(Model.Content) we just want to render a shape that gets all the "zones" and renders them along with a tab for that "zone". To achieve this I've created my own custom shape within code, done by decorating it with the Shape attribute, which tells Orchard it is a shape (they don't call me Captain Obvious for nothing).

    [Shape]
    public void TabEditor(dynamic Display, dynamic Zones, TextWriter Output) {
    	// cast the dynamic properties as a zone
    	ZoneHolding x = Zones;
    	// get all the dynamic properties from their under the hood dictionary store
    	var props = x.Properties;
    	// get the content item
    	var item = (ContentItem) Zones.ContentItem;
    	// need to replace this with a way to get current tabs, for ordering
    	string[] tabs = new[] {"Content", "Extra"}'
    
    	// loop through, find each tab and render it
    	foreach (var tab in tabs) {
    		dynamic shape = props[tab];
    		if (shape == null)
    			continue;
    
    		Render(tab, shape, Display, Output);
    	}
    
    	// if there are any other zones render these too (ie. from placement)
    	foreach (var prop in props.Keys.Cast<string>().Except(tabs)) {
    		//TODO: a better solution exists probably
    		// make sure they are not Sidebar or Header
    		if (prop == "Sidebar" || prop == "Header") continue;
    		// cast as a shape to make sure it is a zone we want to render
    		var shape = props[prop];
    		if (!(shape is Shape))
    			continue;
    
    		Render(prop, shape, Display, Output);
    	}
    }
    
    /// <summary>
    /// Renders the specified tab and the tab HTML
    /// </summary>
    /// <param name="tab">The tab.</param>
    /// <param name="shape">The shape.</param>
    /// <param name="Display">The display.</param>
    /// <param name="Output">The output.</param>
    public void Render(string tab, dynamic shape, dynamic Display, TextWriter Output) {
    	Output.Write("<h3>" + tab + "</h3><section>");
    	foreach (var item in CoreShapes.Order(shape))
    		Output.Write(Display(item));
    	Output.Write("</section>");
    }

It's pretty simple and messy code, but it works. So now we can manage tabs from our Placement.info, but ideally we'd like to do this from the admin panel. Thankfully, most of this functionality (the complicated bit) is already available in Orchard.ContentTypes. It implements its own Placement binding strategy from placements stored in the database. We just need to extend this so it supports tabs. I don't much like the way the editor for it is written, javascript messing around with inputs. The only thing I dislike more is what I replaced it with, which is just a horrible javascript mess, so I shall not go through that code. I'd be terribly embarrassed... So here are some screenshots instead:

![Tab Editor][4]
*New tab editor screen, with a Header section for content that should be displayed above the tabs*

![Create new tabs][5]
*You can create new tabs within the editor*

![Add parts to the new tab][6]
*You can drag and drop parts between tabs and within tabs for ordering. You can also delete tabs, which will copy all parts and fields within that tab into the closest tab*

Next, we need a good way to decide which content types should have tabbed editors, and of course what tabs we have so we can order them correctly in the editor. Orchard allows us to add settings to the content type itself, like so:

    public class TabSettings {
    	public bool EditorTabs { get; set; }
    }
    
    public class TabSettingsEditorEvents : ContentDefinitionEditorEventsBase {
    	public override IEnumerable<TemplateViewModel> TypeEditor(ContentTypeDefinition definition) {
    		var settings = definition.Settings.GetModel<TabSettings>();
    
    		yield return DefinitionTemplate(settings);
    	}
    
    	public override IEnumerable<TemplateViewModel> TypeEditorUpdate(ContentTypeDefinitionBuilder builder, IUpdateModel updateModel) {
    		var model = new TabSettings();
    		updateModel.TryUpdateModel(model, "TabSettings", null, null);
    
    		builder.WithSetting("TabSettings.EditorTabs", model.EditorTabs.ToString());
    
    		yield return DefinitionTemplate(model);
    	}
    } 

Now when we load the content type editor page, we should have an extra checkbox (after you've created the relevant view, of course) for whether you want tabs displayed or not. To make use of this, we'll remove the silly stereotype hack and add an alternate depending on the value of that checkbox.

    public class TabShapes : IShapeTableProvider {
    	public void Discover(ShapeTableBuilder builder) {
    		builder.Describe("Content_Edit")
    			.OnDisplaying(displaying => {
    				ContentItem contentItem = displaying.Shape.ContentItem;
    				var tabSettings = contentItem.TypeDefinition.Settings.GetModel<TabSettings>();
    				if (!tabSettings.EditorTabs)
    					return;
    
    				displaying.ShapeMetadata.Alternates.Add("Tabs_Edit");
    			});
    	}
    }

And we should probably actually render the tabs as well, for which I am using jQuery Steps, because I was already using that for a different project, however I want to change it for various reasons, mainly because it sucks for this. The Tabs.Edit.cshtml view (I couldn't be bothered to rename it so our alternate shall stay as so):

    @{
        Style.Include("tabcontrol");
        
        Script.Require("jQuery").AtFoot();
        Script.Include("jquery.steps.min.js").AtFoot();
        
        var stuff = New.TabEditor(Zones: Model);
    }
    
    
    <div class="edit-item">
        <div class="edit-item-primary">
            @Display(Model.Header)
            
            <div class="steps">
                @Display(stuff)
            </div>
    
        </div>
        <div class="edit-item-secondary group">
            @if (Model.Actions != null) {
                <div class="edit-item-actions">
                    @Display(Model.Actions)
                </div>
            }
            @if (Model.Sidebar != null) {
                <div class="edit-item-sidebar group">
                    @Display(Model.Sidebar)
                </div>
            }
        </div>
    </div>
    
    @if (!String.IsNullOrWhiteSpace(Request.QueryString["returnUrl"])) {
        @Html.Hidden("returnUrl", Request.QueryString["returnUrl"])
    }
    
    @using (Script.Foot()) {
        <script type="text/javascript">
            $(function () {
                function resizeJquerySteps() {
                    $('.steps .content').animate({ height: $('.body.current').outerHeight() + 140  }, "fast");
                }
    
                $(".steps").steps({
                    headerTag: "h3",
                    bodyTag: "section",
                    transitionEffect: "slideLeft",
                    enableFinishButton: false,
                    enablePagination: false,
                    enableAllSteps: true,
                    titleTemplate: "#title#",
                    cssClass: "tabcontrol",
                    onStepChanged: function (event, currentIndex, priorIndex) {
                        resizeJquerySteps();
                    },
                    onInit: function() {
                        resizeJquerySteps();
                        $(".steps").show();
                    }
                });
            });
        </script>
    }

I'm planning to release the code as a little module shortly (still needs a fair amount of tidying), so if you desperately want content editor tabs and cant wait until Orchard officially supports it, you can quite happily have content editor tabs.


  [1]: https://github.com/OrchardCMS/Orchard/issues/2573
  [2]: http://sebastienros.com/
  [3]: http://www.codeplex.com/site/users/view/Znowman
  [4]: /Media/Arkleseizure/Images/tabs1.PNG
  [5]: /Media/Arkleseizure/Images/tabs2.PNG
  [6]: /Media/Arkleseizure/Images/tabs3.PNG