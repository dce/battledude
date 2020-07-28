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
      case entry.last
      when "battle"
        state.merge(
          "mode" => "main",
          "current_screen" => entry.last,
          "current_char" => Util.non_null_indexes(state["battle"]).max
        )
      when "character_list"
        state.merge(
          "mode" => "main",
          "current_screen" => entry.last,
          "current_char" => 0
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
        battle = state["battle"]
        selected = state["selected_char"]

        slot = Util.null_before(battle, selected) || selected - 1

        battle = Util.swap(battle, selected, slot)

        battle.pop while battle.length > 20 && battle.last.nil?

        state.merge(
          "battle" => battle,
          "selected_char" => slot,
          "current_char" => slot
        )
      else
        c = Util.non_null_before(
          state["battle"],
          state["current_char"]
        )

        if c
          state.merge(
            "current_char" => c,
            "message" => state["battle"][c]["note"]
          )
        else
          state
        end
      end
    when Curses::KEY_UP, "k" # these move backward
      if state["selected_char"]
        battle = state["battle"]
        selected = state["selected_char"]

        slot = Util.null_after(battle, selected) || battle.length

        state.merge(
          "battle" => Util.swap(battle, selected, slot),
          "selected_char" => slot,
          "current_char" => slot
        )
      else
        c = Util.non_null_after(
          state["battle"],
          state["current_char"]
        )

        if c
          state.merge(
            "current_char" => c,
            "message" => state["battle"][c]["note"]
          )
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
          "current_char" => slot,
          "selected_char" => nil
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
      participants, state = Game.all_characters_list(state)

      state.merge(
        "current_screen" => "add_participant",
        "participant_list" => participants,
        "current_participant" => 0,
        "participant_filter" => nil
      )
    when "i"
      char = state["current_char"] &&
        state["battle"][state["current_char"]]

      if char && char["api"]
        begin
          response, cached_state = Api
            .fetch_and_cache(char["api"], state)

          cached_state.merge(
            "current_screen" => "info",
            "info" => Api.pretty(response),
            "info_offset" => nil,
            "info_pan" => nil
          )
        rescue => ex
          state.merge(
            "message" => Util.split_footer_string(ex.message)
          )
        end
      end
    end
  end

  def Input.handle_add_participant_input(input, state)
    case input
    when Curses::KEY_UP
      if state["current_participant"] > 0
        Util.dec(state, "current_participant")
      end
    when Curses::KEY_DOWN
      if state["current_participant"] < state["participant_list"].length - 1
        Util.inc(state, "current_participant")
      end
    when "\n"
      slot = Util.null_before(state["battle"], state["current_char"])

      if slot
        char = state["participant_list"][state["current_participant"]]

        if char["url"]
          data, state = Api.fetch_and_cache(char["url"], state)
          char = Game.character_from_api_data(data)
        end

        state.merge(
          "battle" => Util.set_at(state["battle"], char, slot),
          "current_screen" => "battle",
          "current_char" => slot,
          "selected_char" => nil
        )
      else
        state.merge(
          "currrent_screen" => "battle",
          "message" => "Couldn't add char"
        )
      end
    when "q"
      state.merge("current_screen" => "battle")
    when "a".."z"
      list, state = Game.all_characters_list(state)

      filter = (state["participant_filter"] || "") + input
      re = Util.search_regex(filter)
      filtered = list.filter { |c| c["name"] =~ re }

      state.merge(
        "participant_list" => filtered,
        "participant_filter" => filter,
        "current_participant" => 0
      )
    when Curses::KEY_BACKSPACE, Util.ord_eq?(127)
      list, state = Game.all_characters_list(state)

      filter = (state["participant_filter"] || "")[0..-2]
      re = Util.search_regex(filter)
      filtered = list.filter { |c| c["name"] =~ re }

      state.merge(
        "participant_list" => filtered,
        "participant_filter" => filter,
        "current_participant" => 0
      )
    when " "
      page_size = Curses.lines - Screen::BOTTOM_HEIGHT - 4

      char = [
        state["current_participant"] + page_size,
        state["participant_list"].length - 1
      ].min

      state.merge("current_participant" => char)
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
        "message" => Util.split_footer_string(
          "Rolling #{ state["roll_dice"] }: #{result}"
        )
      )
    when Curses::KEY_BACKSPACE, Util.ord_eq?(127)
      state.merge("roll_dice" => state["roll_dice"][0..-2])
    when "q"
      state.merge("mode" => "main")
    else
      state
    end
  end

  def Input.handle_info_input(input, state)
    height = Curses.lines - Screen::BOTTOM_HEIGHT - 2

    case input
    when Curses::KEY_DOWN, "j"
      if state["info_offset"]
        if state["info_offset"] < state["info"].length - height
          Util.inc(state, "info_offset")
        end
      else
        state.merge("info_offset" => 1)
      end
    when Curses::KEY_UP, "k"
      if state["info_offset"] && state["info_offset"] > 0
        Util.dec(state, "info_offset")
      else
        state.merge("info_offset" => 0)
      end
    when Curses::KEY_RIGHT, "l"
      if state["info_pan"]
        Util.inc(state, "info_pan", 10)
      else
        state.merge("info_pan" => 10)
      end
    when Curses::KEY_LEFT, "h"
      if state["info_pan"] && state["info_pan"] > 0
        Util.dec(state, "info_pan", 10)
      end
    when " "
      new_offset = [
        (state["info_offset"] || 0) + height - 1,
        state["info"].length - height
      ].min

      state.merge("info_offset" => new_offset)
    when "q"
      state.merge("current_screen" => "battle")
    end
  end

  def Input.handle_character_list_input(input, state)
    current = state["current_char"]

    case input
    when Curses::KEY_DOWN, "j"
      if current < state["players"].count - 1
        Util.inc(state, "current_char")
      end
    when Curses::KEY_UP, "k"
      if current > 0
        Util.dec(state, "current_char")
      end
    when Curses::KEY_LEFT, "h"
      state.merge(
        "mode" => "menu",
        "current_char" => nil
      )
    when "\n"
      state.merge(
        "current_screen" => "character_edit",
        "current_field" => 0
      )
    end
  end

  def Input.handle_character_edit_input(input, state)
    case input
    when /a-zA-Z0-9/
      char = state["players"][i] # state["char_being_edited"] or something
      field = Game.character_fields[state["current_field"]]
        
      # do some work
      # this isn't really going to work -- we don't want to edit
      # the player in real-time -- need to submit + parse
      
      state.merge(
        "players" => Util.set_at(state["players"], char, i)
      )
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
      when "info"
        handle_info_input(input, state)
      when "character_list"
        handle_character_list_input(input, state)
      when "character_edit"
        handle_character_edit_input(input, state)
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
      state.merge(
        "message" =>
        [
          "Unrecognized key: #{ input.inspect }",
          ("(#{ input.ord })" unless input == "")
        ].compact.join(" ")
      )
    end
  end
end
