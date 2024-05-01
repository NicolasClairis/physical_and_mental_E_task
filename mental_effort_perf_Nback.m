function[mentalE_perf, trial_success, onsets] = mental_effort_perf_Nback(scr, stim, key,...
    numberVector, mentalE_prm, n_max_to_reach,...
    learning_instructions, time_limit, t_max, errorLimits,...
    n_maxReachedUntilNow, n_minCorrectAnswersToReach, R_or_P, R_chosen)
%[mentalE_perf, trial_success, onsets] = mental_effort_perf_Nback(scr, stim, key,...
%     numberVector, mentalE_prm, n_max_to_reach,...
%     curr_learning_instructions, time_limit, t_max, errorLimits,...
%     n_maxReachedUntilNow, n_minCorrectAnswersToReach, R_or_P, R_chosen)
%
% mental_effort_perf_Nback corresponds to the actual performance. Can be
% used both for learning period (with or without instructions) and for the
% actual task. It corresponds to one mental effort trial (either learning,
% calibration or task trial). The task uses a 1-back like procedure where
% the question asked is based on the previously displayed number.
%
% INPUTS
% scr: structure with screen parameters
%
% stim: stucture with stimuli parameters
%
% key: structure with key code for Psychtoolbox to identify which key
% corresponds to left and right cues
%
% numberVector: vector with big list of numbers for the current trial
%
% mentalE_prm: structure with main parameters for mental effort task:
%   .startAngle: start angle for displaying the effort arc
%
%   .mental_n_col: structure with the colour to use for the font
%       .oddEven: colour to use for odd or even question
%       .lowHigh: colour to use for lower/higher than 5 question
%
%   .sideQuestion: structure which tells where each answer is expected to be
%       .oE.pair: -1 means left button corresponds to the pair answer and
%       .oE.impair = 1 means right button corresponds to the impair answer
%       same logic applies to .hL.low and .hL.high fields
%
%   .switchPerc: percentage of switches required (based on total number of
%   subsequent correct answers you want)
%
% learning_instructions
% 'fullInstructions': display instructions: ask if odd/even (or lower/higher than 5) and
% display also on the screen the relevant answer to each question
% 'partialInstructions': display only the two possible answers but not the
% question anymore
% 'noInstructions': no reminder of what the question is nor of where you should answer
%
% time_limit
% (0)/false = no time limit to perform the requested number of questions
% (1)/true = when time limit is reached, stop the trial, even if requested
% number not reached => consider the trial a failure
%
% t_max: maximum time allowed to reach the requested number of correct
% answers
%
% errorLimits: structure containing information about way to handle
% errors
%   .useOfErrorThreshold: if true, means the trial is considered a failure,
%   if the number of errors set as a threshold is reached
%   .errorThreshold: consider the trial a failure if more than this number
%   of errors are made
%   .useOfErrorMapping: if true, display the mapping where to answer and
%   type of the trial after a given number of errors has been made
%   .errorMappingLimit: display the mapping after this number of errors has
%   been reached
%
% n_maxReachedUntilNow: maximal number of correct answers reached until now
% (for calibration mostly): will display an orange bar at the location of
% the maximal performance until now
%
% n_minCorrectAnswersToReach: minimal number of correct answers to reach so
% that performance can be considered to be ok: will display a red bar at
% the location of the minimal performance to reach
%
% R_or_P: 'R' reward or 'P' punishment trial (if not empty will display the
% monetary amount on the screen)
%
% R_chosen: amount of money for which you play in the current trial (if not
% empty will display the monetary amount on the screen)
%
% OUTPUTS
% mentalE_perf: structure with summary of mental effort performance
%   .nTrials: number of trials it took to reach a correct
% performance
%   .rt: reaction time (rt) for each question
%   .taskType: task type (0: odd/even; 1: lower/higher than 5)
%   .totalTime_success: time passed between trial onset and last correct
%   answer (if the trial was a success), NaN if trial was a failure
%
% trial_success:
% false: failure
% true: effort was correctly performed in the requested time
%
% onsets: structure with onset of each number on the screen
%   .nb_i: onset of (i) question during the current trial
%
% See also mental_learning.m

%% extract relevant variables
% angle values
startAngle_currentTrial = mentalE_prm.startAngle;
endAngle = 360;
totalAngleDistance = endAngle - startAngle_currentTrial;
% coordinates for the angle corresponding to the max until now
if exist('n_maxReachedUntilNow','var') && ~isempty(n_maxReachedUntilNow)
    maxPerfUntilNowAngle = totalAngleDistance*(n_maxReachedUntilNow/n_max_to_reach);
