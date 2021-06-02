% This program extracts EEG data from the raw (.eeg, .vhdr, .vmrk) files
% and stores the data in specified folders. The format is the same as for Blackrock data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program needs the following matlab files
% makeDirectory.m
% appendIfNotPresent.m
% removeIfPresent.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Supratim Ray,
% March 2015

function getEEGDataBrainProducts(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [subjectName expDate protocolName '.vhdr'];
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use EEGLAB plugin "bva-io" to read the file
eegInfo = pop_loadbv(folderIn,fileName,[],[]);

cAnalog = eegInfo.nbchan;
Fs = eegInfo.srate;
analogInputNums = 1:cAnalog;
disp(['Total number of Analog channels recorded: ' num2str(cAnalog)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% EEG Decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisOnsetTimes = goodStimTimes + timeStartFromBaseLine;
times = eegInfo.times/1000; % This is in ms

if (cAnalog>0)
    
    % Set appropriate time Range
    numSamples = deltaT*Fs;
    timeVals = timeStartFromBaseLine+ (1/Fs:1/Fs:deltaT);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Prepare folders
    folderOut = fullfile(folderName,'segmentedData');
    makeDirectory(folderOut); % main directory to store EEG Data
    
    % Make Diectory for storing LFP data
    outputFolder = fullfile(folderOut,'LFP'); % Still kept in the folder LFP to be compatible with Blackrock data
    makeDirectory(outputFolder);
    
    % Now segment and store data in the outputFolder directory
    totalStim = length(analysisOnsetTimes);
    goodStimPos = zeros(1,totalStim);
    for i=1:totalStim
        goodStimPos(i) = find(times>analysisOnsetTimes(i),1);
    end
    
    for i=1:cAnalog
        disp(['elec' num2str(analogInputNums(i))]);
        
        clear analogData
        analogData = zeros(totalStim,numSamples);
        for j=1:totalStim
            analogData(j,:) = eegInfo.data(analogInputNums(i),goodStimPos(j)+1:goodStimPos(j)+numSamples);
        end
        analogInfo = eegInfo.chanlocs(analogInputNums(i)); %#ok<*NASGU>
        save(fullfile(outputFolder,['elec' num2str(analogInputNums(i)) '.mat']),'analogData','analogInfo');
    end
    
    % Write LFP information. For backward compatibility, we also save
    % analogChannelsStored which is the list of electrode data
    electrodesStored = analogInputNums;
    analogChannelsStored = electrodesStored;
    save(fullfile(outputFolder,'lfpInfo.mat'),'analogChannelsStored','electrodesStored','analogInputNums','goodStimPos','timeVals');
end