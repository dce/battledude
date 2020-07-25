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
end
