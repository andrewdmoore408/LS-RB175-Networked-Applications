require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @chapter_names = File.readlines("data/toc.txt")
  @chapter_folder_path = "data/chp"
end

helpers do
  def bold_query_match(query, text)
    text.gsub(query, "<strong>#{query}</strong>")
  end

  def html_query_results(query, chapters_hash)
    html_results = []

    return html_results if chapters_hash.empty?

    # need array of hashes: :name, :num, :paragraphs (array of hashes: index-num => text)

    chapters_hash.each do |chapter_num, paragraphs|
      matching_paragraphs = []

      paragraphs.each_with_index do |graph, index|
        if graph.include?(query)
          matching_paragraphs.push( { "#{index}" => graph.gsub(/\n\n/, "").gsub(/\n/, " ") } )
        end
      end

      html_results << { name: @chapter_names[chapter_num - 1],
                        num: chapter_num,
                        paragraphs: matching_paragraphs }

      # html_results << "<ul class=\"search-result-chapter-heading\">"
      # html_results << "<li class=\"search-result-chapter-name\">#{@chapter_names[chapter_num - 1]}</li>"
      # html_results << "<ul class=\"search-result-paragraph-links-list\">"

      # paragraphs.each_with_index do |graph, index|
      #   if graph.include?(query)
      #     html_results << "<li class=\"search-result-paragraph-link\">" +
      #                     "<a href=\"/chapters/#{chapter_num}#paragraph#{index}\">#{graph.gsub(/\n/, " ")}</a>" +
      #                     "</li>"
      #   end
      # end

      # html_results << "</ul></ul>"
    end

    html_results
  end

  def in_paragraphs(arr_text)
    arr_text.map.with_index do |graph, index|
      "<p id=\"paragraph#{index}\">#{graph.gsub(/\n/, " ")}</p>"
    end
  end

  def matching_chapters(query)
    chapter_numbers = (1..@chapter_names.length).to_a

    chapter_arrays = chapter_numbers.map do |num|
      File.readlines("#{@chapter_folder_path}#{num}.txt", "\n\n")
    end

    matching_chapter_nums = []

    chapter_arrays.each_with_index do |chapter, index|
      matching_chapter_nums << (index + 1) if chapter.any? { |graph| graph.include?(query) }
    end

    results = matching_chapter_nums.each_with_object({}) do |num, hash|
                                      hash[num] = chapter_arrays[num - 1]
                                    end
    [query, results]
  end

  def search_results(query)
    query, matching_chapters = matching_chapters(query)

    html_query_results(query, matching_chapters)
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:chapter_num" do
  @chapter_num = params[:chapter_num].to_i
  @title = "#{@chapter_num}: #{@chapter_names[@chapter_num - 1]}"

  chapter_path = "#{@chapter_folder_path}#{@chapter_num}.txt"

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
