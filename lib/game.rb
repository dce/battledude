module Game
  def Game.load_state
    JSON.parse(File.read(".data/game.json"))
  end

  def Game.save_state(state)
    File.write(".data/game.json", JSON.pretty_generate(state))
  end

  def Game.all_characters_list(state)
    monsters = monster_list(state)

    (state["players"] + state["npcs"] + monsters)
      .sort_by { |c| c["name"] }
  end

  def Game.monster_list(state)
    Api.fetch("/api/monsters").fetch("results")
  end

  def Game.character_from_api_data(data)
    {
      "name" => data["name"],
      "mhp"  => data["hit_points"],
      "chp"  => data["hit_points"],
      "ac"   => data["armor_class"],
      "api"  => data["url"]
    }
  end
end
