# frontends/play.py

from tic_tac_toe_ai_player.game.engine import TicTacToe
from tic_tac_toe_ai_player.game.players import RandomComputerPlayer
from tic_tac_toe_ai_player.logic.models import Mark

from console.renderers import ConsoleRenderer


# This script is a test. It creates two RandomComputerPlayers and instanciates
# a game between them.
player1 = RandomComputerPlayer(Mark("X"))
player2 = RandomComputerPlayer(Mark("O"))

TicTacToe(player1, player2, ConsoleRenderer()).play()
