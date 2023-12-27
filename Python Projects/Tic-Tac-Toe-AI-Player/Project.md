# Project Overview

This personal code project focuses on creating a Tic-Tac-Toe game engine with an integrated AI player, drawing inspiration from the Real Python tutorial: Tic-Tac-Toe AI in Python (https://realpython.com/tic-tac-toe-ai-python/). The primary goal is to learn the process of seamlessly integrating a game engine with an artificial intelligence.

Having previously worked on a corridor game with an assigned agent function during classes at Polytechnique Montreal, I encountered a scenario where the game engine was pre-programmed by the instructor. The task was to develop an agent within the boundaries of this engine, with a predefined input and output format. However, the connection between the game and the agent was out of scope for the class. My intention for this project is to create a system and an agent and to see how they interact to learn to implement similar systems without relying on a third party to provide me with the engine and input/output format.

While working on the Tic-Tac-Toe project, I realised that the guidance provided was more detailed than I expected. In response, I opted to provide detailed comments for the code, to make sure I understood what was going on and to avoid falling prey to the trap of reproducingw without understanding.

# Testing

The project can be executed through the run.bat file. This script sets up the virtual environment, navigates to the correct directory, and initiates a game between a human player and an AI player.

It can also be run manually by activating the virtual environment and running the  '__main__.py' file in frontends\console and picking options.

Among the options, -X and -O select the player between human, random and minimax.
--starting allows to pick wether X or O starts.

# Conclusions

## Main interest

To answer my work question: To integrate artificial intelligence into the game engine, we can
- Create an object that represents the agent
- Give this object a method that takes the state of the game at time T, runs our AI algorithm on this state to determine a move, and returns the state of the game after the move.

To make this work, we need to represent our game as a succession of states, and allow the players to make moves by creating a new state.