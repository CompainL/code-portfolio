# tic_tac_toe/logic/models.py

import enum
from dataclasses import dataclass
import random
import re
from functools import cached_property

from tic_tac_toe_ai_player.logic.exceptions import ( 
    InvalidMove,
    UnknownGameScore
    )
from tic_tac_toe_ai_player.logic.validators import (
    validate_game_state,
    validate_grid
    )

# Patterns for winning combinations. Question marks represent the positions of
# similar Marks that trigger the player's victory.
# These are representations of the grid, using the 9 characters string of the
# Grid class.
WINNING_PATTERNS = (
    "???......",
    "...???...",
    "......???",
    "?..?..?..",
    ".?..?..?.",
    "..?..?..?",
    "?...?...?",
    "..?.?.?..",
)


class Mark(enum.StrEnum):
    # The enum to manage the Marks available to the players
    CROSS = "X"
    NAUGHT = "O"

    @property
    def other(self) -> "Mark":
        # Input: a Mark
        # Outpput: the opposite Mark
        # Use: Get the Mark of the other player
        return Mark.CROSS if self is Mark.NAUGHT else Mark.NAUGHT


@dataclass(frozen=True)
class Grid:
    # The Grid on which the players will play.
    # It actually is a string of 9 characters that gets represented
    # as a grid when displayed. Spaces represent empty cells.
    # The Grid is immutable, so we will need to create new instances
    # for each turn.
    # Display will be handled in the fontend part of the project.
    cells: str = " " * 9

    def __post_init__(self) -> None:
        # Function that uses Regex on our cells to check if they contain a
        # valid input
        # Input: string representing our grid
        # Output: raises error if the input is anomalous
        # if not re.match(r"^[\sXO]{9}$", self.cells):
        # raise ValueError("Must contain 9 cells of: X, O, or space")
        validate_grid(self)

    @cached_property
    def x_count(self) -> int:
        # Function that counts the number of X Marks
        # Input: the Cells string
        # Output: the number of occurences of X in Cells
        return self.cells.count("X")

    @cached_property
    def o_count(self) -> int:
        # Function that counts the number of O Marks
        # Input: the Cells string
        # Output: the number of occurences of O in Cells
        return self.cells.count("O")

    @cached_property
    def empty_count(self) -> int:
        # Function that counts the number cells with no Marks
        # Input: the Cells string
        # Output: the number of occurences of the empty space character in
        # the Cells string
        return self.cells.count(" ")


@dataclass(frozen=True)
class Move:
    # Class that represents a move.
    # It models what Mark is placed and in what cell.
    # Note: this is a data transfer object, which is here to carry data
    # between two processes (here two instances of the GameState class)
    mark: Mark
    cell_index: int
    before_state: "GameState"
    after_state: "GameState"


@dataclass(frozen=True)
class GameState:
    # A class that represents the state of the game at a point in time.
    # It contains the grid, but also the starting Mark. The point of knowing
    # the starting mark is to be able to find whose turn it is in case there
    # is an equal number of "X" or "O".
    # Like the grid, this is an immutable object. After each move, the game is
    # in a new state, represented by a new GameState object.
    grid: Grid
    starting_mark: Mark = Mark("X")

    def __post_init__(self) -> None:
        # Function that checks if the GameSate is valid.
        # Input: Current state of the game.
        # Output: raises error if the input is anomalous
        validate_game_state(self)

    @cached_property
    def current_mark(self) -> Mark:
        # Function that finds out who's turn it is.
        # Input: the current state of the game
        # Output: the next player to play, defined by their Mark
        if self.grid.x_count == self.grid.o_count:
            return self.starting_mark
        else:
            return self.starting_mark.other

    @cached_property
    def game_not_started(self) -> bool:
        # Function that signals that the game has not started and flags the
        # current state of the game as the initial state.
        # Input: Current state of the game
        # Output: A boolean that is True when all cells are empty and False
        # if at least one cell is occupied by a Mark.
        return self.grid.empty_count == 9

    @cached_property
    def game_over(self) -> bool:
        # Function that detects when the game is finished by identifying when
        # there is a winner or a tie.
        # Input: Current state of the game
        # Output: A boolean that is True when all cells are occupied or there
        # is a winner and False if at least one cell is not occupied by a Mark
        # and there is no winner.
        return self.winner is not None or self.tie

    @cached_property
    def tie(self) -> bool:
        # Function that detects ties and flags the current state of the game
        # as a tie.
        # Input: Current state of the game
        # Output: A boolean that is True when all cells are occupied and
        # there is no winner and False if at least one cell is not occupied by
        # a Mark or if there is a winner.
        return self.winner is None and self.grid.empty_count == 0

    @cached_property
    def winner(self) -> Mark | None:
        # Function that identifies a winner in the current state of the Game
        # and returns their Mark. Iterates over every winning pattern,
        # replaces the "?" placeholders with each marks, and checks if the
        # pattern matches the current state of the game.
        # Input: Current state of the game and global variable WINNING_PATTERNS
        # Output: the Mark of the winner
        for pattern in WINNING_PATTERNS:
            for mark in Mark:
                if re.match(pattern.replace("?", mark), self.grid.cells):
                    return mark
        return None

    @cached_property
    def winning_cells(self) -> list[int]:
        # Identifies the winning cells. Iterates over every pattern and mark.
        # When a winning pattern is encountered, identifies its cells and
        # returns their indexes (?) as a list.
        # Input: Current state of the game and global variable WINNING_PATTERNS
        # Output: a list of indexes of the winning cells.
        for pattern in WINNING_PATTERNS:
            for mark in Mark:
                if re.match(pattern.replace("?", mark), self.grid.cells):
                    return [
                        match.start()
                        for match in re.finditer(r"\?", pattern)
                    ]
        return []

    @cached_property
    def possible_moves(self) -> list[Move]:
        # Function that lists all of the possible moves for this round.
        # Input: the current state of the game
        # Output: a list of moves, in the form of cell indexes (?)
        moves = []
        if not self.game_over:
            for match in re.finditer(r"\s", self.grid.cells):
                moves.append(self.make_move_to(match.start()))
        return moves

    def make_random_move(self) -> Move | None:
        # Function that takes all possible moves from the game state and
        # returns one of them randomly.
        # Input: The current state of the game
        # Output: A move
        try:
            return random.choice(self.possible_moves)
        except IndexError:
            return None

    def make_move_to(self, index: int) -> Move:
        # Fonction that takes the current state of the game and the index of a
        # cell to make the move of the turn in that cell.
        # Input: The current state of the game and an index for the cell
        # Output: an instance of the Move class
        if self.grid.cells[index] != " ":
            raise InvalidMove("Cell is not empty")
        return Move(
            mark=self.current_mark,
            cell_index=index,
            before_state=self,
            after_state=GameState(
                Grid(
                    self.grid.cells[:index]
                    + self.current_mark
                    + self.grid.cells[index + 1:]
                ),
                self.starting_mark,
            ),
        )
    
    def evaluate_score(self, mark: Mark) -> int:
        # Function that evaluates the score of a game in a static way.
        # Input: The current state of the game and the mark of the player
        # whose score is being calculated
        # Output: The score of the player. Raises UnknownGameScore if there is
        # no score to return.
        if self.game_over:
            if self.tie:
                return 0
            if self.winner is mark:
                return 1
            else:
                return -1
        raise UnknownGameScore("Game is not over yet")
