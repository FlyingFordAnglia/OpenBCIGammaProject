

% check whether we are getting the eye signal or not
if ~ML_eyepresent, error('This task requires eye signal input. Please set it up or try the simulation mode.'); end
hotkey('x', 'escape_screen(); assignin(''caller'',''continue_'',false);'); % hotkey to stop the task

set_bgcolor([0.5 0.5 0.5]); % for grey subject screen

fixation_point = 1;
grating = 2;
stimulus_duration = 1000; %defining time intervals (ms)
hold_radius = [5 5];

% Task

% initial fixation:
toggleobject(fixation_point); %displays fixation point
idle(100);
[ontarget,rt] = eyejoytrack('acquirefix', fixation_point, hold_radius, 2000); %waits for 2 seconds max for eye position to arrive in the fixation radius
if ~ontarget
    toggleobject(fixation_point);
    trialerror(4);  % no fixation
    return
end
ontarget = eyejoytrack('holdfix', fixation_point, hold_radius, 1000); %checks that the eye position is stably inside the fixation radius for 1 second (baseline period)
if ~ontarget
    toggleobject(fixation_point);
    trialerror(3);  % broke fixation
    return
end

% grating epoch
x = TrialRecord.CurrentCondition+18; %setting event markers as 19 to 30 for the 12 conditions
toggleobject(grating, 'eventmarker',x);  % turn on stimulus
ontarget = eyejoytrack('holdfix', fixation_point, hold_radius, stimulus_duration);
if ~ontarget
    toggleobject([fixation_point grating]);
    trialerror(3);  % broke fixation
    return
end
toggleobject(grating);  % turn off sample
toggleobject(fixation_point);   % turn off fixation point
trialerror(0); % correct trial

set_iti(1000); % inter trial interval is 1 second.