else
    maxPerfUntilNowAngle = [];
end
% coordinates for the angle corresponding to the minimal performance to
% accomplish
if exist('n_minCorrectAnswersToReach','var') && ~isempty(n_minCorrectAnswersToReach)
    minPerfAngle = totalAngleDistance*(n_minCorrectAnswersToReach/n_max_to_reach);
else
    minPerfAngle = [];
end
% monetary amount on the screen: if one of the variables is empty or not
% entered, set everything to empty so that the script can work
if ~exist('R_or_P','var') || isempty(R_or_P) ||...
        ~exist('R_chosen','var') || isempty(R_chosen)
    R_or_P = [];
    R_chosen = [];
end

% extract main mental effort parameters
sideQuestion = mentalE_prm.sideQuestion;
mental_n_col = mentalE_prm.mental_n_col;
Nback       = mentalE_prm.Nback;

% extract error management variables
useOfErrorThreshold = errorLimits.useOfErrorThreshold;
if useOfErrorThreshold == true
    errorThreshold = errorLimits.errorThreshold;
end
useOfErrorMapping = errorLimits.useOfErrorMapping;
if useOfErrorMapping == true
    errorMappingLimit = errorLimits.errorMappingLimit;
end

%% define moments when the task switches: should be unpredictable and
% distance between 2 switches should vary between 1 and 4
n_questions = size(numberVector,2);
[taskTypeDisplay,...
    taskTypePerf,...
    currentAngle,...
    rt,...
    sideAnswer,...
    goodOrBadAnswer,...
    numberVectorUsedDisplay,...
    numberVectorUsedPerf] = deal( NaN(1, n_questions));

% lower/higher than 5 task (no more task switching)
taskTypeDisplay(1) = 1;

task_seq = ones(1, n_max_to_reach);
% define first number which will appear on screen
numberVectorUsedDisplay(1) = numberVector(1);
% precise that for first questions of Nback, pressing any button is ok
if Nback > 0
    taskTypePerf(1:Nback) = 2; % first answers = any button press is ok
    taskTypePerf((Nback+1):end) = 1; % next = need to say if lower or higher than zero
    numberVectorUsedPerf(1:Nback) = NaN;
elseif Nback == 0
    taskTypePerf(:) = 1;
end

%% initialize the counters

% number of subsequent correct answers
iCorrectAnswers = 0; % indicator to know when trial is considered as a success
% (note that iCorrectAnswers will decrease for each error made, but not
% jCorrectAnswers)

jCorrectAnswers = 0; % indicator tracking actual real number of correct answers (used for selection of the number to display)

% number of questions answered
i_question = 1;
j_seq = 2; % first trial type already defined!

%% wait all keys are released before starting
KbReleaseWait;
% you could even add a timer here in order to ask the participant to
% release the keys if he/she is currently pressing one key

%% initial display to get timing of the start
% add the rest
[onsetTrial] = mental_display_stim(scr, stim,...
    startAngle_currentTrial, endAngle,...
    sideQuestion, taskTypeDisplay(1), numberVector(1), mental_n_col,...
    learning_instructions, maxPerfUntilNowAngle, minPerfAngle, R_chosen, R_or_P);
onset_question_tmp = onsetTrial; % for the first question
onsets.nb_1 = onsetTrial;
timeNow = onsetTrial;

% initialize the angle for the first questions (should not move for first
% questions of Nback where no real question is asked)
currentAngle(1:(1+Nback)) = startAngle_currentTrial;

% keep track of number of errors made during the trial
jErrorsMade = 0;

