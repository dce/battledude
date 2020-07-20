#!/usr/bin/env ruby

require "json"
require "curses"

SIDEBAR_WIDTH = 20
BOTTOM_HEIGHT = 10

BATTLE_SCREEN = 1
CHARACTER_SCREEN = 2

Curses.init_screen

def screens
  {
    BATTLE_SCREEN => "Battle",
    CHARACTER_SCREEN => "Characters"
  }
end

def inc(state, key)
  state.merge(key => state[key] + 1)
end

def dec(state, key)
  state.merge(key => state[key] - 1)
end

def draw_sidebar(state)
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

def draw_bottom(state)
  bottom = Curses::Window.new(
    BOTTOM_HEIGHT, Curses.cols, Curses.lines - BOTTOM_HEIGHT, 0)
  bottom.box("*", "*", "*")
  bottom.setpos(1, 2)
  bottom.addstr(state["message"].to_s)
  bottom.refresh
end

def draw_battle(win, state)
  win.attron(Curses::A_UNDERLINE)
  win.setpos(1, 2)
  win.addstr("Name")

  win.setpos(1, 15)
  win.addstr("Cur HP")

  win.setpos(1, 25)
  win.addstr("Max HP")

  win.setpos(1, 35)
  win.addstr("AC")
  win.attroff(Curses::A_UNDERLINE)

  state["characters"].each_with_index do |char, i|
    win.attron(Curses::A_STANDOUT) if state["current_char"] == i
    win.attron(Curses::A_UNDERLINE) if state["selected_char"] == i

    win.setpos(i + 2, 2)
    win.addstr(char["name"])

    win.attroff(Curses::A_STANDOUT) if state["current_char"] == i
    win.attroff(Curses::A_UNDERLINE) if state["selected_char"] == i

    win.setpos(i + 2, 15)
    win.addstr(char["chp"].to_s)

    win.setpos(i + 2, 25)
    win.addstr(char["mhp"].to_s)

    win.setpos(i + 2, 35)
    win.addstr(char["ac"].to_s)
  end
end

def draw_main(state)
  main = Curses::Window.new(
    Curses.lines - BOTTOM_HEIGHT, Curses.cols - SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH)
  main.box("*", "*", "*")
  main.keypad(true)

  if state["current_screen"] == 1
    draw_battle(main, state)
  end

  main
end

def draw_ui(state)
  draw_sidebar(state)
  draw_bottom(state)
  draw_main(state)
end

def save_state(state)
  File.write(".data/game.json", JSON.pretty_generate(state))
end

def handle_menu_input(input, state)
  screen = state["current_screen"]

  case input
  when Curses::KEY_DOWN, "j"
    if screen < screens.keys.max
      inc(state, "current_screen")
    end
  when Curses::KEY_UP, "k"
    if screen > 1
      dec(state, "current_screen")
    end
  when Curses::KEY_RIGHT, "l"
    if screen == BATTLE_SCREEN
      state.merge("mode" => "main", "current_char" => 0)
    end
  end
end

def handle_battle_input(input, state)
  case input
  when " "
    if state["selected_char"]
      state.merge("selected_char" => nil)
    else
      state.merge("selected_char" => state["current_char"])
    end
  when "-"
    chars = state["characters"].each_with_index.map do |c, i|
      if i == state["current_char"]
        dec(c, "chp")
      else
        c
      end
    end

    state.merge("characters" => chars)
  when "+", "="
    chars = state["characters"].each_with_index.map do |c, i|
      if i == state["current_char"]
        inc(c, "chp")
      else
        c
      end
    end

    state.merge("characters" => chars)
  when Curses::KEY_DOWN, "j"
    if state["selected_char"] && state["selected_char"] < state["characters"].length - 1
      c = state["characters"]
      s = state["selected_char"]
      c[s], c[s+1] = c[s+1], c[s]

      inc(
        inc(
          state.merge("characters" => c),
          "selected_char"
        ),
        "current_char"
      )
    elsif state["current_char"] < state["characters"].length - 1
      inc(state, "current_char")
    end
  when Curses::KEY_UP, "k"
    if state["selected_char"] && state["selected_char"] > 0
      c = state["characters"]
      s = state["selected_char"]
      c[s], c[s-1] = c[s-1], c[s]

      dec(
        dec(
          state.merge("characters" => c),
          "selected_char"
        ),
        "current_char"
      )
    elsif state["current_char"] > 0
      dec(state, "current_char")
    end
  when Curses::KEY_LEFT, "h"
    state.merge("mode" => "menu",
                "current_char" => nil,
                "selected_char" => nil)
  end
end

def handle_input(input, state)
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
    save_state(state)
    state.merge("message" => "State saved (#{Time.now})")
  else
    state.merge("message" => "Unrecognized key: '#{input}'")
  end
end

state = JSON.parse(File.read(".data/game.json"))

begin
  window = draw_ui(state)
  input = window.get_char
  state = handle_input(input, state)
end while input != 'q'

window.close
