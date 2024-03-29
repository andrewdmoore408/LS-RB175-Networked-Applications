require 'socket'

def parse_request(line)
  url_pieces = line.split

  # get rid of HTTP version
  url_pieces.pop

  http_method, full_string = url_pieces.first, url_pieces.last

  return [http_method, full_string, nil] unless full_string =~ /\?/

  path, query_string = full_string.split('?')
  params = parse_query(query_string)

  [http_method, path, params]
end

def parse_query(string)
  queries = string.split('&')

  params = {}

  queries.each do |pair|
    name, value = pair.split('=')
    params[name] = value
  end

  params
end

def roll_dice(params)
  rolls = []

  params["rolls"].to_i.times { |_| rolls << (rand(params["sides"].to_i) + 1)}
  rolls
end

server = TCPServer.new("localhost", 3003)

loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  puts request_line

  http_method, path, params = parse_request(request_line)

  client.puts "HTTP/1.1 200 OK"
  client.puts "Content-Type: text/html"
  client.puts

  client.puts "<html>"
  client.puts "<head><meta charset=\"utf-8\"></head>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts "Method: #{http_method}\nPath: #{path}\nParams: #{params}\n\n"
  client.puts "</pre>"

  client.puts "<h1>Rolls!</h1>"

  rolls = roll_dice(params)
  rolls.each { |roll| client.puts "<p>#{roll}</p>" }

  client.puts "</body></html>"
  client.close
end