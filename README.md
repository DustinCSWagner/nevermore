# Nevermore
Use your computer's hosts file to block unwanted domains.

![nevermore logo](https://github.com/DustinCSWagner/nevermore/raw/main/files/logo.png)

This is an application written in [Crystal](https://crystal-lang.org) to update your PC's host file with [Stephen Black' host file](https://github.com/StevenBlack/hosts) to block Ads, etc.
You can can also specify other hosts files found on the internet, use a local copy you create yourself, or reset your hosts file back to defaults.
This then combines Stephen's host file with an additional blacklist of domains found in 'top_million_sites.txt'.
Finally, domains that match a substring in 'whitelist.txt' are removed.

# Operating System Support
There will be releases built for the following:
* Linux x64
* FreeBSD
* Mac OSX (v10.15+)
~~* Windows (v10+)~~ (Windows support is planned to be added witha later Crystal version)

Currently there is a Linux x64 binary in bin, or comile one with "shards build".


# Usage
Currently this is a command-line-interface application, there is no graphical component.

Usage: update-hosts [arguments]
*    -v,           --version                    Show the version  
*    -b,           --basic                      Get the basic hosts file that will block Ads  
*    -e,           --everything                 Get the hosts file that blocks fake news, gambling, porn, and social media  
*    -r,           --reset                      Reset the hosts file  
*    -h,           --help                       Show this help  
*    -d HTTPFILE,  --download=HTTPFILE          Download a hosts file via http or https  
*    -l LOCALFILE, --local=LOCALFILE            Overwrite your hosts file using a local file  

