class Article < ApplicationRecord
    #urls can't be blank and only allowed for Wikipedia urls

    validates :url, presence: true, uniqueness: true
    validates :url, format: URI::regexp(%w[http https])
    validate :is_wikipedia_url

    def is_wikipedia_url
        uri = URI.parse(url.downcase)
        if uri.host
            return true if uri.host.match /[a-z]{2}\.wikipedia\.org/
            errors.add(:url, "must be an article on wikipedia.org")
        end
    end

  before_save :grab_html

    def grab_html
      response = HTTParty.get(self.url)
      return if response.code != 200
      self.html = response.body
    end

    def title
      Nokogiri::HTML.parse(self.html).at('h1').text
    end

    def image
      "https:" + Nokogiri::HTML.parse(self.html).at('.infobox img, .thumb img')['srcset'].split('1.5, ').last.split(' 2x').first
    end

    def first_sentence
      Nokogiri::HTML.parse(self.html).at('.mw-parser-output > p:not(.mw-empty-elt)').text.split(".").first.gsub(/\(.*\)/, "").gsub(" ,",",")
    end

    #JSON payload to POST to Bannerbear
    def post_to_bannerbear
      return if !self.html
      payload = {
        "template": ENV['bannerbear_template_id'],
        "modifications": [
          {
            "name": "image",
            "image_url": self.image
          },
          {
            "name": "intro",
            "text": self.first_sentence
          },
          {
            "name": "title",
            "text": self.title
          }
        ]
      }
      response = HTTParty.post("https://api.bannerbear.com/v2/images",{
        body: payload,
        headers: {"Authorization" => "Bearer #{ENV['bannerbear_api_key']}"}
      })
    end

    after_commit :post_to_bannerbear
    
end
