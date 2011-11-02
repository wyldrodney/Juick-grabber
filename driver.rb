login = ARGV[0]
password = ARGV[1]

system "curl -d 'nick=#{login}' -d 'passwd=#{password}' -c juick-cookie http://juick.com/login"

