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


def parse(page)

	filename = '/tmp/juick-parser-' + srand.to_s

	system 'curl -s -b juick-cookie -o ' + filename + ' http://juick.com/?show=my&page=' + page.to_s

	until system "ls #{filename}" do
		sleep(1)
	end

	source = Nokogiri::HTML(open(filename), nil, 'UTF-8')
	system "rm -f #{filename}"

	source.search("#content .liav .msg").each do |message|

		puts "Message..."

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

end

parse(11)

puts @nicks
