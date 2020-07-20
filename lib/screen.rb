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
    sidebar.box("*", "*", "*")

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
    bottom.box("*", "*", "*")
    bottom.setpos(1, 2)
    bottom.addstr(state["message"].to_s)
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
        win.addstr(char["name"])

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
    win.attron(Curses::A_UNDERLINE)
    win.setpos(1, 2)
    win.addstr("Add Participant")
    win.attroff(Curses::A_UNDERLINE)

    state["participant_list"].each_with_index do |char, i|
      win.attron(Curses::A_STANDOUT) if state["current_participant"] == i
      win.setpos(i + 2, 2)
      win.addstr(char["name"].to_s)
      win.attroff(Curses::A_STANDOUT) if state["current_participant"] == i
    end
  end

  def Screen.draw_main(state)
    main = Curses::Window.new(
      Curses.lines - BOTTOM_HEIGHT, Curses.cols - SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH)
    main.box("*", "*", "*")
    main.keypad(true)

    case state["current_screen"]
    when "battle"
      draw_battle(main, state)
    when "add_participant"
      draw_add_participant(main, state)
    end

    main
  end

  def Screen.draw_ui(state)
    draw_sidebar(state)
    draw_bottom(state)
    draw_main(state)
  end
end
