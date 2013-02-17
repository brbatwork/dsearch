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

file = open("http://www.scrabblefinder.com/ends-with/#{options[:tld]}/")
content = file.read
words = content.scan(/\/word\/[a-z]+#{options[:tld]}/)

words.each { |x|
  begin
    domain = x.slice(/[a-z]+#{options[:tld]}$/).sub(/#{options[:tld]}$/, ".#{options[:tld]}")
    r = Whois.whois(domain)
    puts domain if r.available?
    sleep(1/2)
  rescue SignalException => e
    STDOUT.flush
    exit
  rescue Exception => e
  end
}
