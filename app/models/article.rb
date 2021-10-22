class Article < ApplicationRecord
    #urls can't be blank and only allowed for Wikipedia urls

    validates :url, presence: true, uniqueness: true
    validates :url, format: URI::regexp(%w[http https])
    validates :is_wikipedia_url

    def is_wikipedia_url
        uri = URI.parse(url.downcase)
        if uri.host
            return true if uri.host.match /[a-z]{2}\.wikipedia\.org/
            errors.add(:url, "must be an article on wikipedia.org")
        end
    end
end
