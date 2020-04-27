---
title: Modifying Orchard's Host.config file on Publish
tags:
- Orchard
date: 2016-09-01
---
We have been gradually moving things to Azure over the last year, including some of Orchard installations. Orchard plays nice with Azure and setting up Azure services like blob storage to complement your Azure deployment are surprisingly simple. You can use blob settings to store media, but also to store your app_data configuration. To store Orchard's app_data in blob storage you need to make some changes to the Host.config file, however since the solution I work from is also used to deploy to sites that use s3 and just the file system to store app_data, I thought I could make a little transform to handle this. 

Now, I deploy by publishing straight from visual studio so I will be modifying the Orchard.Web project file, but if you use the command line to build your deployment package then you will need to edit the Orchard.proj file. Just add the following ItemGroup element in the Project element, I have mine near the web.config transforms (where I copied all this from!)

    <ItemGroup>
    	<WebConfigsToTransform Include="Config\Host.config">
    	  <DestinationRelativePath>Config\Host.config</DestinationRelativePath>
    	  <Exclude>False</Exclude>
    	  <TransformFileFolder>$(TransformWebConfigIntermediateLocation)\original</TransformFileFolder>
    	  <TransformFile>Config\Host.$(DeploymentTarget).config</TransformFile>
    	  <TransformOriginalFolder>$(TransformWebConfigIntermediateLocation)\original</TransformOriginalFolder>
    	  <TransformOriginalFile>$(TransformWebConfigIntermediateLocation)\original\%(DestinationRelativePath)</TransformOriginalFile>
    	  <TransformOutputFile>$(TransformWebConfigIntermediateLocation)\transformed\%(DestinationRelativePath)</TransformOutputFile>
    	  <TransformScope>$(_PackageTempDir)\%(DestinationRelativePath)</TransformScope>
    	  <SubType>Designer</SubType>
    	</WebConfigsToTransform>
    	<None Include="Config\Host.Basic.config">
    	  <DependentUpon>Host.config</DependentUpon>
    	</None>
    	<None Include="Config\Host.s3.config">
    	  <DependentUpon>Host.config</DependentUpon>
    	</None>
    	<None Include="Config\Host.Azure.config">
    	  <DependentUpon>Host.config</DependentUpon>
    	</None>
    </ItemGroup>

Easy. It displays in the nice way with the transformer files underneath the basic one within Visual Studio. Sexy. Create your Host.Azure.config file in the Config file with this transform to change the Host.config file on publish.

    <?xml version="1.0" encoding="utf-8" ?>
    <configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
      <autofac defaultAssembly="Orchard.Framework">
        <components>
          <!-- Configure Orchard to store shell settings in Microsoft Azure Blob Storage. -->
          <component xdt:Transform="Insert" instance-scope="single-instance" type="Orchard.FileSystems.Media.ConfigurationMimeTypeProvider, Orchard.Framework" service="Orchard.FileSystems.Media.IMimeTypeProvider"></component>
          <component xdt:Transform="Insert" instance-scope="single-instance" type="Orchard.Azure.Services.Environment.Configuration.AzureBlobShellSettingsManager, Orchard.Azure" service="Orchard.Environment.Configuration.IShellSettingsManager"></component>
        </components>
      </autofac>
    
    </configuration>

Or you could just exclude the Host.config from your deployments. But is that as fun?!

As a quick note as to why we store settings in blob storage at all when Azure web apps share the same file system across instances, you cant use deployment slots. Deployment slots allow you upload code to the staging deployment slot, move it to live instantly when changes are verified as good to go. The problem here is that it is a file system swap, so you cant have any application data (media, settings etc.) on the azure file system. I'm currently only running one site (that is only in beta right now) that uses blob storage for setting, but seems to be running okay. Touch wood...