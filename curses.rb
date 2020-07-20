require "curses"

SIDEBAR_WIDTH = 20
BOTTOM_HEIGHT = 5

Curses.init_screen

sidebar = Curses::Window.new(
  Curses.lines - BOTTOM_HEIGHT, SIDEBAR_WIDTH, 0, 0)
sidebar.box("*", "*", "*")
sidebar.refresh

bottom = Curses::Window.new(
  BOTTOM_HEIGHT, Curses.cols, Curses.lines - BOTTOM_HEIGHT, 0)
bottom.box("*", "*", "*")
bottom.refresh

sidebar.setpos(1, 2)
sidebar.attron(Curses::A_STANDOUT)
sidebar.addstr("Menu Item #1")
sidebar.attroff(Curses::A_STANDOUT)
sidebar.setpos(2, 2)
sidebar.addstr("Menu Item #2")
sidebar.refresh

main = Curses::Window.new(
  Curses.lines - BOTTOM_HEIGHT, Curses.cols - SIDEBAR_WIDTH, 0, SIDEBAR_WIDTH)
main.box("*", "*", "*")
main.refresh

main.getch
main.close
