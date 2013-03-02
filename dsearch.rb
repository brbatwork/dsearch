#!/usr/bin/env ruby
require 'whois'
require 'open-uri'
require 'optparse'
require 'thread'

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

queue = Queue.new
puts "Searching #{words.size} possible domains"
words.each { |x|
  begin
    word = x.slice(/[a-z]+#{tld}$/)
    domain = word.sub(/#{tld}$/, ".#{tld}")
	wd = [word, domain]
	queue << wd
	sleep (1/2)
  rescue SignalException => e
    STDOUT.flush
    STDERR.puts "Quitting"
    STDERR.flush
    exit
  rescue Exception => e
    STDOUT.flush
    STDERR.puts e
    STDERR.flush
  end
}

consumer = Thread.new("Whois consumer") do |name|
	until queue.empty?
		wait = [((queue.size % 10) - 10).abs, 5].min #TODO need better throttle algorthim
		#puts "Sleeping #{wait} secs"
		sleep(wait)
		wd = queue.pop
		r = Whois.whois(wd[1])
		puts "#{wd[0]} --> #{wd[1]}" if r.available?		
	end

end

consumer.join
