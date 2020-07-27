module Screen
  SIDEBAR_WIDTH = 20
  BOTTOM_HEIGHT = 10

  def Screen.menu_items
    [
      ["Battle", "battle"],
      ["Character", "character"]
    ]
  end

  def Screen.draw_sidebar(state)
    sidebar = Curses::Window.new(
      Curses.lines - BOTTOM_HEIGHT, SIDEBAR_WIDTH, 0, 0)

    if state["mode"] == "menu"
      sidebar.box("|", "=", "+")
    else
      sidebar.box("|", "-", "+")
    end

    menu_items.each_with_index do |(name, _), index|
      sidebar.setpos(index + 1, 2)

      if state["current_menu_item"] == index
        if state["mode"] == "menu"
          sidebar.attron(Curses::A_STANDOUT)
          sidebar.addstr(name)
          sidebar.attroff(Curses::A_STANDOUT)
        else
          sidebar.addstr(name)
        end
      else
        sidebar.attron(Curses::A_DIM)
        sidebar.addstr(name)
        sidebar.attroff(Curses::A_DIM)
      end
    end

    sidebar.refresh
  end

  def Screen.draw_bottom(state)
    bottom = Curses::Window.new(
      BOTTOM_HEIGHT, Curses.cols, Curses.lines - BOTTOM_HEIGHT, 0)

    if state["mode"] == "roll"
      bottom.box("|", "=", "+")
    else
      bottom.box("|", "-", "+")
    end

    if state["mode"] == "roll"
      bottom.setpos(1, 2)
      bottom.addstr("> " + state["roll_dice"].to_s)
    else
      msgs = if state["message"].is_a?(Array)
               state["message"]
             else
               [state["message"]]
             end

      msgs.each_with_index do |msg, i|
        bottom.setpos(i + 1, 2)
        bottom.addstr(msg)
      end
    end

    bottom.refresh
  end

  def Screen.draw_battle(win, state)
    cols = {
      name: 5,
      chp: 20,
      mhp: 30,
      ac: 40
    }

    win.attron(Curses::A_UNDERLINE)
    win.setpos(1, cols[:name])
    win.addstr("Name")

    win.setpos(1, cols[:chp])
    win.addstr("Cur HP")

    win.setpos(1, cols[:mhp])
    win.addstr("Max HP")

    win.setpos(1, cols[:ac])
    win.addstr("AC")
    win.attroff(Curses::A_UNDERLINE)

    state["battle"].each_with_index do |char, i|
      line = state["battle"].length - i + 1

      win.attron(Curses::A_DIM)
      win.setpos(line, 2)
      win.addstr((i + 1).to_s.rjust(2))
      win.attroff(Curses::A_DIM)

      if char
        win.attron(Curses::A_STANDOUT) if state["current_char"] == i
        win.attron(Curses::A_UNDERLINE) if state["selected_char"] == i

        win.setpos(line, cols[:name])

        win.addstr(
          char["name"][0, cols[:chp] - cols[:name] - 1]
        )

        win.attroff(Curses::A_STANDOUT) if state["current_char"] == i
        win.attroff(Curses::A_UNDERLINE) if state["selected_char"] == i

        win.setpos(line, cols[:chp])
        win.addstr(char["chp"].to_s)

        win.setpos(line, cols[:mhp])
        win.addstr(char["mhp"].to_s)

        win.setpos(line, cols[:ac])
        win.addstr(char["ac"].to_s)
      end
    end
  end

  def Screen.draw_add_participant(win, state)
    height = Curses.lines - BOTTOM_HEIGHT - 3

    if state["current_participant"] >= height
      offset = state["current_participant"] - height + 1
    else
      offset = 0
    end

    win.attron(Curses::A_UNDERLINE)
    win.setpos(1, 2)
    win.addstr("Add Participant")
    win.attroff(Curses::A_UNDERLINE)

    state["participant_list"][offset, height].each_with_index do |char, i|
      current = state["current_participant"] - offset == i
      filter = state["participant_filter"]

      strs = if filter && filter != ""
               char["name"].split(Util.search_regex(filter))
             else
               [char["name"]]
             end

      win.setpos(i + 2, 2)

      strs.each_with_index do |str, j|
        win.attron(Curses::A_STANDOUT) if current
        win.attron(Curses::A_UNDERLINE) if j % 2 == 1
        win.addstr(str)
        win.attroff(Curses::A_UNDERLINE) if j % 2 == 1
        win.attroff(Curses::A_STANDOUT) if current
      end
    end
  end

  def Screen.draw_info(win, state)
    width = Curses.cols - SIDEBAR_WIDTH - 4
    height = Curses.lines - BOTTOM_HEIGHT - 2
    offset = state["info_offset"] || 0
    pan = state["info_pan"] || 0

    state["info"][offset, height].each_with_index do |str, i|
      win.setpos(i + 1, 2)
      win.addstr(str[pan, width])
    end
  end

  def Screen.draw_main(state)
    main = Curses::Window.new(
      Curses.lines - BOTTOM_HEIGHT, Curses.cols - SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH)

    if state["mode"] == "main"
      main.box("|", "=", "+")
    else
      main.box("|", "-", "+")
    end

    main.keypad(true)

    case state["current_screen"]
    when "battle"
      draw_battle(main, state)
    when "add_participant"
      draw_add_participant(main, state)
    when "info"
      draw_info(main, state)
    end

    main
  end

  def Screen.draw_ui(state)
    draw_sidebar(state)
    draw_bottom(state)
    draw_main(state)
  end
end
