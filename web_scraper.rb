require 'httparty'
require 'nokogiri'
require 'pry'
require_relative './web_scraper/city.rb'
require_relative './web_scraper/care_house.rb'

response = HTTParty.get('https://www.cqc.org.uk/')
main_page = Nokogiri::HTML(response)

cities = main_page.at('select#edit-authority').children.map { |option| option.values.first }

threads = []

data = cities[0..1].map do |city|
  threads << Thread.new(city) do
    WebScraper::City.new(city).scrap
  end
end

threads.each(&:join)

data = threads.map(&:value)
