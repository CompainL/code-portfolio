from step_loop import step_loop


def main():
    # Initial prompts
    duration = int(input("Time: ")) 
    BPM = int(input("BPM: "))
    input("Go?") # start the exercise
    step_loop(BPM, duration)


main()
