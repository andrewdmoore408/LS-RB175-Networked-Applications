require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @chapter_names = File.readlines("data/toc.txt")

  erb :home
end

get "/chapters/:chapter_num" do
  @title = "The Adventures of Sherlock Holmes"
  @chapter_names = File.readlines("data/toc.txt")

  @chapter_num = params["chapter_num"]
  @chapter_text = File.readlines("data/chp#{@chapter_num}.txt", "\n\n").map { |graph| graph.gsub(/\n/, " ") }

  erb :chapter
end
