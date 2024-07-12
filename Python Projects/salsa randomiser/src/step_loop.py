from step_selection import step_selection
import time
BAR_LENGTH = 8


def step_loop(beat_per_minute, duration):
    # loop function that manages the timing of steps
    bar_time = time_calculator(beat_per_minute)  # duration of a bar inseconds
    # print("bar_time =", bar_time) # control for the expected duration
    t_end = time.time() + 60 * duration  # get the time where the loop must stop
    while time.time() < t_end:
        step, bar_number = step_selection()
        print(step, " ", bar_number, " repetitions")  # shows the next step
        time.sleep(bar_time/2)  # small delay before the go to finish the previous step
        print("Go!")  # Time where the step should start
        print(bar_number*bar_time-bar_time/2, bar_time/2)
        time.sleep(bar_number*bar_time-bar_time/2 - bar_time/2)  # dance time


def time_calculator(beat_per_minute):
    # calculates the time for a full bar based on the bats per minute
    beat_per_second = beat_per_minute / (60)
    bar_time = BAR_LENGTH / beat_per_second
    print("bar time =", bar_time)  # control value for the duration of a bar
    return bar_time
