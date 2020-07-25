require 'net/http'

module Api
  BASE = "https://www.dnd5eapi.co"

  def self.fetch(endpoint)
    JSON.pretty_generate(
      JSON.parse(
        Net::HTTP.get(URI(BASE + endpoint))
      )
    )
  end
end
