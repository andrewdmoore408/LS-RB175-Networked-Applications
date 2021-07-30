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
  dice = []

  params["rolls"].to_i.times { |_| dice << (rand(params["sides"].to_i) + 1)}
  dice
end

server = TCPServer.new("localhost", 3003)

loop do
  client = server.accept

  request_line = client.gets
  next if !request_line || request_line =~ /favicon/

  puts request_line

  http_method, path, params = parse_request(request_line)

  client.puts request_line
  client.puts "Method: #{http_method}\nPath: #{path}\nParams: #{params}\n\n"

  client.puts roll_dice(params)
  client.close
end