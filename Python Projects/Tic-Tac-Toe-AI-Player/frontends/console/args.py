# frontends/console/args.py
import argparse

from tic_tac_toe_ai_player.game.players import (
    Player,
    RandomComputerPlayer,
    MinimaxComputerPlayer,
)

from tic_tac_toe_ai_player.logic.models import Mark
from typing import NamedTuple
from .players import ConsolePlayer

PLAYER_CLASSES = {
    "human": ConsolePlayer,
    "random": RandomComputerPlayer,
    "minimax": MinimaxComputerPlayer,
}


class Args(NamedTuple):
    # The arguments for the main function. This is the format we use to
    # collect them from the parse_args function.
    player1: Player
    player2: Player
    starting_mark: Mark


def parse_args() -> Args:
    # Function that allows to parse the arguments from a console command.
    # Searches for the following arguments: type of the X player, type of the
    # O player, starting mark.
    # Inputs: Console entry
    # Output: An instance of Args
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-X",
        dest="player_x",
        choices=PLAYER_CLASSES.keys(),
        default="human",
    )
    parser.add_argument(
        "-O",
        dest="player_o",
        choices=PLAYER_CLASSES.keys(),
        default="minimax",
    )
    parser.add_argument(
        "--starting",
        dest="starting_mark",
        choices=Mark,
        type=Mark,
        default="X",
    )
    args = parser.parse_args()

    player1 = PLAYER_CLASSES[args.player_x](Mark("X"))
    player2 = PLAYER_CLASSES[args.player_o](Mark("O"))

    if args.starting_mark == "O":
        player1, player2 = player2, player1

    return Args(player1, player2, args.starting_mark)
