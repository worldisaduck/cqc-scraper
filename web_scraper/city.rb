module WebScraper
  class City
    attr_reader :name, :care_houses

    def initialize(name)
      @name = name
      @care_houses = []
    end

    def scrap
      @current_page = 1
      parse_page

      @number_of_pages[1..-1].each do |page|
        @current_page = page
        parse_page
      end

      self
    end

    protected

    def parse_page
      raw_html = HTTParty.get(uri(@current_page))
      parsed_page = Nokogiri::HTML(raw_html)
      care_houses_raw = parsed_page.css('.result-item')
      
      @number_of_pages ||= parsed_page.css('.pager').children.map(&:text).select { |li| li.match /\d/ }

      puts '* ' * 25
      puts "Scrapping page ##{@current_page} of city - #{@name}"
      puts '* ' * 25
      puts ''
      
      care_houses_raw.each do |html|
        parsed_data = WebScraper::CareHouse.new(html)
        @care_houses << parsed_data
        puts "#{parsed_data.name} is finished."
      end
      puts 'Page is finished!'
      puts ''
    end

    def uri(page)
      "https://www.cqc.org.uk/search/services/care-homes?page=#{page}&location=#{URI.encode(@name)}"
    end
  end
end