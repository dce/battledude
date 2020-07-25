require 'net/http'

module Api
  BASE = "https://www.dnd5eapi.co"

  def self.fetch(endpoint)
    JSON.pretty_generate(
      JSON.parse(
        Net::HTTP.get(URI(BASE + endpoint))
      )
    ).split(/\n/)
  end

  def self.fetch_and_cache_info(endpoint, state)
    if state["cache"] && state["cache"][endpoint]
      state.merge("info" => state["cache"][endpoint])
    else
      info = fetch(endpoint)

      state.merge(
        "info" => info,
        "cache" => state.fetch("cache", {}).merge(endpoint => info)
      )
    end
  end
end
