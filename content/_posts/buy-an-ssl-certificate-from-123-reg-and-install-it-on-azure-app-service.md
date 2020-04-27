---
title: Buy an SSL certificate from 123-reg and install it on Azure App Service
tags:
- Azure
- SSL
date: 2016-10-18
---
I've done this a few times sporadically over the last few years and every time I have to do it again I forget exactly what to do. So this is a reminder for future me. Although this is in regards to 123-reg and Azure, it's pretty similar on most platforms.

So first thing you need is to order your certificate. I used 123-reg, which was pretty painless for the checkout phase. Once you've ordered your SSL certificate you can generate a CSR (a certificate signing request) and assign your certificate to a URL. When you generate a CSR ([online form here][1]), you need to put the url in (if using a wildcard then use *.myurl.com), company info and a password. It will download a zip containing your key file, the csr (in a .pem file) and password file. Keep these safe! Open the .pem file in notepad and copy the contents, then paste this into the csr field when you are issuing your SSL in the 123-reg admin. You can now download your certificate from 123-reg (although "download" to 123-reg is apparently a text field with your certificates content, so download this and save it in as certificate.cer file). 

Azure requires a .pfx file and to get that we will need OpenSSL. You can install it from the binaries [found here][2]. Once you've installed OpenSSL, open a command prompt where all your files are and run the following command:

    openssl pkcs12 -export -out certificate.pfx -inkey private-key.key -in certificate.cer

You will need to type in the password you used when generating the CSR and then ask you to create a new password. You should now have a .pfx file with a password that you can upload to Azure.

Head to your Azure dashboard and open the app service and find SSL certificates in the menu. Click Upload Certificate and select your .pfx file and enter your password. All done!

  [1]: https://www.123-reg.co.uk/secure/cpanel/ssl/generate-csr
  [2]: https://slproweb.com/products/Win32OpenSSL.html