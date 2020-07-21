#!/usr/bin/env ruby

require "json"
require "curses"

require "./lib/game"
require "./lib/screen"
require "./lib/input"
require "./lib/util"

Curses.init_screen

state = Game.load_state

begin
  window = Screen.draw_ui(state)
  ch = window.get_char
  state = Input.handle_input(ch, state)
end while state["exit"] != true

window.close
