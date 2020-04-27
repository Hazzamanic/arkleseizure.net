---
title: Retrieving the balance transaction object when creating a charge in Stripe
tags:
- stripe
- .net
date: 2017-12-06
---
When making a post request to Stripe's REST api to create a charge, we needed to return information in the balance_transaction object. Stripe offers the ability to expand properties so you don't have to make an additional request to their api for more information, which is cool. To expand a property you add it to the request parameter `expand[]`. But when making a post request (e.g. creating a charge), I had to wrap it in square brackets like so: `[expand][]`. Here is a quick example written in C#.


    var collection = new NameValueCollection() {
        {"amount", (100).ToString("F0")},
        {"currency", "GBP"},
        {"source", token}, // using stripe connect to split a charge 
        {"destination", destination}, // using stripe connect to split a charge
        {"application_fee", (100).ToString("F0")},
        {"[expand][]", "balance_transaction" }
    };
    
    var client = new WebClient {
        Credentials = new NetworkCredential("secretKeyHere", "")
    };
    byte[] responseBytes;
    try {
        responseBytes = client.UploadValues("https://api.stripe.com/v1/charges", "POST", collection);
    } catch() {
    
    }
    var responseText = Encoding.UTF8.GetString(responseBytes);