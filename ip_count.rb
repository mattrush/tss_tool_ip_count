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
# settings
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

################
# arguments
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

format_heading('settings')
format_message("#{file_name}",'input file')

STDERR.puts('')
format_heading('progress')

lines = File.readlines(file_name)
total_lines = lines.count

total_hosts = 0
current_line = 0

lines.each do |line|
  current_line += 1

  STDERR.print(same_line) if current_line > 1
  format_notice("#{current_line}/#{total_lines}",'completed')

  network = NetAddr::IPv4Net.parse(line)

  total_hosts += network.len - 2
  format_notice("subtotal: #{network.len - 2} / total: #{total_hosts}","network: #{line.chomp}")
end

STDERR.puts('')
format_heading('total assignable addresses')

STDOUT.puts total_hosts
