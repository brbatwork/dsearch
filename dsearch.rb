#!/usr/bin/env ruby
require 'whois'
require 'open-uri'
require 'optparse'

options = {}
option_parser = OptionParser.new do |opts|
  opts.on("-s", "--suffix SUFFIX", "Top Level Domain") do |s|
    options[:tld] = s 
  end
end
option_parser.parse!

if options[:tld].nil?
  puts "Usage: dsearch.rb -s <TLD>"
  exit
end

tld = options[:tld]

file = open("http://www.scrabblefinder.com/ends-with/#{tld}/")
content = file.read
words = content.scan(/\/word\/[a-z]+#{tld}/)

puts "Searching #{words.size} possible domains"
words.each { |x|
  begin
    word = x.slice(/[a-z]+#{tld}$/)
    domain = word.sub(/#{tld}$/, ".#{tld}")
    r = Whois.whois(domain)
    puts "#{word} --> #{domain}" if r.available?
    sleep(1/2)
  rescue SignalException => e
    STDOUT.flush
    STDERR.puts "Quitting"
    STDERR.flush
    exit
  rescue Exception => e
    STDERR.puts e
    STDERR.flush
  end
}
