# tic_tac_toe/game/renderers.py

import abc

from tic_tac_toe_ai_player.logic.models import GameState


class Renderer(metaclass=abc.ABCMeta):
    # A rendedrer class, This is an abstract interface for the library that
    # will interface with our frontend. This allows to create different
    # subclasses for different frontends while keeping a common reference for
    # these frontends.
    @abc.abstractmethod
    def render(self, game_state: GameState) -> None:
        """Render the current game state."""
