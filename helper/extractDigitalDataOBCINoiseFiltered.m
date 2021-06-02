% This function is used to extract the digital data from raw OpenBCI data
% file (output saved from OpenBCI GUI)

% Each data file is characterized by four parameters - subjectName, expDate,
% protocolName and gridType.

% We assume that the raw data is initially stored in
% folderSourceString\data\rawData\{subjectName}{expDate}\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [digitalTimeStamps, digitalEvents]=extractDigitalDataOBCINoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,deltaLimit)

% Currently the OpenBCI board is assumed to be running at 250Hz Sampling (without Daisy,
% with Bluetooth Adaptor)
% The digital code circuit is assumed to keep the code persistant after updating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% minimum inter-event-code difference below which they are removed as transition codes
if ~exist('deltaLimitMS','var');  deltaLimit = 0.005; end %deltaLimit is in milliseconds                 


fileName = [subjectName expDate protocolName];
folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use readtable MATLAB function to read the code
eegData = readtable(fullfile(folderIn, fileName), 'HeaderLines', 4, 'ReadVariableNames', 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Digital Codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
decimalEventCodes = convertFromBinary(eegData); % binary format -> integers
[digitalTimeStamps, digitalEvents] = findEventCodeChanges(decimalEventCodes); % finding the event-code changes
goodCodePositions = removeTransitionCodes(digitalTimeStamps, deltaLimit); % filter transition codes
digitalEvents = digitalEvents(goodCodePositions);
digitalTimeStamps = digitalTimeStamps(goodCodePositions);
disp(['Total Digital Events: ' num2str(length(digitalEvents))]);

end

% To convert binary-represented digital pin signals to a decimal number
function [newCodes]=convertFromBinary(eegData)
newCodes = transpose(eegData{:, 14} * 16 + eegData{:, 15} * 8 + eegData{:, 16} * 4 + eegData{:, 17} * 2 + eegData{:, 19});
%Column 18 is a list of zeroes and does not store any information (as there are only 5 digital pins in OpenBCI)
end

%To extract the timestamps (relative to the start) and the corresponding Event codes
%OpenBCI does not send any timestamps from the Cyton Board. The sampling is
%assumed to be constant and timestamps are generated here using the expected 4ms gap
%between packets of data.

function [digitalTimeStamps, digitalEvents]=findEventCodeChanges(decimalEventCodes)

temp = find(abs(diff(decimalEventCodes)) > 0) + 1;  % Get the digital codes whenever a code changed
allTimes = (0 : (length(decimalEventCodes)-1)) * 0.004;
digitalEvents = decimalEventCodes(temp);
digitalTimeStamps = allTimes(temp);
end


function [goodCodePosition] = removeTransitionCodes(digitalTimeStamps, deltaLimit)

diffDT = diff(digitalTimeStamps);
goodCodePosition = [not(diffDT<=deltaLimit) true]; % always keep the last code entry

end