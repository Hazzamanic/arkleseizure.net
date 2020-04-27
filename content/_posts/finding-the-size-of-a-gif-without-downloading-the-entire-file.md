---
title: Finding the size of a GIF without downloading the entire file
tags:
- GIF
- C#
date: 2017-12-14
---
In a recent project I had a large number of GIF files that I need to dynamically check the dimensions for. I didn't really want to be downloading gigs of GIFs and thanks to this incredibly detailed and insightful [breakdown][1] of the GIF format by [@EmEmEff][2], I didn't have to. 

So the key points from the article are that bytes 1-6 tell us bout the file (the first three are the signature: "GIF", the last three are the version, with "89a" being the most common). The next four bytes are what we want though, they let us know the canvas size of the image. Bytes 7 and 8 represent the width, with 9 and 10 being the height. Note that the GIF format uses little-endian, so the two bytes are reversed when we work out the width and height.

It all turned out to be horribly simple. Here is some sample code in C#.

    public Tuple<int, int> GetSize(string url) {
        var req = WebRequest.Create(url);
        req.Proxy = WebRequest.DefaultWebProxy;
        using (var response = request.GetResponse()) {
            using (var stream = response.GetResponseStream()) {
                return GetSize(stream);
            }
        }
    }
    
    private Tuple<int, int> GetSize(Stream stream) {
        var b = GetBytes(10);
        string hex = BitConverter.ToString(new byte[] { b[7], b[6] }).Replace("-", "");
        var width = Int32.Parse(hex, System.Globalization.NumberStyles.HexNumber);
        hex = BitConverter.ToString(new byte[] { b[9], b[8] }).Replace("-", "");
        var height = Int32.Parse(hex, System.Globalization.NumberStyles.HexNumber);
    
        return new Tuple<int, int>(width, height);
    }

I'm fairly sure there is a better way to get the value than converting the byte array to hexadecimal and parsing it as an int but the combination of my poor knowledge, lack of fast answers from Google and time constraints meant that this would have to do.

  [1]: http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp
  [2]: https://twitter.com/EmEmEff