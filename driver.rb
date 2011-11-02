require 'nokogiri'
require 'open-uri'

login = 'wyldrodney'
#ARGV[0]
password = 'Lf,k_"ynshghfqp'
#ARGV[1]


system "rm -f juick-cookie"

system "curl -s -d 'nick=#{login}' -d 'passwd=#{password}' -c juick-cookie http://juick.com/login"

if system 'ls juick-cookie'
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



def parse(page)

	filename = '/tmp/juick-parser-' + srand.to_s

	puts "Page: #{page}"

	system "curl -s -b juick-cookie -o #{filename} --get -d 'show=my' -d 'page=#{page}'  http://juick.com/"

	until system "ls #{filename}" do
		sleep(1)
	end

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

		puts @nums.last
	end

	pagination = source.search("#content .page a").last

	if pagination.children.to_s.index('Older')

		page += 1

		if page > 10
		  puts "Done!"
			exit
		end

		parse(page)
	end

end

parse(@page)

