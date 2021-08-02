require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @title = "The Adventures of Sherlock Holmes"
  @chapter_names = File.readlines("data/toc.txt")
end

get "/" do
  erb :home
end

get "/chapters/:chapter_num" do
  @chapter_num = params["chapter_num"]
  @raw_chapter = File.readlines("data/chp#{@chapter_num}.txt", "\n\n")
  @chapter_text = @raw_chapter.map { |graph| graph.gsub(/\n/, " ") }

  erb :chapter
end
