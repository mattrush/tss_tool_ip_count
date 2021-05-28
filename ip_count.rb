#!/usr/bin/env ruby

################
# meta
################

# description: return the number of assignable ip addresses (including gateways) available given a text file containing a list of networks in cidr notation
# dependencies: ruby >= 2.6.3p62 and netaddr 2.0.4 (gem install netaddr)
# contact: matt rush <matthew.rush@trustedsite.com> <m@root.dance>
# date: 04/19/2021

################
# libraries
################

require 'netaddr'

################
# data
################

same_line  = "\x1B[1A" # move cursor up one line
same_line += "\x1B[2K" # clear entire line
same_line += "\x1B[1A" # move cursor up one more line
same_line += "\x1B[2K" # clear entire line again

################
# functions
################

def usage
  STDERR.puts("usage: #{$0} input_file.txt")
end

def format_message(message,title='ok')
  STDERR.puts "[+][#{title}:][#{message}]"
end

def format_notice(message,title='ok')
  STDERR.puts "[.][#{title}:][#{message}]"
end

def format_heading(title)
  STDERR.puts "[#{title.upcase.chomp}]"
end

def is_private?(ip)
  unless ip =~ /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})$/
    raise "#{ip} is not a valid ip address"
  end

  octets = [$1,$2,$3,$4].map(&:to_i)
  raise "#{ip} is not a bad ip address" unless octets.all? { |o| o < 256 }

  (octets[0] == 10) ||
  (
    (octets[0] == 172) && (octets[1] >= 16) && (octets[1] <= 31)
  ) ||
  (
    (octets[0] == 192) && (octets[1] == 168)
  )
end

################
# parameters
################

file_name = ARGV[0]
begin
  raise ArgumentError.new("i need a file") if file_name.nil?
  rescue ArgumentError => e
    usage; exit 1
end

################
# rc
################

# init

format_heading('init')
format_message("#{file_name}",'input file')

# read in txt file

lines = File.readlines(file_name)
total_lines = lines.count
format_message(total_lines,"network count")

# find internal vs. external hosts

STDERR.puts('')
format_heading('progress')

internal_hosts = []
external_hosts = []
lines.each do |line|
  d = {}

  network = NetAddr::IPv4Net.parse(line)	# convert string to netaddr object
  ip_net_name = network.network.to_s		# get network name as string from netaddr object

  if is_private?(ip_net_name)
    network_type = "private"
  else
    network_type = "public"
  end
 
  count_tmp = network.len - 2 
 
  format_message("#{network.to_s}][#{count_tmp}","#{network_type}")



  # build d hash.

  d[:network] = network.to_s
  d[:size] = network.len - 2

  internal_hosts.push(d) if network_type == "private"
  external_hosts.push(d) if network_type == "public"
end

# summarize

STDERR.puts('')
format_heading('summary')

#   internal
internal_networks = internal_hosts.count

total_internal_hosts = 0
internal_hosts.each do |host|
  total_internal_hosts += host[:size]
end

format_message("networks: #{internal_networks}][addresses: #{total_internal_hosts}",'internal')

#   external
external_networks = external_hosts.count

total_external_hosts = 0
external_hosts.each do |host|
  total_external_hosts += host[:size]
end

format_message("networks: #{external_networks}][addresses: #{total_external_hosts}",'external')

#   combined
all_networks = internal_networks + external_networks
all_hosts = total_internal_hosts + total_external_hosts

format_message("networks: #{all_networks}][addresses: #{all_hosts}",'total')
