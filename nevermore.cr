# Usage: update_hosts [arguments]
# -v, --version                    Show the version
# -b, --basic                      Get the basic hosts file that will block Ads
# -e, --everything                 Get the hosts file that blocks fake news, gambling, porn, and social media
# -r, --reset                      Reset the hosts file
# -h, --help                       Show this help
# -d HTTPFILE, --download=HTTPFILE Download a hosts file via http or https
# -l LOCALFILE, --local=LOCALFILE  Overwrite your hosts file using a local file

# For download options, this downloads a "hosts" file to the directory that this application is running in

# Big thanks to StevenBlack for aggregating and all the great sources
# basic hosts file: "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
# everything hosts file: "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"

require "option_parser"
require "./update_hosts_functions.cr"

# paramaters
option = "basic"
version = "Version 0.1"
download_file = ""
local_file = ""
os_info = get_os

# command-line options
OptionParser.parse do |parser|
  parser.banner = "Usage: update-hosts [arguments]"
  parser.on("-v", "--version", "Show the version") do
    puts version
    exit(0)
  end
  parser.on("-b", "--basic", "Get the basic hosts file that will block Ads") { option = "basic" }
  parser.on("-e", "--everything", "Get the hosts file that blocks fake news, gambling, porn, and social media") { option = "everything" }
  parser.on("-r", "--reset", "Reset the hosts file") { option = "reset" }
  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end
  parser.on("-d HTTPFILE", "--download=HTTPFILE", "Download a hosts file via http or https") do |httpfile|
    option = "download"
    download_file = httpfile
  end
  parser.on("-l LOCALFILE", "--local=LOCALFILE", "Overwrite your hosts file using a local file") do |localfile|
    option = "local"
    local_file = localfile
  end
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

# Driver code
if ["basic", "everything", "download", "local"].includes?(option)
  get_hosts_file(option, download_file, local_file)
  #blend_hosts
  write_hosts_file(os_info)
  reset_network(os_info)
elsif option == "reset"
  write_reset_file(os_info)
  reset_network(os_info)
else
  # NA
end