% loop until relevant number of subsequent correct answers has been reached
% or that max time limit has been reached (if one time limit has been
% defined) or that total tolerated number of errors has been reached (if
% there is a time limit and a threshold on the number of errors)
while (iCorrectAnswers < n_max_to_reach) &&...
        ( ( (time_limit == true) && (timeNow < onsetTrial + t_max) ) ||...
        (time_limit == false) ) &&...
        ( ( (useOfErrorThreshold == true) && (jErrorsMade < errorThreshold) ) ||...
        (useOfErrorThreshold == false) )
    %% get timing
    timeNow = GetSecs;
    
    %% display instructions after 2 errors have been made (in case where no
    % instructions on screen)
    switch useOfErrorMapping
        case true
            if strcmp(learning_instructions,'noInstructions') &&...
                    i_question > 1 &&...
                    mod(jErrorsMade, errorMappingLimit) == 0 &&...
                    goodOrBadAnswer(i_question  - 1) == 0
                % will display instructions for the next question everytime after
                % 2 errors (can be adapted easily to remain for th whole trial if
                % necessary)
                learning_instructions_bis = 'fullInstructions';
            else
                learning_instructions_bis = learning_instructions;
            end
        case false
            learning_instructions_bis = learning_instructions;
    end
    
    %% display stimulus
    onset_stim = mental_display_stim(scr, stim,...
        currentAngle(i_question), endAngle,...
        sideQuestion, taskTypeDisplay(i_question), numberVectorUsedDisplay(i_question), mental_n_col,...
        learning_instructions_bis, maxPerfUntilNowAngle, minPerfAngle, R_chosen, R_or_P);
    
    %% record onset
    if i_question > 1
        onsets.(['nb_',num2str(i_question)]) = onset_stim;
    end
    
    %% check key presses
    [keyisdown, ~, ~, lastPress, ~] = KbQueueCheck;
    
    if (keyisdown == 1) &&...
            ((lastPress(key.left) > onset_question_tmp && lastPress(key.right) < onset_question_tmp) ||...
            (lastPress(key.left) < onset_question_tmp && lastPress(key.right) > onset_question_tmp)) % focus only when 1 single button
        % which belongs to the 2 buttons of interest has been pressed
        
        if lastPress(key.left) > onset_question_tmp &&...
                lastPress(key.right) < onset_question_tmp % left answer
            sideAnswer(i_question) = -1;
            timeAnswer = lastPress(key.left);
        elseif lastPress(key.left) < onset_question_tmp &&...
                lastPress(key.right) > onset_question_tmp % right answer
            sideAnswer(i_question) = 1;
            timeAnswer = lastPress(key.right);
        end % left or right answer? (ignore the rest = if another key has
        % been pressed or if both pressed in the same time for ex.)
        
        %% wait for participant to release the keys before updating the variables of interest
        % without this, it can create weird bugs as for the next question
        % it could reuse the previous answer
        KbReleaseWait();
        
        %% determine whether the response was correct or not
        [goodOrBadAnswer(i_question)] = mental_effort_answer_correct(taskTypePerf(i_question),...
            numberVectorUsedPerf(i_question),...
            sideAnswer(i_question), sideQuestion);
        
        %% update counters for number of correct answers
        if i_question <= Nback % first questions of Nback = provide any answer left or right (no correct answer)
            if goodOrBadAnswer(i_question) == 1
                jCorrectAnswers = jCorrectAnswers + 1;
            end
        elseif i_question > Nback
            % do not update the counter for the first question where they just
            % should press any button
            
            switch goodOrBadAnswer(i_question)
                case 0 % error made
                    
                    % version where you reset the timer whenever they make an
                    % error
                    % currentAngle(i_question + 1) = startAngle_currentTrial; % re-initialize
                    % i_max_correct = 0; % if wrong, set back indicators to zero: needs to restart
                    
                    if iCorrectAnswers > 0 % keep equal to zero if you made a mistake the first trial
                        iCorrectAnswers = iCorrectAnswers - 1; % if wrong, decrement the total number of correct answers
                        % just (-1) decrement after an error (otherwise too hard)
                        currentAngle(i_question + 1) = currentAngle(i_question) - totalAngleDistance/n_max_to_reach;
                    else % if error made during the first trial should not move
                        iCorrectAnswers = 0;
                        currentAngle(i_question + 1) = startAngle_currentTrial; % if error made during the first question, keep at initial location
                        % otherwise it means that you increase the difficulty
                        % when they make an error for the first question
                    end
                    jErrorsMade = jErrorsMade + 1;
                case 1 % if correct, update the count of correct answers and the angle display
                    currentAngle(i_question + 1) = currentAngle(i_question) + totalAngleDistance/n_max_to_reach;
                    iCorrectAnswers = iCorrectAnswers + 1;
                    jCorrectAnswers = jCorrectAnswers + 1;
            end
        end
        %% define the task type and the number for the next question
        if iCorrectAnswers < n_max_to_reach
            % once the expected amount of correct answers has been reached,
            % there is no need to make more switches
            
            if goodOrBadAnswer(i_question) == 0
                % no task switch after an error to keep the task easy after an error has been made
                taskTypeDisplay(i_question + 1) = taskTypeDisplay(i_question);
                
