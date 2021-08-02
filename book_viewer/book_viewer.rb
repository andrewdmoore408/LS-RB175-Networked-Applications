require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @chapter_names = File.readlines("data/toc.txt")
end

helpers do
  def html_chapter_results(chapter_nums)
    return ["<p>Sorry, no matches were found.</p>"] if chapter_nums.empty?

    chapter_links = chapter_nums.map do |num|
      "<li class=\"search-link\"><a href=\"/chapters/#{num}\">#{@chapter_names[num - 1]}</a></li>"
    end
  end

  def in_paragraphs(arr_text)
    arr_text.map do |graph|
      "<p>#{graph.gsub(/\n/, " ")}</p>"
    end.join
  end

  def matching_chapters(query)
    # load all chapter text
      # initialize empty array chapters to hold all chapters
      # each @chapter_names
        # load file into one string, add it to results array

    chapter_numbers = (1..@chapter_names.length).to_a

    chapter_texts = chapter_numbers.map do |num|
      File.read("data/chp#{num}.txt")
    end

    # initialize empty array to hold chapter indexes for those chapters whose text matches query
    # search for matches to query
      # each chapters
        # search the string for a match (regex? includes?)
          # if match found, add current index to array of chapters that match
    matching_chapter_nums = []

    chapter_texts.each_with_index do |chapter, index|
      matching_chapter_nums << (index + 1) if chapter.include?(query)
    end

    matching_chapter_nums
  end

  def search_results(query)
    matching_chapters = matching_chapters(query)

    html_chapter_results(matching_chapters)
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:chapter_num" do
  @chapter_num = params[:chapter_num].to_i
  @title = "#{@chapter_num}: #{@chapter_names[@chapter_num - 1]}"

  chapter_path = "data/chp#{@chapter_num}.txt"

  redirect "/" unless File.exist?(chapter_path)

  @raw_chapter = File.readlines(chapter_path, "\n\n")

  erb :chapter
end

get "/search" do
  @search_results = search_results(params[:query]) if params[:query]
  erb :search
end

not_found do
  redirect "/"
end
