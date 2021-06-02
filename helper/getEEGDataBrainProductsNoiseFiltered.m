% This program is identical to getEEGDataBrainProducts.m except for the file-name directory

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

function getEEGDataBrainProductsNoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimes,timeStartFromBaseLine,deltaT)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileName = [subjectName expDate protocolName '.vhdr'];
folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
makeDirectory(folderName);
folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
folderExtract = fullfile(folderName,'extractedData');
makeDirectory(folderExtract);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% use EEGLAB plugin "bva-io" to read the file
eegInfo = pop_loadbv(folderIn,fileName,[],[]);
segmentLength = 20;
Fs = eegInfo.srate;

for iElec = 1:8
    rawData = eegInfo.data(iElec,:);
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
        noiseCorrectedSegment = segmentToBeNoiseCorrected - noiseSignal;
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
    eegInfo.data(iElec,:) = rawData;
end
cAnalog = eegInfo.nbchan;
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