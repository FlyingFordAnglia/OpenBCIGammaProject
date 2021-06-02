% This program extracts EEG data from the raw output of the OpenBCI GUI
% and stores the data in specified folders.

% This function is run inside runExtractAllProtocolsOBCIGammaProject.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function getEEGDataOBCI(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,electrodeLabels)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 250;  % 250Hz without Daisy, 125Hz with Daisy
fileName = [subjectName expDate protocolName '.txt'];
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use readtable MATLAB function to read the code
eegData = readtable(fullfile(folderIn, fileName), 'HeaderLines', 4, 'ReadVariableNames', 1);
analogInputNums = 1:8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% EEG Decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisOnsetTimes = goodStimTimes + timeStartFromBaseLine; % the times where stimulus began
times = 0.004 * (1:height(eegData)); % assuming the perfect 250Hz sampling frequency because OBCI does not give timestamps

% Set appropriate time Range
numSamples = deltaT * Fs; % number of samples in the duration of each segment (trial length)
timeVals = timeStartFromBaseLine + (1/Fs:1/Fs:deltaT);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare folders
folderOut = fullfile(folderName,'segmentedData');
makeDirectory(folderOut); % main directory to store EEG Data

% Make Directory for storing LFP data
outputFolder = fullfile(folderOut,'LFP'); % Still kept in the folder LFP to be compatible with Blackrock data
makeDirectory(outputFolder);

% Now segment and store data in the outputFolder directory
totalStim = length(analysisOnsetTimes);
goodStimPos = zeros(1,totalStim);

for i=1:totalStim
	goodStimPos(i) = find(times>analysisOnsetTimes(i),1);
end

for i=1:8
	disp(['elec' num2str(i)]);
	
	clear analogData
	analogData = zeros(totalStim,numSamples);
	for j=1:totalStim
		analogData(j,:) = eegData{goodStimPos(j)+1:goodStimPos(j)+numSamples,i+1};
	end
	analogInfo = struct('labels', electrodeLabels(i)); %#ok<*NASGU>
	save(fullfile(outputFolder,['elec' num2str(analogInputNums(i)) '.mat']),'analogData','analogInfo');
end

% Write LFP information. For backward compatibility, we also save
% analogChannelsStored which is the list of electrode data
electrodesStored = 1:8;
analogChannelsStored = 1:8;
save(fullfile(outputFolder,'lfpInfo.mat'),'analogChannelsStored','electrodesStored','analogInputNums','goodStimPos','timeVals');
end