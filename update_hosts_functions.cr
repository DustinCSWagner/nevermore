require "http/client"

def download_hosts(uri)
  HTTP::Client.get uri do |response|
    File.open("hosts", "w") do |file|
      IO.copy response.body_io, file
    end
  end
end

def copy_rw(source, dest)
  File.open(source, "r") do |s|
    File.open(dest, "w") do |d|
      IO.copy s, d
    end
  end
end

# functions
def get_hosts_file(option, download_file, local_file)
  case option
  when "basic"
    download_hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
  when "everything"
    download_hosts "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
  when "download"
    download_hosts download_file
  when "local"
    copy_rw(local_file, "hosts")
  when "reset"
    # NA
  else
    # NA
  end
end

def get_os
  if run_proc("uname", ["-a"]) == "error"
    # linux/mac/bsd fail
    if run_proc("ver", [""]) == "error"
      # windows fail
      return "Unknown"
    else
      # Return windows version
      return run_proc("ver", [""])
    end
  else
    # Linux, Mac, or BSDs
    return run_proc("uname", ["-a"])
  end
end

def run_proc(command, a)
  stdout = IO::Memory.new
  stderr = IO::Memory.new
  begin
    mini_proc = Process.run(command, args: a, output: stdout, error: stderr)
    if mini_proc.success?
      return stdout.to_s
    else
      return stderr.to_s
    end
  rescue ex
    return "error"
  end
end

def write_hosts_file(operating_sys)
  if operating_sys.includes?("Linux")
    puts "INFO: Writing Linux hosts file"
    copy_rw("hosts", "/etc/hosts")
  elsif operating_sys.includes?("Windows")
    puts "INFO: Writing Windows hosts file"
    copy_rw("hosts", "C:\\Windows\\System32\\Drivers\\etc\\hosts")
  elsif operating_sys.includes?("Darwin")
    puts "INFO: Writing Mac hosts file"
    copy_rw("hosts", "/etc/hosts")
  elsif operating_sys.includes?("FreeBSD")
    puts "INFO: Writing BSD hosts file"
    copy_rw("hosts", "/etc/hosts")
  else
    puts "WARNING: Unrecognized OS detected, attempting to update /etc/hosts"
    copy_rw("hosts", "/etc/hosts")
  end
end

def write_reset_file(operating_sys)
  default_lin_host = "# auto-generated host file by the update-hosts utility\n" +
                     "#\n" +
                     "# hosts         This file describes a number of hostname-to-address\n" +
                     "#               mappings for the TCP/IP subsystem.  It is mostly\n" +
                     "#               used at boot time, when no name servers are running.\n" +
                     "#               On small systems, this file can be used instead of a\n" +
                     "#               \"named\" name server.\n" +
                     "# Syntax:\n" +
                     "#    \n" +
                     "# IP-Address  Full-Qualified-Hostname  Short-Hostname\n" +
                     "#\n" +
                     "\n" +
                     "127.0.0.1       localhost\n" +
                     "# fallback hostname used by NetworkManager\n" +
                     "127.0.0.1       localhost.localdomain\n" +
                     "\n" +
                     "# special IPv6 addresses\n" +
                     "::1             localhost ipv6-localhost ipv6-loopback\n" +
                     "\n" +
                     "fe00::0         ipv6-localnet\n" +
                     "\n" +
                     "ff00::0         ipv6-mcastprefix\n" +
                     "ff02::1         ipv6-allnodes\n" +
                     "ff02::2         ipv6-allrouters\n" +
                     "ff02::3         ipv6-allhosts\n"

  default_win_host = "# auto-generated host file by the update-hosts utility\n" +
                     "#\n" +
                     "# DNS should handle localhost resolution but\n" +
                     "# you can remove the comment #s below to resolve on the local computer.\n" +
                     "# 127.0.0.1 localhost\n" +
                     "# ::1 localhost"

  default_bsd_host = "# auto-generated host file by the update-hosts utility\n" +
                     "#\n" +
                     "# In the presence of the domain name service of NIS, this file may\n" +
                     "# not be consulted at all; see /etc/nsswitch.conf for the resolution order.\n" +
                     "#\n" +
                     "#\n" +
                     "::1 localhost localhost.my.domain\n" +
                     "127.0.0.1 localhost localhost.my.doman\n" +
                     "#\n"
  default_mac_host = "# auto-generated host file by the update-hosts utility\n" +
                     "127.0.0.1           localhost\n" +
                     "255.255.255.255     broadcasthost\n" +
                     "::1                 localhost\n" +
                     "fe80::1%lo0         localhost\n"

  if operating_sys.includes?("Linux")
    puts "INFO: Resetting Linux hosts file"
    File.write("/etc/hosts", default_lin_host)
  elsif operating_sys.includes?("Windows")
    puts "INFO: Resetting Windows hosts file"
    File.write("C:\\Windows\\System32\\Drivers\\etc\\hosts", default_win_host)
  elsif operating_sys.includes?("Darwin")
    puts "INFO: Resetting Mac hosts file"
    File.write("/etc/hosts", default_mac_host)
  elsif operating_sys.includes?("FreeBSD")
    puts "INFO: Resetting BSD hosts file"
    File.write("/etc/hosts", default_bsd_host)
  else
    puts "WARNING: Unrecognized OS detected, attempting to reset /etc/hosts with linux hosts file"
    # operating_sys.chars.each do |c|
    # puts "char: " + c + " unicode: " + c.unicode_escape
    # end
    File.write("/etc/hosts", default_lin_host)
  end
