require "sinatra"
require "sinatra/reloader"

get "/" do
  File.read "public/template.html"
  # "Sup, nurd?"
end
