---
title: Sending JSON from a WebRequest workflow activity in Orchard CMS
tags:
- Orchard
date: 2017-07-12
---
An option for the web request workflow activity is to post your data as JSON. Cool. Unfortunately, due to [how orchard evaluates tokens prior to the workflow activity execution][2], the JSON you enter will be lost. A [question][1] on stack overflow brought this issue up, and since I have nothing else to pollute the blogosphere with I'm just rehashing my answer on here.

The fix requires no coding. Yay. Simply replace all curly braces in your JSON with double brackets. So the following JSON: 

    { test: "hello" }

Should be inputted as: 

    (( test: "hello" ))

Clearly someone discovered the issue and made a hacky fix but didn't bother updating the help text in the activity ui to reflect this hack, leaving the text telling the user to input valid JSON. 


  [1]: https://stackoverflow.com/questions/44937158/correct-json-string-format-for-the-body-request-in-a-webrequest-activity-inside
  [2]: http://arkleseizure.net/storing-json-in-orchard-workflows