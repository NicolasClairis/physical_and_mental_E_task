function[onset_stim] = mental_display_stim(scr, stim,...
    startAngle, endAngle,...
    sideQuestion, taskTypeDisplay, numberValue, mental_n_col,...
    learning_instructions, maxPerfUntilNowAngle, minPerfToReachAngle, R_chosen, R_or_P)
% [onset_stim] = mental_display_stim(scr, stim,...
%     startAngle, endAngle,...
%     sideQuestion, taskTypeDisplay, numberValue, mental_n_col,...
%     learning_instructions, maxPerfUntilNowAngle, minPerfToReachAngle, R_chosen, R_or_P)
% mental_display_stim will display the arc, number to solve,
% instructions and reward level (all relevant info) according to the inputs
%
% INPUTS
% scr: screen structure with relevant info about screen
%
% stim: structure with relevant info about stimulus display
%
% startAngle, endAngle: values for the angle of the arc showing how far you
% are from reaching the end
%
% sideQuestion: structure explaining which side corresponds to which answer
% for each task (odd/even; lower/higher than 5 vs left/right)
%
% taskTypeDisplay: (0) odd/even; (1): lower/higher than 5; (2) last question (for N-back version can be ignored = 0 in white)
% (type of the question displayed on screen which determines the number colour)
%
% numberValue: number for the current question
%
% mental_n_col: structure with information about colour corresponding to
% each task type
%
% learning_instructions
% 'fullInstructions': display instructions: ask if odd/even (or lower/higher than 5) and
% display also on the screen the relevant answer to each question
% 'partialInstructions': display only the two possible answers but not the
% question anymore
% 'noInstructions': no reminder of what the question is nor of where you should answer
%
% maxPerfUntilNowAngle: for calibration, add an orange bar where the
% maximum perf has been reached until now
%
% minPerfToReachAngle: for learning and calibration, add a red bar where the
% minimal tolerated performance is located
%
% R_chosen: monetary amount (numerical) for which they play (if not empty,
% will display the amount on the screen)
%
% R_or_P: 'R' or 'P' for reward or punishment trial (if not empty,
% will display the amount on the screen)
%
% OUTPUTS
% onset_stim: time when everything appears on screen
%
% See also mental_learning.m

%% extract relevant parameters
window = scr.window;
arcCurrLevelColor = stim.difficulty.currLevelColor;
arcPosition = stim.difficulty.middle_center;

%% percentage of correct answers already provided
Screen('FillArc', window,...
    arcCurrLevelColor,...
    arcPosition,...
    startAngle,...
    endAngle - startAngle);

%% number to solve
textColor = mental_n_col.lowHigh;
% increase text size for number
Screen('TextSize', window, scr.textSize.mentalNumber);
% display number on screen
DrawFormattedText(window, num2str(numberValue),...
    stim.Em.(['numberPerf_',num2str(numberValue)]).x,...
    stim.Em.(['numberPerf_',num2str(numberValue)]).y,...
    textColor);
% text size back to baseline
Screen('TextSize', window, scr.textSize.baseline);

%% display orange bar where is the best performance until now
if exist('maxPerfUntilNowAngle','var') && ~isempty(maxPerfUntilNowAngle)
    lineColour = stim.calibBestUntilNow.color;
    circleRadius = stim.calibBestUntilNow.circleRadius;
    xCircleCenter = stim.calibBestUntilNow.xCircleCenter;
    yCircleCenter = stim.calibBestUntilNow.yCircleCenter;
    xCircle = xCircleCenter + circleRadius*cos(maxPerfUntilNowAngle*(pi/180) - pi/2);
    yCircle = yCircleCenter + circleRadius*sin(maxPerfUntilNowAngle*(pi/180) - pi/2);
    Screen('DrawLine', window, lineColour,...
        xCircleCenter, yCircleCenter, xCircle, yCircle,...
        stim.calibBestUntilNow.lineWidth);
end

%% display red bar where the minimal performance to reach is located
if exist('minPerfToReachAngle','var') && ~isempty(minPerfToReachAngle)
    lineColour = stim.calibMinToReach.color;
    circleRadius = stim.calibMinToReach.circleRadius;
    xCircleCenter = stim.calibMinToReach.xCircleCenter;
    yCircleCenter = stim.calibMinToReach.yCircleCenter;
    xCircle = xCircleCenter + circleRadius*cos(minPerfToReachAngle*(pi/180) - pi/2);
    yCircle = yCircleCenter + circleRadius*sin(minPerfToReachAngle*(pi/180) - pi/2);
    Screen('DrawLine', window, lineColour,...
        xCircleCenter, yCircleCenter, xCircle, yCircle,...
        stim.calibMinToReach.lineWidth);
end

%% instructions
switch learning_instructions
    case {'fullInstructions','partialInstructions'}
        mental_effort_task_question_display(scr, stim, taskTypeDisplay, sideQuestion, textColor, learning_instructions);
end

%% add monetary amounts on top of performance
if exist('R_chosen','var') && exist('R_or_P','var') &&...
        ~isempty(R_chosen) && ~isempty(R_or_P)
    drawMoneyProportional(scr, stim, R_chosen, R_or_P);
end

%% display on screen
[~,onset_stim] = Screen(window,'Flip');

end % function