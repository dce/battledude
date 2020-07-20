module Screen
  SIDEBAR_WIDTH = 20
  BOTTOM_HEIGHT = 10

  BATTLE_SCREEN = 1
  CHARACTER_SCREEN = 2

  def Screen.screens
    {
      BATTLE_SCREEN => "Battle",
      CHARACTER_SCREEN => "Characters"
    }
  end

  def Screen.draw_sidebar(state)
    sidebar = Curses::Window.new(
      Curses.lines - BOTTOM_HEIGHT, SIDEBAR_WIDTH, 0, 0)
    sidebar.box("*", "*", "*")

    screens.each do |index, item|
      sidebar.setpos(index, 2)

      if state["current_screen"] == index
        if state["mode"] == "menu"
          sidebar.attron(Curses::A_STANDOUT)
          sidebar.addstr(item)
          sidebar.attroff(Curses::A_STANDOUT)
        else
          sidebar.addstr(item)
        end
      else
        sidebar.attron(Curses::A_DIM)
        sidebar.addstr(item)
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

  def Screen.draw_main(state)
    main = Curses::Window.new(
      Curses.lines - BOTTOM_HEIGHT, Curses.cols - SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH)
    main.box("*", "*", "*")
    main.keypad(true)

    if state["current_screen"] == 1
      draw_battle(main, state)
    end

    main
  end

  def Screen.draw_ui(state)
    draw_sidebar(state)
    draw_bottom(state)
    draw_main(state)
  end
end
