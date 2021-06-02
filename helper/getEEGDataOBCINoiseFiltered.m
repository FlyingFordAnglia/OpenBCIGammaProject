%This program is identical to getEEGDataOBCI except for a file name directory in line 21.

% This program extracts EEG data from the raw output of the OpenBCI GUI
% and stores the data in specified folders.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program needs the following matlab files
% makeDirectory.m
% appendIfNotPresent.m
% removeIfPresent.m


function getEEGDataOBCINoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT,electrodeLabels)
% Currently the OpenBCI is assumed to be running at 250Hz Sampling (without Daisy,
% with Bluetooth Adaptor)
% The digital code circuit is assumed to keep the code persistant after updating

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 250;  % 250Hz without Daisy, 125Hz with Daisy
fileName = [subjectName expDate protocolName '.txt'];
folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use readtable MATLAB function to read the code
eegData = readtable(fullfile(folderIn, fileName), 'HeaderLines', 4, 'ReadVariableNames', 1);
segmentLength = 20;
for iElec = 1:8
    rawData = eegData{:,iElec+1};
    counter = 1;
    while counter < length(rawData)
        if (counter + (segmentLength*Fs)) <= length(rawData)
            segmentIndices = counter : (counter + (segmentLength*Fs) - 1);
        else
            segmentIndices = counter : length(rawData);
        end
%         disp('segmentIndices');
%         disp([segmentIndices(1) segmentIndices(end)]);
        segmentToBeNoiseCorrected = rawData(segmentIndices);
        fftX = fft(segmentToBeNoiseCorrected);
        absfftX = abs(fftX);
        freqVals = 0:1/(length(segmentIndices)/Fs):Fs-1/(length(segmentIndices)/Fs); 
        freqPos = find(freqVals>20 & freqVals<125);
        maxPos = find(absfftX==max(absfftX(freqPos)));
%         disp('maxFreq');
%         disp(freqVals(maxPos));
        fftNX = zeros(1,length(fftX));
        fftNX(maxPos) = fftX(maxPos);
        noiseSignal = ifft(fftNX);
        noiseCorrectedSegment = segmentToBeNoiseCorrected - noiseSignal';
        rawData(segmentIndices) = noiseCorrectedSegment;
%         figure();
%         fig1 = subplot(1,2,1);
%         plot(fig1,segmentToBeNoiseCorrected);
%         hold on;
%         plot(fig1,noiseCorrectedSegment);
%         legend(fig1,'old','new');
%         fig2 = subplot(1,2,2);
%         plot(fig2,freqVals,log10(abs(fftX)));
%         hold on;
%         plot(fig2,freqVals,log10(abs(fft(noiseCorrectedSegment))))
%         pause;
        counter = counter + (segmentLength*Fs) - 1;
        %disp(['counter: ' num2str(counter)])

    end
    eegData{:,iElec+1} = rawData;
end

analogInputNums = 1:8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% EEG Decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisOnsetTimes = goodStimTimes + timeStartFromBaseLine;
times = 0.004 * (1:height(eegData)); % assuming the perfect 250Hz sampling frequency

% Set appropriate time Range
numSamples = deltaT * Fs;
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