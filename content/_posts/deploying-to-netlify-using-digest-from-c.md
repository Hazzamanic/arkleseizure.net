---
title: Deploying to Netlify using files digest from C#
tags:
- c#
- netlify
date: 2018-01-09
---
Netlify offers two ways of uploading your files, via zip or using files digest. Files digest is the recommended way because it checks for existing files and only uploads new or changed files, saving bandwidth and time. I struggled a bit with Netlify's API. Their documentation isn't particularly great and once a few things aren't quite correct you start to doubt everything, so I was going mad trying to fix the final bug second guessing everything in the docs, digging into their node library. Turns out, as always, a typo. I'm bad. So here it is, upload files via digest from C#.

    public class Netlify {
        private static string Api = "https://api.netlify.com/api/v1/";
        private readonly string _access_token;

        public Netlify(string access_token) {
            _access_token = access_token;
        }

        public bool Deploy(string siteId, string folderPath) {
            var files = Directory.EnumerateFiles(folderPath, "*.*", SearchOption.AllDirectories);
            var hashes = new Dictionary<string, string>();
            foreach(var f in files) {
                if(!File.Exists(f)) {
                    continue;
                }

                using(var s = File.OpenRead(f)) {
                    using (var cryptoProvider = new SHA1CryptoServiceProvider()) {
                        var hash = BitConverter.ToString(cryptoProvider.ComputeHash(s));
                        var file = f.Replace(folderPath, String.Empty);
                        hashes.Add(file.Replace('\\', '/'), hash.Replace("-", String.Empty).ToLowerInvariant());
                    }
                }
            }

            var json = JsonConvert.SerializeObject(new { files = hashes, draft = false });
            var client = new WebClient();
            //client.Credentials = new NetworkCredential(_access_token, "");
            client.Headers.Add("Authorization", "Bearer " + _access_token);
            client.Headers.Add("Content-Type", "application/json");
            string response;
            try {
                response = client.UploadString(Api + "sites/" + siteId + "/deploys", "POST", json);
            }
            catch (WebException ex) {
                client.Dispose();
                return false;
            }

            var deployment = JsonConvert.DeserializeObject<Deployment>(response);
            foreach(var hash in deployment.required) {
                var fs = hashes.Where(e => e.Value == hash);
                foreach(var f in fs) {
                    var filePath = f.Key;
                    var fullPath = Path.Combine(folderPath, filePath.TrimStart('/').Replace('/', '\\'));
                    if(!File.Exists(fullPath)) {
                        continue;
                    }

                    var fileContent = File.ReadAllText(fullPath);
                    client.Headers.Add("Content-Type", "application/octet-stream");
                    try {                        
                        client.UploadFile(Api + "deploys/" + deployment.id + "/files" + filePath, "PUT", fullPath);
                    }
                    catch (WebException ex) {
                        client.Dispose();
                        return false;
                    }
                }
            }

            client.Dispose();
            return true;
        }
    }

    public class Deployment {
        public string id { get; set; }
        public string[] required { get; set; }
    }

Usage:

    var netlify = new Netlify("access_token");
    var deployment = netlify.Deploy("site_url", "directory");