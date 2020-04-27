---
title: Bulk Renaming files in Amazon S3
tags:
- Amazon S3
date: 2015-08-27
---
The problem: We are currently migrating our on demand video collection from dedicated servers to Amazon's Simple Storage Service (S3). The process has been fairly smooth, if a little laborious. However, we ran into an issue caused by the fact that S3 is case sensitive, where previously this didn't make a difference to us. 

There were quite a few things we could do to solve this particular issue, we opted to just make all the videos stored on S3 lowercase. To do this, I wrote a simple C# console app, because I'm a Microsoft junkie and not down with whatever the cool kids are using these days.

S3 doesn't allow you to rename a file, I guess because of the fact it is an object-based storage solution, so we basically have to copy the object we want to rename and assign it a modified key then delete the old object. 

First we need to create a C# console app and add the AWS S3 nuget package. Amazon recently modularised their .NET SDK into different packages for each of their different services, which is pretty neat. To find the relevant nuget package, which is stupidly hidden in nuget, search for "amazon simple storage service" and install the package with the Id "AWSSDK.S3".

    using Amazon;
    using Amazon.S3;
    using Amazon.S3.Model;
    
    namespace AmazonLowercase {
        class Program {
            private static string awsSecret = "";
            private static string awsAccess = "";
            private static string bucket = "";
            private static string folder = "";
    
    
            static void Main(string[] args)
            {
                var client = new AmazonS3Client(awsAccess, awsSecret, RegionEndpoint.EUWest1);
    
                ListObjectsRequest request = new ListObjectsRequest();
                request.BucketName = bucket;
                request.Prefix = folder;
                ListObjectsResponse response = client.ListObjects(request);
    
                foreach (S3Object o in response.S3Objects)
                {
                    var newKey = o.Key.ToLowerInvariant();
                    if (newKey == o.Key)
                        continue;
    
                    var copy = new CopyObjectRequest();
                    copy.SourceBucket = bucket;
                    copy.SourceKey = o.Key;
                    copy.DestinationBucket = bucket;
                    copy.DestinationKey = newKey;
                    client.CopyObject(copy);
    
                    //if (o.Key.EndsWith("/"))
                    //    continue;
    
                    //var delete = new DeleteObjectRequest();
                    //delete.Key = o.Key;
                    //delete.BucketName = bucket;
                    //client.DeleteObject(delete);
                }
            }
        }
    }

The code is fairly simple. If the keys are the same after you've made your adjustments, just continue, since no need to copy. You need to specify your access secret keys at the top (lazy, I know), as well as the bucket name and any folder name you want (this is treated by amazon as a prefix so you can do nested folders or beginnings of files etc.). I've commented out the delete code because I never used it in the end (the folder case was changed too so I just deleted the entire old folder in the S3 admin panel at the end). However, I tested it and it seemed to work. I had an issue where it tried to delete folder objects and something was being weird so I just made it ignore folders (they end with a slash). But yeah, you may need to test that delete bit a little more extensively.

Remember to adjust the policy of the user account you are using to allow copies and deletes etc. A total control policy will look something like this:

    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "s3:*",
                "Resource": "arn:aws:s3:::BucketNameHere/*"
            }
        ]
    }

Replace "BucketNameHere" with the name of your bucket. And there we go, simples.