import numpy as np

# a list of the steps
LIST = ["Basic Step", "In Place", "Side Step", "Cross step", "Back Step",
        "Cuban Step", "Susie Q", "Half left turn", "Right Turn", "Left Turn"]


def step_selection():
    # function that gets called outside of this file.
    step, step_id = step_choice()
    number = number_choice(step_id)
    return step, number


def step_choice():
    # function that chooses the step
    id = np.random.randint(10)
    step = LIST[id]
    return step, id


def number_choice(id):
    # function that selects the number of times the step is repeated
    if id >= 8:
        # turns are danced only once
        return 1
    elif id >= 6:
        # those steps can be danced several times in a row, but not for long
        return np.random.randint(1, 4)
    else:
        # simple steps, made for duration
        return np.random.randint(1, 6)