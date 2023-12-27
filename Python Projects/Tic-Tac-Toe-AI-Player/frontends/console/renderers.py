# frontends/console/renderers.py

import textwrap
from typing import Iterable

from tic_tac_toe_ai_player.game.renderers import Renderer
from tic_tac_toe_ai_player.logic.models import GameState


class ConsoleRenderer(Renderer):
    def render(self, game_state: GameState) -> None:
        clear_screen()
        if game_state.winner:
            print_blinking(game_state.grid.cells, game_state.winning_cells)
            print(f"{game_state.winner} wins \N{party popper}")
        else:
            print_solid(game_state.grid.cells)
            if game_state.tie:
                print("No one wins this time \N{neutral face}")


def clear_screen() -> None:
    # Function that enters a command that clears the console
    print("\033c", end="")


def blink(text: str) -> str:
    # Function that makes text blink in the console.
    # Input: a text.
    # Output: a text in an expression that makes it blink.
    return f"\033[5m{text}\033[0m"


def print_solid(cells: Iterable[str]) -> None:
    # A function that prints the grid with the current content of each cell.
    # Input: the content of the cells in the form of an Iterable with 9
    # strings.
    # Output: None. Prints the grid in the console.
    print(
        textwrap.dedent(
            """\
             A   B   C
           ------------
        1 ┆  {0} │ {1} │ {2}
          ┆ ───┼───┼───
        2 ┆  {3} │ {4} │ {5}
          ┆ ───┼───┼───
        3 ┆  {6} │ {7} │ {8}
    """
        ).format(*cells)
    )


def print_blinking(cells: Iterable[str], positions: Iterable[int]) -> None:
    # Functions that prints the grid with several cells blinking. Calls the
    # blink function on the required cells and calls print_solid to display
    # the grid.
    # Input: the content of the cells in the form of an Iterable with 9
    # strings and the list of blinking cells.
    # Output: None. Calls print_solid and gets its display.
    mutable_cells = list(cells)
    for position in positions:
        mutable_cells[position] = blink(mutable_cells[position])
    print_solid(mutable_cells)
