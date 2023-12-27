# tic_tac_toe/game/engine.py

from dataclasses import dataclass
from typing import Callable, TypeAlias
from tic_tac_toe_ai_player.game.players import Player
from tic_tac_toe_ai_player.game.renderers import Renderer
from tic_tac_toe_ai_player.logic.exceptions import InvalidMove
from tic_tac_toe_ai_player.logic.models import GameState, Grid, Mark
from tic_tac_toe_ai_player.logic.validators import validate_players

ErrorHandler: TypeAlias = Callable[[Exception], None]


@dataclass(frozen=True)
class TicTacToe:
    # Class that represents the game  of tic tac toe
    player1: Player
    player2: Player
    renderer: Renderer
    error_handler: ErrorHandler | None = None

    def __post_init__(self):
        validate_players(self.player1, self.player2)

    def play(self, starting_mark: Mark = Mark("X")) -> None:
        # Function that instantiate a game of tic tac toe.
        # Creates a blank game state, and instanciates a loop that, as long as
        # the game is not over, renders the "board", finds which player has to
        # play, and allows them to make their move.
        game_state = GameState(Grid(), starting_mark)
        while True:
            self.renderer.render(game_state)
            if game_state.game_over:
                break
            player = self.get_current_player(game_state)
            try:
                game_state = player.make_move(game_state)
            except InvalidMove as ex:
                if self.error_handler:
                    self.error_handler(ex)

    def get_current_player(self, game_state: GameState) -> Player:
        # Functions that identifies the current player. Current mark was
        # already implemented in game_state, and we just have to call it in
        # the TicTacToe object.
        # Input: game instance and current state of the game
        # Output: a player
        if game_state.current_mark is self.player1.mark:
            return self.player1
        else:
            return self.player2