end

# https://askubuntu.com/questions/1031439/am-i-running-networkmanager-or-networkd
def reset_network(operating_sys)
  if operating_sys.includes?("Linux")
    puts "INFO: Resetting Linux network"
    if run_proc("systemctl", ["restart", "NetworkManager"]) == "error"         # first try
      if run_proc("systemctl", ["restart", "network"]) == "error"              # second try
        if run_proc("service", ["network-manager", "restart"]) == "error"      # third
          if run_proc("/etc/init.d/network", ["restart"]) == "error"           # fourth
            if run_proc("/etc/rc.d/rc.inet1", ["restart"]) == "error"          # fifth
              if run_proc("systemctl", ["restart", "wicd.service"]) == "error" # sixth
                if run_proc("/etc/init.d/dns-clean", ["restart"]) == "error"   # seventh
                  puts "WARNING: Failure to restart network, you may need to restart your network manually"
                else
                  puts "INFO: Success restarting network with '/etc/init.d/dns-clean restart'" # 7
                end
              else
                puts "INFO: Success restarting network with 'systemctl restart wicd.service'" # 6
              end
            else
              puts "INFO: Success restarting network with '/etc/rc.d/rc.inet1 restart'" # 5
            end
          else
            puts "INFO: Success restarting network with '/etc/init.d/network restart'" # 4
          end
        else
          puts "INFO: Success restarting network with 'service network-manager restart'" # 3
        end
      else
        puts "INFO: Success restarting network with 'systemctl restart network'" # 2
      end
    else
      puts "INFO: Success restarting network with 'systemctl restart NetworkManager'" # 1
    end
  elsif operating_sys.includes?("Windows")
    puts "INFO: Resetting Windows network"
    run_proc("ipconfig ", ["/flushdns"])
  elsif operating_sys.includes?("Darwin")
    puts "INFO: Resetting network"
    run_proc("dscacheutil", ["-flushcache"])
    run_proc("killall", ["-HUP", "mDNSResponder"])
  elsif operating_sys.includes?("FreeBSD")
    puts "INFO: Resetting network"
    run_proc("service", ["nscd", "restart"])
  else
    puts "WARNING: Unrecognized OS detected, you will need to reset your network manually if required"
    # operating_sys.chars.each do |c|
    # puts "char: " + c + " unicode: " + c.unicode_escape
    # end
  end
end
