# frontends/play.py

from tic_tac_toe_ai_player.game.engine import TicTacToe
from tic_tac_toe_ai_player.game.players import RandomComputerPlayer
from tic_tac_toe_ai_player.logic.models import Mark

from console.players import ConsolePlayer
from console.renderers import ConsoleRenderer

player1 = ConsolePlayer(Mark("X"))
player2 = RandomComputerPlayer(Mark("O"))

TicTacToe(player1, player2, ConsoleRenderer()).play()
