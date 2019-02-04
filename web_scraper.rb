require 'httparty'
require 'nokogiri'
require 'pry'
require_relative './city.rb'
require_relative './care_house.rb'

BASE_URL = "https://www.cqc.org.uk" 

# 1. scrap all cities from main page
# 2. iterate trough all cities and scrap each city page
# 3. visit all pages and collect needed data
#
# City class with @page_url, @number_of_pages, @data
# Scraper class @cities and #process method

response = HTTParty.get('https://www.cqc.org.uk/')
main_page = Nokogiri::HTML(response)

cities = main_page.at('select#edit-authority').children.map { |option| option.values.first }

cities.each do |city|
  City.new(city).scrap
  binding.pry
end 

# response = HTTParty.get('https://www.cqc.org.uk/search/services/care-homes/Leicester')
# page = Nokogiri::HTML(response)

# care_houses = page.css('.result-item')

# data = care_houses.map do |raw_data|
# 	CareHouse.new(raw_data)
# end

# binding.pry



