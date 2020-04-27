---
title: Sending texts via Twilio in Orchard CMS
tags:
- Orchard
- Twilio
date: 2017-04-24
---
A simple Orchard CMS module for sending texts via [Twilio][1]. The module provides a workflow activity called SmsActivity that you can use to send the texts. Just two fields are required: recipients and message. Recipients is a comma separated list of phone numbers. Both fields are tokenized. You can also send texts programmatically by injecting *ITwilioService* and calling `SendSms`. Enter your Twilio settings in Settings -> Twilio.

You can get the module [here][2].


  [1]: http://twilio.com
  [2]: https://github.com/Hazzamanic/Mod.Twilio