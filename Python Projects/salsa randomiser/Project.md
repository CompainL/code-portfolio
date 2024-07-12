# Project Overview

This personal code project focuses on creating a little software that will randomly call salsa steps.

I happen to danse salsa, and one of the main practice exercices is to danse solo on a music, and to move randomly between different steps. This exercice develops muscle memory for the steps and their transitions, and the sense of rythm. Now this is an exercice that is more interesting with a teacher, because they are the ones telling you at the last moment what step to danse, which removes the "what steps am I practicing next? Have I practiced everything?" question from your mind and lets the dancer concentrate on dancing.
This role of the teacher may be fulfilled wth a software tool that randomly picks steps from a list.

My primary goal here is to exercices my ability to define a problem by myself and to develop a software solution. 

# Problem definition
Here, the goal is to replace a teacher for a specific salsa exercice. In the basic exercice, a music will play, and the teacher says the steps the person exercicing is supposed to dance. 

We need to 
- Play music
- Call the steps at the right time relatively to the music

Calling the steps will need synchronisation to the beat. A salsa step lasts for 8 beats. The decision to dance a step or the other is most often made on steps 6, 7 or 8. So we need our software to find the beat per minute rythm, to find the first beat, and to find out when to call the next step.
Another consideration that I will take into acount is that some steps are danced once before moving to the next one (turns for example) while others might repeat (basic step, side step, cuba step...). The software will, depending on the step, pick a number of repetition that is appropriate. It will have a ceiling of 5 repetitions to avoid endless loops (which, from experience, make bad dancing).

Concerning the muscic, an efficient and ambitious solution already exists for the music: the Salsa Beat Machine. https://github.com/urish/beat-machine
Reproducing it would be a considerable task. Instead I propose the following solution: creating a script that launches with the online version and completes it. 

## Use case scenario

The use case scenario woul be the following:
- Open the sala beat machine and the software in separate windows
- Choose the BPM inside the salsa beat machine, and copy it to the software
- launch the song
- click a "go" button on the software on beat 1 of the 8 beat loop, and then start dancing on the next 1 OR let the software automatically find the beat
- read on the screen the requested step and dance it on the next 8 beat loop
- repeat until exercice is complete

## Tasks

To complete this project I need to 
- Create a visual interface which allows to: set a BPM, set a timer, launch the exercicse, display the steps
- Create a function that picks a step from a list
- Create a function that selects an appropriate number of repetitions for the step 
- Create a function that continuously picks and displays steps every 8 beats (based on BPM) for the duration of the timer. 
- Optionally: find out how to read the SalsaBeatMachine display, and synchronuste th two loops automatically for greater precision

# Testing

The project can be executed through the run.bat file. A terminal will appear and ask for the time of the session (in minutes) and the BPM.

It can also be run manually by activating the virtual environment and running the  '__main__.py' file in frontends\console and picking options.


# Conclusions

The current version of the software displays a terminal, which announces the steps as expected. The terminal is less "prety" than the GUI I originally envisionned, but it was simpler and just as efficient. Future improvement should target the BPM detection on SalsaBeatMachine to synchornise, as the current synchronisation is made by hand. 

## Main interest
