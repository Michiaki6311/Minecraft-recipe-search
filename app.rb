require 'sinatra'
require 'json'
require 'open-uri'
require 'uri'
require 'nokogiri'

url = "http://www26.atwiki.jp/minecraft/pages/1073.html"
items = nil

get '/' do
  'Hello,World!'
end

post '/search' do
  response = ""

  j = JSON.parse(request.body.string)
  j['events'].select{|e| e['message']}.map{|e|
    if e['message']['text'] =~ /^#mr/ then
      searchword = e['message']['text'].gsub(/^#mr\s/,'')

      # parse only first time and keep items
      if !items
        doc = Nokogiri::HTML.parse(open(url), nil, "utf-8")
        items = doc.xpath("//tr").select { |tr|
          # FIXME: rowspanned item is not contained
          tr.children.filter('td').length == 3
        }.map { |tr|
          item = tr.children.filter('td')

          {
            name: item[0].text,
            image: item[1].xpath('.//img').map {|img| "http:#{img.attribute('src')}#.png" }.join("\n"),
            craft: item[2].text,
          }
        }
      end

      count = items.index {|item| item[:name] =~ /#{searchword}/ }

      response = "#{items[count][:name]}\n#{items[count][:craft]}\n#{items[count][:image]}\n" if count
    end
  }

  response.strip
end
