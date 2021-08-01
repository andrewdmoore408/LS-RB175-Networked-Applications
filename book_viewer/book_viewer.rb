require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

get "/" do
  @title = "Ruby Toozdei"
  @chapters = File.readlines("data/toc.txt").map do |chapter|
    chapter.gsub(/\n/, "")
  end
  # @chapters = @chapters.map { |chapter| chapter.gsub(/\n/, "") }
  erb :home
end
