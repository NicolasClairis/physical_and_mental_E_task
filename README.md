These scripts allow to run the physical and mental effort tasks that we used. The tasks consist in a physical and a mental effort task spread into 4 blocks, alternating between physical and mental effort with the order between physical and mental effort being counterbalanced across participants. Each task was performed in 2 blocks. Before and after each block subjects had to perform their maximal performance to assess how physical fatigue or mental learning may have impacted their maximal capacity over time.
Before the main task, each task was calibrated and trained for each individual using the main_TRAINING.m script. This consisted in the following:
Physical task
1) Calibration of maximal voluntary contraction (MVC) force
2) Training for the different difficulty levels used in the task (varying in duration from 0.5 to 4.5 s)
3) Training and familiriazition with the choice procedure and the selection between left/right options + between low/high confidence simultaneously + every time they have to perform the effort after the choice is made to understand that choices are consequential
Mental task
1) Learning of the N-back task until the performance reaches at least 6 correct answers in 4/5 consecutive trials
2) Calibration of the number of maximal correct answers (NMCA)
3) Training of the N-back task for each difficulty level used in the actual task (depending on the preceding calibration)
4) Training and familiriazition with the choice procedure and the selection between left/right options + between low/high confidence simultaneously (like for the physical task) + every time they have to perform the effort after the choice is made to understand that choices are consequential

At the end of this calibration and training, the main_TRAINING.m launches a quick indifference point measurement in the reward domain between effort level 0 (low effort option) and effort level 2 (middle level of the high effort option). This measure will subsequently serve to calibrate the amounts of money used for each task.
The order of physical vs mental will depend on the value entered in input and should be counterbalanced across subjects.

Once the calibration + training + indifference point measurement was over outside the scanner, we put subjects in the fMRI. After MRI recording, we launched the task (in the same order as the training) with the script choice_task_main.m which allows you to indicate subject name, session type (physical/mental) and block number.

Note that scripts are working for Windows 10, Matlab >=2021, Psychtoolbox 3 (http://psychtoolbox.org/), a handgrip from BioPac connected to Matlab via a National Instruments NI 9215 BNC module and a cDAQ-9171 chassis card, a 4 button curve right Fiber Optic Response Pad from Current Designs, and a 7T Siemens Magnetom scanner. Adaptations may be required to the code depending on the devices and software that you plan to use.
