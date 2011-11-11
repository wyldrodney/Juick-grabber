#!/usr/bin/ruby

require 'nokogiri'
require 'open-uri'
require 'csv'
require 'shellwords'


print "Enter login: "
login = gets

print "Enter password: "
system "stty -echo"
password = $stdin.gets.chomp
system "stty echo"

print "\nEnter pasges count (skip if you want all pages): "
@last_page = gets.to_i || 0


system "rm -f juick-cookies*"

system "wget -q --post-data='nick=#{login}&passwd=#{password}' --save-cookies=juick-cookies http://juick.com/login -O /dev/null"

if system 'ls juick-cookies'
	puts "Authorized."
else
	puts "Auth failed."
	exit
end


@nicks = []
@tags = []
@texts = []
@nums = []
@page = 1



def write_to_file
	CSV.open("output.csv", "wb") do |row|
		@nicks.count.times do |i|
			row << [@nicks[i], @tags[i], @texts[i], @nums[i]]
		end
	end

	system "rm -f juick-cookies"
	exit
end



def parse

	filename = '/tmp/juick-parser-' + srand.to_s

	system "wget -q --load-cookies=juick-cookies --post-data='show=my&page=#{@page}' -O #{filename} http://juick.com/"

	source = Nokogiri::HTML(open(filename), nil, 'UTF-8')
	system "rm -f #{filename}"


	source.search("#content .liav .msg").each do |message|

		@nicks << message.search("big a[1]").children.to_s

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

		@tags << tags

		@texts << message.search(".msgtxt").children.to_s

		@nums << message.search(".msgnum a").children.to_s
	end

	pagination = source.search("#content .page a").last

	if pagination.children.to_s.index('Older')

		@page += 1

		if @page == @last_page
			write_to_file
		else
			parse
		end
	end

end

parse

