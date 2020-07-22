# Battlefriend

Text UI for managing DnD battles

```
****************************************************************
* Battle           **    Name           Cur HP    Max HP    AC *
* Character        ** 20 Brexalee       44        44        17 *
*                  ** 19                                       *
*                  ** 18                                       *
*                  ** 17 Johan          33        33        14 *
*                  ** 16                                       *
*                  ** 15                                       *
*                  ** 14                                       *
*                  ** 13 Graksis        33        33        17 *
*                  ** 12                                       *
*                  ** 11 Johan          33        33        14 *
*                  ** 10                                       *
*                  **  9 Kobold         5         5         12 *
*                  **  8 Kobold         5         5         12 *
*                  **  7 Kobold         5         5         12 *
*                  **  6 Kobold         5         5         12 *
*                  **  5                                       *
*                  **  4                                       *
*                  **  3 Violet         32        32        13 *
*                  **  2                                       *
*                  **  1                                       *
*                  **                                          *
*                  **                                          *
****************************************************************
****************************************************************
*                                                              *
*                                                              *
*                                                              *
***************************************************************
```

To run:

```
> gem install curses
> cp .data/game.json.example .data/game.json
> ./battlefriend.rb
```

To use the program:

* `a`: bring up add character scrren (and then `[enter]` to add)
* `s`: save the game state
* `+`/`-`: modify current hit points
* `c`: add a copy of the current character
* `[space]`: select a character to reorder (and then again to unselect)
* `q`: quit