%                 % no change of number after an error to keep the task easy
%                 % after an error has been made
%                 numberVectorUsedDisplay(i_question + 1) = numberVectorUsedDisplay(i_question);
%                 numberVectorUsedPerf(i_question + 1)    = numberVectorUsedPerf(i_question);
            elseif goodOrBadAnswer(i_question) == 1 % correct answer => update
                if j_seq <= length(task_seq) % keep taking next element of the task_seq vector
                    taskTypeDisplay(i_question + 1) = task_seq(j_seq);
                    j_seq = j_seq + 1;
                else % when all the sequence has already been passed, keep the same task
                    taskTypeDisplay(i_question + 1) = taskTypeDisplay(i_question);
                end
%                 % + consider that because of the Nback procedure, you need
%                 % to go +1 more because first answer = any number
%                 numberVectorUsedDisplay(i_question + 1) = numberVector(jCorrectAnswers + 1);
%                 % update performance information: if the answer provided
%                 % was correct, then the next performance question is the
%                 % previous display question
%                 numberVectorUsedPerf(i_question + 1) = numberVectorUsedDisplay(i_question);
            end
            
            % the question answered in [Nback] questions is the one
            % displayed in the current question
            taskTypePerf(i_question + Nback) = taskTypeDisplay(i_question);
            
            % keep updating the numbers displayed even after an error has been made
            numberVectorUsedDisplay(i_question + 1) = numberVector(i_question + 1);
            % number for perf is to answer in [Nback] questions
            numberVectorUsedPerf(i_question + Nback) = numberVectorUsedDisplay(i_question); % perf for next question depends on the previously displayed number
        end % no need to update task type for the next question if the end has been reached
        
        %% update variables of interest
        % record time to answer and re-initialize the counter to get next
        % RT
        rt(i_question) = timeAnswer - onset_question_tmp;
        onset_question_tmp = timeAnswer; % for the next question, the onset corresponds to the answer of the previous question
        
        %% update total count of answers in any case
        i_question = i_question + 1;
        
    end % has a relevant key been pressed
    
end % keep performing until number of subsequent answers reaches threshold predefined or if timer has been reached

%% compute gains

if iCorrectAnswers == 0 % case where no answers has been provided or all answers are bad
    mentalE_perf.performance = 0;
    currentAngleTrialsDone = 0;
else % at least some questions were answered
    currentAngleTrialsDone = currentAngle(1:i_question); % take angle until last trial
    mentalE_perf.performance = 100*((currentAngleTrialsDone(end) - startAngle_currentTrial)/(360 - startAngle_currentTrial));
end

%% record all in output
% keep only questions performed
questions_done = ~isnan(sideAnswer);
% record question parameters
mentalE_perf.Nback = Nback;
mentalE_perf.questions_done = questions_done;
mentalE_perf.numberVector   = numberVector;
mentalE_perf.numberVectorUsedDisplay = numberVectorUsedDisplay(questions_done);
mentalE_perf.numberVectorUsedPerf = numberVectorUsedPerf(questions_done);
mentalE_perf.taskTypeDisplay= taskTypeDisplay(questions_done);
mentalE_perf.taskTypePerf   = taskTypePerf(questions_done);
mentalE_perf.sideAnswer     = sideAnswer(questions_done);
mentalE_perf.isGoodAnswer   = goodOrBadAnswer(questions_done);
mentalE_perf.rt             = rt(questions_done);
mentalE_perf.n_max_to_reach = n_max_to_reach;
mentalE_perf.n_errorsMade   = jErrorsMade;
mentalE_perf.anglePerformance = currentAngleTrialsDone;
% record number of questions answered and how many were correct
mentalE_perf.n_questions_performed = i_question - 1;
mentalE_perf.n_correctAnswersForDisplay = iCorrectAnswers;
mentalE_perf.n_correctAnswersProvided = jCorrectAnswers - Nback; % remove Nback for the first answers (=just pressing any button)
% record if trial was achieved or interrompted due to time limit (=failure)
if iCorrectAnswers == n_max_to_reach % reached the top
    trial_success = true;
    totalTime_success = timeAnswer - onsetTrial; % total time between start of the trial and last correct answer
elseif iCorrectAnswers < n_max_to_reach % not enough good answers
    trial_success = false;
    totalTime_success = NaN;
end
mentalE_perf.success = trial_success;
mentalE_perf.totalTime_success = totalTime_success;
mentalE_perf.onsets = onsets;

end % function