% This function is used to extract the digital data from raw brain products
% data files (.eeg, .vhdr, .vmrk)

% Each data file is characterized by four parameters - subjectName, expDate,
% protocolName and gridType.

% We assume that the raw data is initially stored in
% folderSourceString\data\rawData\{subjectName}{expDate}\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In order to make sure that digital codes from different recording systems
% are similar, we convert the digital codes to the Blackrock format.

% The GRF Protocol automatically extends the length of two digital -
% trialStart and trialEnd, to 2 ms, making sure that they are captured
% properly as long as the sampling frequency exceeds 1 kHz. Further, the
% codes corresponding to reward are also recorded. The program therefore
% does the following:

% 1. Finds out which codes correspond to reward on/off, TrialStart and TrialEnd
% 2. Changes these codes to the format used in Blackrock
% 3. Ignores the other digital codes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,deltaLimitMS)

% We only consider codes that are separated by at least deltaLimit ms to make sure
% that none of the codes are during the transition period.
if ~exist('deltaLimitMS','var');    deltaLimitMS = 5;                   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [subjectName expDate protocolName '.vhdr'];
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use EEGLAB plugin "bva-io" to read the file
eegData = pop_loadbv(folderIn,fileName,[],1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Digital Codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[digitalTimeStampsS,digitalEventsS,digitalTimeStampsR,digitalEventsR] = getStimulusEvents(eegData.event);
disp(['Digital events: Total: ' num2str(length(eegData.event)) ', Stimulus: ' num2str(length(digitalTimeStampsS)) ', Response: ' num2str(length(digitalTimeStampsR))]);

if isempty(digitalTimeStampsR)
    [digitalTimeStamps,digitalEvents] = removeBadCodes(digitalTimeStampsS/eegData.srate,digitalEventsS,deltaLimitMS);
else
    [digitalTimeStampsS,digitalEventsS] = removeBadCodes(digitalTimeStampsS/eegData.srate,digitalEventsS,deltaLimitMS);
    [digitalTimeStampsR,digitalEventsR] = removeBadCodes(digitalTimeStampsR/eegData.srate,digitalEventsR,deltaLimitMS);
    [digitalTimeStamps,digitalEvents] = combineGoodCodes(digitalTimeStampsS,digitalEventsS,digitalTimeStampsR,digitalEventsR,deltaLimitMS);
end

end

function [eventTimes,eventVals,eventTimesR,eventValsR] = getStimulusEvents(allEvents)

% All 16 digital pins of BrainProducts should be set to 'Stimulus'. If that
% is not the case, throw an error for now.

count=1;
countR=1; dispFlag=0; eventTimesR=[]; eventValsR = [];
for i=1:length(allEvents)
    if strcmp(allEvents(i).code, 'Response')
        if dispFlag==0
            disp('Response pins should be set to Stimulus in the Brain Products configurations settings. Trying to merge Responses to Stimulus...');
            dispFlag=1;
        end
        eventTimesR(countR) = allEvents(i).latency;
        eventValsR(countR)   = str2double(allEvents(i).type(2:end));
        countR=countR+1;
    end   
    if strcmp(allEvents(i).code, 'Stimulus')
        eventTimes(count) = allEvents(i).latency;
        eventVals(count)   = str2double(allEvents(i).type(2:end)); %#ok<*AGROW>
        count=count+1;
    end
end

if countR==1 % No response markers. This happens only when all pins are set at Stimulus
    % MSB is set to negative. Change to positive
    x = find(eventVals<0);
    eventVals(x) = 2^16 + eventVals(x);
end

end
function [digitalTimeStamps,digitalEvents] = removeBadCodes(digitalTimeStamps,digitalEvents,deltaLimitMS)
deltaLimit = deltaLimitMS/1000; 
dt = diff(digitalTimeStamps);
badDTPos = find(dt<=deltaLimit);

if ~isempty(badDTPos)
    disp([num2str(length(badDTPos)) ' of ' num2str(length(digitalTimeStamps)) ' (' num2str(100*length(badDTPos)/length(digitalTimeStamps),2) '%) are separated by less than ' num2str(1000*deltaLimit) ' ms and will be discarded']);
    digitalTimeStamps(badDTPos)=[];
    digitalEvents(badDTPos)=[];
end
end
function [digitalTimeStamps,digitalEvents] = combineGoodCodes(digitalTimeStampsS,digitalEventsS,digitalTimeStampsR,digitalEventsR,deltaLimitMS)

for i=1:length(digitalTimeStampsS)
    pos = intersect(find(digitalTimeStampsR>=digitalTimeStampsS(i)-deltaLimitMS/1000),find(digitalTimeStampsR<=digitalTimeStampsS(i)+deltaLimitMS/1000));
    %pos = find(digitalTimeStampsR<=digitalTimeStampsS(i),1,'last');
    if ~isempty(pos)
        digitalTimeStamps(i) = digitalTimeStampsS(i);
        digitalEvents(i) = digitalEventsS(i) + 2^8 *digitalEventsR(pos);
    else
        digitalTimeStamps(i) = digitalTimeStampsS(i);
        digitalEvents(i) = digitalEventsS(i);
    end
end
digitalEvents(digitalEvents==255) = 2^16-1; % if all lower pins are 1, set all upper pins to 1 too. 
end