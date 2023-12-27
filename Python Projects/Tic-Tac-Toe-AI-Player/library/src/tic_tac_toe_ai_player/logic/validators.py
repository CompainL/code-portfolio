# tic_tac_toe/logic/validators.py

from __future__ import annotations
from typing import TYPE_CHECKING
if TYPE_CHECKING:
    from tic_tac_toe_ai_player.logic.models import GameState, Grid, Mark
    from tic_tac_toe_ai_player.game.players import Player


from tic_tac_toe_ai_player.logic.exceptions import InvalidGameState
# from tic_tac_toe_ai_player.logic.models import Grid, Mark, GameState

import re


def validate_grid(grid: Grid) -> None:
    # Function that validates the grid
    # Input: a grid
    # Output: None. Raises error if the input is anomalous.
    if not re.match(r"^[\sXO]{9}$", grid.cells):
        raise ValueError("Must contain 9 cells of: X, O, or space")


def validate_game_state(game_state: GameState) -> None:
    # Function that validates the state of the game using the sub-functions
    # validate_number_of_marks, validate_starting_mark and validate_winner.
    # Input: GameState object, the current state of the game.
    # Output: None. The subfunctions will raise errors if there is an annomaly.
    validate_number_of_marks(game_state.grid)
    validate_starting_mark(game_state.grid, game_state.starting_mark)
    validate_winner(
        game_state.grid, game_state.starting_mark, game_state.winner
    )


def validate_number_of_marks(grid: Grid) -> None:
    # Function that checks if we have the right number of marks.
    # Input: GameState object, the current state of the game.
    # Output: None. Raises error if the input is anomalous.
    if abs(grid.x_count - grid.o_count) > 1:
        raise InvalidGameState("Wrong number of Xs and Os")


def validate_starting_mark(grid: Grid, starting_mark: Mark) -> None:
    # Function that checks if there is an anomaly between the number of marks
    # and the stated starting mark. For example, if  the declared first mark
    # is X, then there should be more Xs than Os, or at least the same number.
    # Input: the Grid and initial Mark of the current state of the game.
    # Output: None. Raises error if the input is anomalous.
    if grid.x_count > grid.o_count:
        if starting_mark != "X":
            raise InvalidGameState("Wrong starting mark")
    elif grid.o_count > grid.x_count:
        if starting_mark != "O":
            raise InvalidGameState("Wrong starting mark")


def validate_winner(
    grid: Grid, starting_mark: Mark, winner: Mark | None
) -> None:
    # Function that checks if a player won during their own turn. Verifies if
    # the winner actually won by comparing the number of marks with the number
    # of marks they should have in a winning scenario.
    # Input: the grid, starting mark and winner of the current GameState
    # Output: None. Raises error if the input is anomalous.
    if winner == "X":
        if starting_mark == "X":
            if grid.x_count <= grid.o_count:
                raise InvalidGameState("Wrong number of Xs")
        else:
            if grid.x_count != grid.o_count:
                raise InvalidGameState("Wrong number of Xs")
    elif winner == "O":
        if starting_mark == "O":
            if grid.o_count <= grid.x_count:
                raise InvalidGameState("Wrong number of Os")
        else:
            if grid.o_count != grid.x_count:
                raise InvalidGameState("Wrong number of Os")


def validate_players(player1: Player, player2: Player) -> None:
    # Function that validates if players have been assigned different marks
    # Input: Two instances of the player class
    # Output: None. Raises error if the input is anomalous.
    if player1.mark is player2.mark:
        raise ValueError("Players must use different marks")
