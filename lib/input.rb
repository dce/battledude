module Input
  def Input.handle_menu_input(input, state)
    current = state["current_menu_item"]
    entry = Screen.menu_items[current]

    case input
    when Curses::KEY_DOWN, "j"
      if current < Screen.menu_items.count - 1
        Util.inc(state, "current_menu_item")
          .merge("current_screen" => Screen.menu_items[current + 1].last)
      end
    when Curses::KEY_UP, "k"
      if current > 0
        Util.dec(state, "current_menu_item")
          .merge("current_screen" => Screen.menu_items[current - 1].last)
      end
    when Curses::KEY_RIGHT, "l"
      if entry.last == "battle"
        state.merge(
          "mode" => "main",
          "current_screen" => entry.last,
          "current_char" => Util.non_null_indexes(state["battle"]).max
        )
      end
    end
  end

  def Input.handle_battle_input(input, state)
    case input
    when " "
      if state["selected_char"]
        state.merge("selected_char" => nil)
      else
        state.merge("selected_char" => state["current_char"])
      end
    when "-"
      chars = state["battle"].each_with_index.map do |c, i|
        if i == state["current_char"]
          Util.dec(c, "chp")
        else
          c
        end
      end

      state.merge("battle" => chars)
    when "+", "="
      chars = state["battle"].each_with_index.map do |c, i|
        if i == state["current_char"]
          Util.inc(c, "chp")
        else
          c
        end
      end

      state.merge("battle" => chars)
    when Curses::KEY_DOWN, "j" # these move backward
      if state["selected_char"] && state["selected_char"] > 0
        s = state["selected_char"]

        battle = Util.swap(state["battle"], s, s - 1)

        battle.pop while battle.length > 20 && battle.last.nil?

        Util.dec(
          Util.dec(
            state.merge("battle" => battle),
            "selected_char"
          ),
          "current_char"
        )
      else
        c = Util.non_null_indexes(state["battle"])
              .filter { |i| i < state["current_char"] }
              .max

        if c
          state.merge("current_char" => c, "message" => state["battle"][c]["note"])
        else
          state
        end
      end
    when Curses::KEY_UP, "k" # these move backward
      if state["selected_char"]
        s = state["selected_char"]

        Util.inc(
          Util.inc(
            state.merge("battle" => Util.swap(state["battle"], s, s + 1)),
            "selected_char"
          ),
          "current_char"
        )
      else
        c = Util.non_null_indexes(state["battle"])
              .filter { |i| i > state["current_char"] }
              .min

        if c
          state.merge("current_char" => c, "message" => state["battle"][c]["note"])
        else
          state
        end
      end
    when Curses::KEY_LEFT, "h"
      state.merge("mode" => "menu",
                  "current_char" => nil,
                  "selected_char" => nil)
    when "c"
      slot = Util.null_before(state["battle"], state["current_char"])

      if slot
        state.merge(
          "battle" => Util.set_at(
            state["battle"],
            state["battle"][state["current_char"]],
            slot
          ),
          "current_char" => slot
        )
      else
        state.merge("message" => "Couldn't add char")
      end
    when Curses::KEY_BACKSPACE, Util.ord_eq?(127)
      char_indexes = Util.non_null_indexes(state["battle"])

      new_index =
        char_indexes.filter { |i| i > state["current_char"] }.min ||
        char_indexes.filter { |i| i < state["current_char"] }.max

      state.merge(
        "battle" => state["battle"].map.with_index do |item, i|
          if i == state["current_char"]
            nil
          else
            item
          end
        end,
        "current_char" => new_index
      )
    when "a"
      state.merge(
        "current_screen" => "add_participant",
        "participant_list" => Game.all_characters_list(state),
        "current_participant" => 0
      )
    end
  end

  def Input.handle_add_participant_input(input, state)
    case input
    when Curses::KEY_UP, "k"
      if state["current_participant"] > 0
        Util.dec(state, "current_participant")
      end
    when Curses::KEY_DOWN, "j"
      if state["current_participant"] < state["participant_list"].length - 1
        Util.inc(state, "current_participant")
      end
    when "\n"
      slot = Util.null_before(state["battle"], state["current_char"])

      if slot
        state.merge(
          "battle" => Util.set_at(
            state["battle"],
            state["participant_list"][state["current_participant"]],
            slot
          ),
          "current_screen" => "battle",
          "current_char" => slot
        )
      else
        state.merge(
          "currrent_screen" => "battle",
          "message" => "Couldn't add char"
        )
      end
    when "q"
      state.merge("current_screen" => "battle")
    when 'a'..'z'
      pl = state["participant_list"]
      char = pl.length.times.detect { |i| pl[i]["name"].downcase.start_with?(input) }

      if char
        state.merge("current_participant" => char)
      end
    end
  end

  def Input.handle_roll_input(input, state)
    case input
    when "d", "+", "0".."9"
      state.merge("roll_dice" => state["roll_dice"] + input)
    when "\n"
      result = Util.eval_dice_string(state["roll_dice"])

      state.merge(
        "mode" => "main",
        "message" => "Rolling #{ state["roll_dice"] }: #{result}"
      )
    when Curses::KEY_BACKSPACE, Util.ord_eq?(127)
      state.merge("roll_dice" => state["roll_dice"][0..-2])
    else
      state
    end
  end

  def Input.handle_input(input, state)
    mode = state["mode"]

    case mode
    when "menu"
      handle_menu_input(input, state)
    when "main"
      case state["current_screen"]
      when "battle"
        handle_battle_input(input, state)
      when "add_participant"
        handle_add_participant_input(input, state)
      end
    when "roll"
      handle_roll_input(input, state)
    end || case input
    when 'r'
      state.merge("mode" => "roll", "roll_dice" => "")
    when 's'
      Game.save_state(state)

      state.merge("message" => "State saved (#{Time.now})")
    when 'q'
      state.merge("exit" => true)
    else
      state.merge("message" => "Unrecognized key: '#{input}'")
    end
  end
end
