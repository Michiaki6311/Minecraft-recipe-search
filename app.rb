require 'sinatra'
require 'json'
require 'open-uri'
require 'uri'
require 'nokogiri'

get '/' do
  'Hello,World!'
end

post '/search' do
  url = "http://www26.atwiki.jp/minecraft/pages/1073.html"
  
  doc = Nokogiri::HTML.parse(open(url), nil,"utf-8")
  
  name = []
  craft = []
  image = []
  
   doc.xpath("//tr//td[@style='text-align:center;vertical-align:MIDDLE;background-color:lightblue;']").each do |item_name|
     name.push(item_name.text)
   end
    
   doc.xpath("//tr//td[@style='vertical-align:MIDDLE;']").each do |item_craft|
     craft.push(item_craft.text)
   end
   
   doc.xpath("//tr//td[@style='text-align:center;vertical-align:MIDDLE;background-color:lightgreen;']").each do |item_img|
     item_img_new = "http:#{item_img.css('img').attribute('src').value}"
     image.push(item_img_new)
   end
   
    searchword = ""
  j = JSON.parse(request.body.string)
  j['events'].select{|e| e['message']}.map{|e|
    if e['message']['text'] =~ /^#mr/ then
      searchword = e['message']['text'].gsub(/^#mr\s/,'')
    else
      searchword = ""
    end
  }
    count = name.index{|item|item =~ /#{searchword}/}
    
    puts name[count]
    puts craft[count]
    puts image[count]

end

