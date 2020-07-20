module Input
  def Input.handle_menu_input(input, state)
    screen = state["current_screen"]

    case input
    when Curses::KEY_DOWN, "j"
      if screen < Screen.screens.keys.max
        Util.inc(state, "current_screen")
      end
    when Curses::KEY_UP, "k"
      if screen > 1
        Util.dec(state, "current_screen")
      end
    when Curses::KEY_RIGHT, "l"
      if screen == Screen::BATTLE_SCREEN
        state.merge(
          "mode" => "main",
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
          state.merge("current_char" => c)
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
          state.merge("current_char" => c)
        else
          state
        end
      end
    when Curses::KEY_LEFT, "h"
      state.merge("mode" => "menu",
                  "current_char" => nil,
                  "selected_char" => nil)
    end
  end

  def Input.handle_input(input, state)
    mode = state["mode"]

    case mode
    when "menu"
      handle_menu_input(input, state)
    when "main"
      case state["current_screen"]
      when 1
        handle_battle_input(input, state)
      end
    end || case input
    when 's'
      Game.save_state(state)

      state.merge("message" => "State saved (#{Time.now})")
    else
      state.merge("message" => "Unrecognized key: '#{input}'")
    end
  end
end
