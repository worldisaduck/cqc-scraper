module WebScraper
  class City
    attr_reader :name, :care_houses

    def initialize(name)
      @name = name
      @care_houses = []
    end

    def scrap
      @current_page = 1

      puts "Scraping page ##{@current_page}..."
      care_houses_raw.each { |html| binding.pry; @care_houses << WebScraper::CareHouse.new(html) }
      puts 'Done!'

      @number_of_pages[1..-1].each do |page|
        @current_page = page
        puts "Scrapping page ##{@current_page}"
        care_houses_raw.each { |html| @care_houses << WebScraper::CareHouse.new(html) }
        puts 'Done!'
      end
    end

    protected

    def care_houses_raw
      parsed_page.css('.result-item')
    end

    def parsed_page
      raw_html = HTTParty.get(uri(@current_page))
      @parsed_page = Nokogiri::HTML(raw_html)
    end

    def uri(page)
      "https://www.cqc.org.uk/search/services/care-homes?page=#{page}&location=#{URI.encode(@name)}"
    end

    def number_of_pages
      @number_of_pages ||= parsed_page.css('.pager').children.map(&:text).select { |li| li.match /\d/ }
    end
  end
end