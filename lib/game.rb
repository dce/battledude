module Game
  def Game.load_state
    JSON.parse(File.read(".data/game.json"))
  end

  def Game.save_state(state)
    File.write(".data/game.json", JSON.pretty_generate(state))
  end
end
