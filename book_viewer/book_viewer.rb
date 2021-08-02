require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @chapter_names = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(arr_text)
    arr_text.map do |graph|
      "<p>#{graph.gsub(/\n/, " ")}</p>"
    end.join
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:chapter_num" do
  @chapter_num = params["chapter_num"].to_i
  @title = "#{@chapter_num}: #{@chapter_names[@chapter_num - 1]}"

  @raw_chapter = File.readlines("data/chp#{@chapter_num}.txt", "\n\n")

  erb :chapter
end
