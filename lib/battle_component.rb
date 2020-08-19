class BattleComponent < Component
  def initial_state
    {
      "current_char" => 
        Util.non_null_indexes(props["battle"]).last,
      "selected_char" => nil
    }
  end

  add_handler " " do
    if state["selected_char"]
      set_state("selected_char", nil)
    else
      set_state("selected_char", state["current_char"])
    end
  end

  add_handler "-" do
    [[:decrement_current_hp, state["current_char"]]]
  end

  add_handler "+", "=" do
    [[:increment_current_hp, state["current_char"]]]
  end

  add_handler Curses::KEY_DOWN, "j" do
    if state["selected_char"]
      [[
        :move_character_down,
        state["current_char"],
        -> (new_index) {
          set_state("current_char", new_index)
          set_state("selected_char", new_index)
        }
      ]]
    else
      c = Util.non_null_before(
        props["battle"],
        state["current_char"]
      )
      
      if c
        set_state("current_char", c)
        note = props["battle"][c]["note"]
        [[:show_message, note]] if note
      end
    end
  end

  add_handler Curses::KEY_UP, "k" do
    if state["selected_char"]
      [[
        :move_character_up,
        state["current_char"],
        -> (new_index) {
          set_state("current_char", new_index)
          set_state("selected_char", new_index)
        }
      ]]
    else
      c = Util.non_null_after(
        props["battle"],
        state["current_char"]
      )
      
      if c
        set_state("current_char", c)
        note = props["battle"][c]["note"]
        [[:show_message, note]] if note
      end
    end
  end

  add_handler Curses::KEY_LEFT, "h" do
    [[:focus_menu]]
  end

  add_handler "c" do
    [[:clone_character, state["current_character"]]]
  end

  add_handler Curses::KEY_BACKSPACE, Util.ord_eq?(127) do
    char_indexes = Util.non_null_indexes(props["battle"])

    new_index =
      char_indexes.filter { |i| i > state["current_char"] }.min ||
      char_indexes.filter { |i| i < state["current_char"] }.max

    set_state("current_char", new_index)

    [[:delete_character, state["current_character"]]]
  end
    
  add_handler "a" do
    [[:show_add_character, state["current_character"]]]
  end

  add_handler "i" do
    [[:show_character_info, state["current_character"]]]
  end

  add_handler "n" do
    [[:edit_note, state["current_character"]]]
  end

  add_handler "g" do
    unless state["selected_char"]
      set_state(
        "current_char",
        Util.non_null_indexes(props["battle"]).last
      )
    end
  end

  add_handler "G" do
    unless state["selected_char"]
      set_state(
        "current_char",
        Util.non_null_indexes(props["battle"]).first
      )
    end
  end

  def render(window)
    cols = {
      name: 5,
      chp: 20,
      mhp: 30,
      ac: 40
    }

    window.attron(Curses::A_UNDERLINE)
    window.setpos(1, cols[:name])
    window.addstr("Name")

    window.setpos(1, cols[:chp])
    window.addstr("Cur HP")

    window.setpos(1, cols[:mhp])
    window.addstr("Max HP")

    window.setpos(1, cols[:ac])
    window.addstr("AC")
    window.attroff(Curses::A_UNDERLINE)

    state["battle"].each_with_index do |char, i|
      line = state["battle"].length - i + 1

      window.attron(Curses::A_DIM)
      window.setpos(line, 2)
      window.addstr((i + 1).to_s.rjust(2))
      window.attroff(Curses::A_DIM)

      if char
        window.attron(Curses::A_STANDOUT) if state["current_char"] == i
        window.attron(Curses::A_UNDERLINE) if state["selected_char"] == i

        window.setpos(line, cols[:name])

        window.addstr(
          char["name"][0, cols[:chp] - cols[:name] - 1]
        )

        window.attroff(Curses::A_STANDOUT) if state["current_char"] == i
        window.attroff(Curses::A_UNDERLINE) if state["selected_char"] == i

        window.setpos(line, cols[:chp])
        window.addstr(char["chp"].to_s)

        window.setpos(line, cols[:mhp])
        window.addstr(char["mhp"].to_s)

        window.setpos(line, cols[:ac])
        window.addstr(char["ac"].to_s)
      end
    end
  end
end
