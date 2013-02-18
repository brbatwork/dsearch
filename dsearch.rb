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

words.each { |x|
  begin
    domain = x.slice(/[a-z]+#{tld}$/).sub(/#{tld}$/, ".#{tld}")
    r = Whois.whois(domain)
    puts domain if r.available?
    sleep(1/2)
  rescue SignalException => e
    STDOUT.flush
    exit
  rescue Exception => e
  end
}
