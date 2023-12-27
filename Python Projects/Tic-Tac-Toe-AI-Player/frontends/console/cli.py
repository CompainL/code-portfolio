# frontends/console/cli.py

from tic_tac_toe_ai_player.game.engine import TicTacToe

from .args import parse_args
from .renderers import ConsoleRenderer


def main() -> None:
    # the main function for the game
    player1, player2, starting_mark = parse_args()
    TicTacToe(player1, player2, ConsoleRenderer()).play(starting_mark)
