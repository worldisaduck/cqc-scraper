module WebScraper
  class City
    attr_reader :city, :care_houses

    def initialize(city)
      @city = city
      @care_houses = []
    end

    def scrap
      parse_page(0)

      @care_houses = @care_houses.map { |house| house.value }
      self
    end

    protected

    def parse_page(page_num)
      return if page_num.nil?
      parsed_page = Nokogiri::HTML(HTTParty.get(uri(page_num)))

      return if parsed_page.at("h2:contains(\"Still can't find what you want?\")")

      care_houses = parsed_page.css('.result-item')
      
      puts '* ' * 25
      puts "Scrapping page ##{page_num + 1} of city - #{city}"
      puts "#{'* ' * 25}\n\n"
      
      threads = []

      care_houses.each do |html|
        threads << Thread.new(html) do |html|
          begin
            parsed_data = WebScraper::CareHouse.new(html)
            puts "#{parsed_data.name} is finished."
            
            parsed_data
          rescue Net::OpenTimeout
            next
          end
        end 
      end
      
      @care_houses = (@care_houses << threads.each(&:join)).flatten

      puts "Page is finished!\n\n"

      parse_page(next_page_num(parsed_page))
    end

    def next_page_num(page_html)
      pagination = page_html.css('.pager')
      
      current_page = pagination.css('.pager__item--current').text.to_i - 1
      last_page = pagination.css('li')[-1].text.to_i

      current_page != 0 && current_page == last_page ? nil : current_page + 1
    end

    def uri(page_num)
      "https://www.cqc.org.uk/search/services/care-homes?page=#{page_num}&location=#{URI.encode(city)}"
    end
  end
end