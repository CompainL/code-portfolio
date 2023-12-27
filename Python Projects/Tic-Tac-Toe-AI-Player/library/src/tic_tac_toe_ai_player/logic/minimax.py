# tic_tac_toe/logic/minimax.py

from functools import partial

from tic_tac_toe_ai_player.logic.models import GameState, Mark, Move


def find_best_move(game_state: GameState) -> Move | None:
    # Function that finds the best move from the current state of the game.
    # Identifies a maximizer (the player who wants to find the best move) and
    # calls the minimax function on every possible move using the partial
    # factory. Then it returns the move with the highest score.
    # Input: the current state of the game.
    # Output: The move with the best score
    maximizer: Mark = game_state.current_mark
    bound_minimax = partial(minimax, maximizer=maximizer)
    return max(game_state.possible_moves, key=bound_minimax)


def minimax(
    move: Move, maximizer: Mark, choose_highest_score: bool = False
) -> int:
    # Recursive function that checks the consequences of a move. If the move
    # ends the game it returns the score for the player. If not, it calls
    # itself on every possible move efter this one and return the best
    # score that come back from the calls. In the end, it covers every
    # possible game from the current point. Since our scores are "Win", "Tie"
    # and "Lose" it means that the function will say what is the best out of
    # those three outcomes after the move. The choose_highest_score boolean
    # used to determine if the best score is the highest (player using the
    # minimax) or the lowest (oponent).
    # Input: A move, which player we are playing as (maximizer) and a boolean
    # to keep track of the future turn (choose_highest_score)
    # Output: the best score possible after the input move.
    if move.after_state.game_over:
        return move.after_state.evaluate_score(maximizer)
    return (max if choose_highest_score else min)(
        minimax(next_move, maximizer, not choose_highest_score)
        for next_move in move.after_state.possible_moves
    )

