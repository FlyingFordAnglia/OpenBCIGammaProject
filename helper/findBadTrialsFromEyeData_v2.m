% Written by Murty Dinavahi

function badEyeTrials = findBadTrialsFromEyeData_v2(eyeDataDeg,eyeRangeMS,FsEye,checkPeriod,fixationWindowWidth)

    if ~exist('fixationWindowWidth','var');         fixationWindowWidth = 5;           end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eyeDataDegX = eyeDataDeg.eyeDataDegX;
    eyeDataDegY = eyeDataDeg.eyeDataDegY;

    timeValsEyePos = (eyeRangeMS(1):1000/FsEye:eyeRangeMS(2)-1000/FsEye)/1000;

    if ~exist('checkPeriod','var');             checkPeriod = eyeRangeMS/1000;      end
    timeValsEyeCheckPos = timeValsEyePos>=checkPeriod(1) & timeValsEyePos<=checkPeriod(2);

    % do baseline correction    
%     eyeDataDegX = eyeDataDegX - repmat(mean(eyeDataDegX(:,timeValsEyeCheckPos),2),1,size(eyeDataDegX,2));
%     eyeDataDegY = eyeDataDegY - repmat(mean(eyeDataDegY(:,timeValsEyeCheckPos),2),1,size(eyeDataDegY,2));

    % Find bad trials
    clear xTrialsBeyondFixWindow yTrialsBeyondFixWindow xTrialsNoSignals yTrialsNoSignals badEyeTrials
    xTrialsBeyondFixWindow = sum(abs(eyeDataDegX(:,timeValsEyeCheckPos))>(fixationWindowWidth/2),2);
    yTrialsBeyondFixWindow = sum(abs(eyeDataDegY(:,timeValsEyeCheckPos))>(fixationWindowWidth/2),2);
    xTrialsNoSignals = sum(abs(eyeDataDegX(:,timeValsEyeCheckPos)),2);
    yTrialsNoSignals = sum(abs(eyeDataDegY(:,timeValsEyeCheckPos)),2);

    badEyeTrials = find(xTrialsBeyondFixWindow>0 | yTrialsBeyondFixWindow>0 | xTrialsNoSignals==0 | yTrialsNoSignals==0);
    if badEyeTrials==0; badEyeTrials=[]; end
end
