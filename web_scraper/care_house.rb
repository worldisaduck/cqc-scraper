module WebScraper
  class CareHouse
    attr_reader :raw_html

    def initialize(raw_html)
      @raw_html = raw_html
      @name,
      @address,
      @phone_number,
      @provider,
      @inspection_ratings,
      @specialisms,
      @accountable_persons
    end

    def get_data
      name = raw_html.css('.facility-name').children.first.text.strip
      address, phone_number, provider = parse_details
      inspection_ratings = parse_rating
      specialisms = parse_specialisms
      accountable_persons = parse_accountable_persons
      [name, address, phone_number, provider, inspection_ratings, specialisms, accountable_persons]
    end

    def parse_details
      details = html.css('.details').children[1].children.map { |node| node.text.strip }.reject(&:empty?)
      details.delete('Provided by:')
      details
    end

    def parse_specialisms
      html.css('.services-specialisms-list').css('ul').css('li').map { |node| node.text.strip  }
    end

    def parse_rating
      html.css('.inspection-results').css('li').each_with_object({}) do |li, hash|
        li = li.children
        hash[li.first.text.downcase.sub('-', '_').to_sym] = li.last.text.downcase.to_sym
      end 
    end

    def parse_accountable_persons
      care_house_url = html.css('h2').css('a').attribute('href').value
      care_house_page = Nokogiri::HTML HTTParty.get("https://www.cqc.org.uk#{care_house_url}")
      
      care_house_page.css('.accountable-person').css('ul').each_with_object({}) do |ul, hash|
        person_info = ul.css('li').map(&:text)
        role = person_info.last.strip.downcase.sub(' ', '_')
        name = person_info.first.strip
        hash[role] = name
      end
    end
  end
end