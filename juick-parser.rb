if ARGV[0] == "help"
	puts "  Type: irb1.9.1 juick-parser.rb <nick> <password> <pages>\n  Pages is optional.\n  Output file will be named `output.csv`."
	exit
end

if ARGV[0].nil?
	puts "  Type irb1.9.1 juick-parser.rb help."
	exit
end


require 'nokogiri'
require 'open-uri'
require 'csv'


login = ARGV[0]
password = ARGV[1]
@last_page = ARGV[2].to_i + 1 || 0


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



def write_to_file
	CSV.open("output.csv", "wb") do |row|
		@nicks.count.times do |i|
			row << [@nicks[i], @tags[i], @texts[i], @nums[i]]
		end
	end

	system "rm -f juick-cookie"
	exit
end



def parse

	filename = '/tmp/juick-parser-' + srand.to_s

	system "curl -s -b juick-cookie -o #{filename} --get -d 'show=my' -d 'page=#{@page}'  http://juick.com/"

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

