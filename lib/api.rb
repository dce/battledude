require 'net/http'

module Api
  BASE = "https://www.dnd5eapi.co"

  def self.fetch(endpoint)
    JSON.parse(Net::HTTP.get(URI(BASE + endpoint)))
  end

  def self.fetch_and_cache(endpoint, state)
    if state["cache"] && state["cache"][endpoint]
      [state["cache"][endpoint], state]
    else
      response = fetch(endpoint)

      cache = state
        .fetch("cache", {})
        .merge(endpoint => response)

      [response, state.merge("cache" => cache)]
    end
  end

  def self.pretty(data)
    JSON.pretty_generate(data).split(/\n/)
  end
end
