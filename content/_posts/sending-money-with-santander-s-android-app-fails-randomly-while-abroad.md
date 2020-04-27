---
title: Sending money with Santander's Android App fails randomly while abroad
tags:
- 
date: 2017-07-10
---
In the Santander UK android application, I've recently run into some issues sending money, receiving a message telling me to call my branch. But then I'd try again later and it would work. Random. Actually it wasn't random, just poor handling of timezones and even poorer error handling. I can't actually claim credit for discovering the issue, it was my girlfriend who clocked onto it. 

When sending money you can choose a date to send your money. This defaults to today's date. Wherever today is for you. And I'd this happens to be a date that has passed in the UK, you are trying to send money yesterday and the app breaks down and tells you to call your branch. Not very helpful. So just adjust the date to the next day to send your money and all will be well. 

And always remember that UTC is your friend. 