---
title: Installing a wildcard renewal certificate from 123-reg into IIS
tags:
- iis
- ssl
date: 2016-09-15
---
> This is just for people who are renewing an existing certificate

When your certificate is ready to be renewed, 123-reg will email you to say your certificate is ready. You can then go to your dashboard and download your certificate. What this presents you with is a page with a text area where you can copy and paste the certificate text into a file. Save this file on your server somewhere you will remember with the extension .crt. 

On your server open IIS, and then in the section IIS open 'Server Certificates'. In the Actions pane on the right click 'Complete Certificate Request...'. This will open a window allowing you to select the file you saved earlier (you may have to select the all files options since it will by default be looking for .cer files). Fill in the Friendly Name field with your wildcard domain e.g. *.arkleseizure.net. This is important. If you have a non-wildcard domain then you can call it whatever. Click okay and it should all now be installed.