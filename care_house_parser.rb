class CareHouseParser
	attr_reader :raw_data, :page_url
	BASE_URL = "https://www.cqc.org.uk" 

	def initialize(raw_data)
		@raw_data = raw_data	
		@page_url = raw_data.css('h2').css('a').first.attributes['href'].value
		binding.pry
	end
	
	def name
		raw_data.css('.header-wrapper').css('h2').text.strip
	end

	def inspection_results
		d = raw_data.css('.inspection-results').children.each_with_object({}) do |inspection, object|
			inspection = inspection.children
			creteria = inspection[0]&.text&.downcase&.sub('-', '_')&.to_sym
			score = inspection[1]&.text&.downcase&.to_sym	
			object[creteria] = score if !creteria.nil?	
		end
	end
end
