from tic_tac_toe_ai_player.game.players import Player
from tic_tac_toe_ai_player.logic.exceptions import InvalidMove
from tic_tac_toe_ai_player.logic.models import GameState, Move

import re


class ConsolePlayer(Player):
    # The subclass of Player that represents a human player.
    def get_move(self, game_state: GameState) -> Move | None:
        # Function that prompts the player to make a move. As long as the game
        # is running, calls grid_to_index to prompt, gets the index of the
        # chosen cell and makes the move to that cell.
        # Input: Current State of the Game. Gets the player's cell input.
        # Output: A call of the make_move_to method with the index of the cell.
        while not game_state.game_over:
            try:
                index = grid_to_index(input(f"{self.mark}'s move: ").strip())
            except ValueError:
                print("Please provide coordinates in the form of A1 or 1A")
            else:
                try:
                    return game_state.make_move_to(index)
                except InvalidMove:
                    print("That cell is already occupied.")
        return None


def grid_to_index(grid: str) -> int:
    # Function that takes a player input with the vertical and horizontal
    # coordinates of a cell and returns the index of the corresponding cell in
    # the grid.
    # Input: a string with a letter, A, B or C, and a nuber from 1 to 3.
    # Output: A number from 1 to 9.
    if re.match(r"[abcABC][123]", grid):
        col, row = grid
    elif re.match(r"[123][abcABC]", grid):
        row, col = grid
    else:
        raise ValueError("Invalid grid coordinates")
    return 3 * (int(row) - 1) + (ord(col.upper()) - ord("A"))
