# tic_tac_toe/game/players.py

import abc
import time
from tic_tac_toe_ai_player.logic.models import GameState, Mark, Move
from tic_tac_toe_ai_player.logic.exceptions import InvalidMove
from tic_tac_toe_ai_player.logic.minimax import find_best_move


class Player(metaclass=abc.ABCMeta):
    def __init__(self, mark: Mark) -> None:
        self.mark = mark

    def make_move(self, game_state: GameState) -> GameState:
        # Function that allows the player to make a move when it their turn.
        # The function checks if its the player's turn, then uses get_move to
        # prompt the player to make a move (?). After the move has been
        # entered, it either returns a new state of the game. If there is no
        # move left for the player to play, or if it's not the player's turn,
        # raises InvalidMove.
        # Input: The players information and the state of the game.
        # Output: The state of the game after the move.
        if self.mark is game_state.current_mark:
            if move := self.get_move(game_state):
                return move.after_state
            raise InvalidMove("No more possible moves")
        else:
            raise InvalidMove("It's the other player's turn")

    @abc.abstractmethod
    def get_move(self, game_state: GameState) -> Move | None:
        # Abstract method to prompt the player to make a move. Makes room for
        # different subclasses with their own input sources, depending on an
        # AI or human player.
        # Input: the player informations and the state of the game
        # Output: A move or None if there is no move left.
        """Return the current player's move in the given game state."""


class ComputerPlayer(Player, metaclass=abc.ABCMeta):
    # Classe that extends the Player class to add a delay specific to the AI
    # players.
    def __init__(self, mark: Mark, delay_seconds: float = 0.25) -> None:
        super().__init__(mark)
        self.delay_seconds = delay_seconds

    def get_move(self, game_state: GameState) -> Move | None:
        # The overriding method with added delay
        time.sleep(self.delay_seconds)
        return self.get_computer_move(game_state)

    @abc.abstractmethod
    def get_computer_move(self, game_state: GameState) -> Move | None:
        """Return the computer's move in the given game state."""


class RandomComputerPlayer(ComputerPlayer):
    # Our first "AI" player, a naive model with random actions
    def get_computer_move(self, game_state: GameState) -> Move | None:
        # A method to call the random move from game_state. We don,t directly
        # create it here because other AI players can use random moves.
        return game_state.make_random_move()


class MinimaxComputerPlayer(ComputerPlayer):
    # A subclass of ComputerPlayer that uses the find_best_move function,
    # based on the minimax algorithm, to find the best move. Uses a random
    # move at the start of the game because minimax is not usefull at that
    # point.
    def get_computer_move(self, game_state: GameState) -> Move | None:
        if game_state.game_not_started:
            return game_state.make_random_move()
        else:
            return find_best_move(game_state)
