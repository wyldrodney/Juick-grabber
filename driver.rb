require 'nokogiri'
require 'open-uri'

login = ARGV[0]
password = ARGV[1]


system "rm juick-cookie"

system "curl -d 'nick=#{login}' -d 'passwd=#{password}' -c juick-cookie http://juick.com/login"

if system 'ls juick-cookie'
	puts "Authorized."
else
	puts "Auth failed."
	exit
end


filename = srand.to_s

system "curl -b juick-cookie -o #{filename} http://juick.com/?show=my"

page = Nokogiri::HTML(open(filename), nil, 'UTF-8')

system "rm #{filename}"


page.search("#content .liav .msg").each do |message|

	nick = message.search("big a[1]").children.to_s


	tag_hash = message.search("big a")

	if tag_hash.count > 1
		tag_hash = tag_hash[1..-1]
	else
		tag_hash = []
	end


	tags = []

	tag_hash.each do |tag|
		tags << tag.children.to_s.gsub(/^\*/, '')
	end


	text = message.search(".msgtxt").children.to_s

	puts "Nick: #{nick} Tags: #{tags} Text: #{text}"
end



