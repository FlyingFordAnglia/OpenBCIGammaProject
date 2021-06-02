%This program is identical to runExtractAllProtocolsOBCIGammaProject.m except for the following:
% Before segmenting data, code has been written to reduce line noise from the raw data.
% The segmented data is now stored in a new folder for each subject

% This program takes in rawData (files from BrainProducts, OpenBCI and
% MonkeyLogic) and extracts and segments the rawData and saves it in the
% data folder for each subject.
% Three protocols are recorded using OpenBCI and BrainProducts each.
% 1. Eye Open - GRF_001 and GRF_004
% 2. Eye Closed - GRF_002 and GRF_005
% 3. Sf-Ori - GRF_003 and GRF_006




gridType='EEG'; 
% folderSourceString is the directory where the 'data' folder is located.

folderSourceString='C:\Users\srivi\Desktop\updated_codes_010621\new';
% allProtocolsOBCIGammaProject has an index wise listing of the experiment
% details.
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = allProtocolsOBCIGammaProject;
electrodeLabels = ["O1","O2","T5","P3","Pz","P4","T6","Ref"];% according to the 10-20 international system

% the indices of protocols you want to extract
extractTheseIndices = 13:18; % This is for subject 3.   
Fs = 250; % sampling frequency of EEG recording - OBCI and BP
for iProt = 1:length(extractTheseIndices) % for each protocol 
    
    subjectName = subjectNames{extractTheseIndices(iProt)};
    expDate= expDates{extractTheseIndices(iProt)};
    protocolName= protocolNames{extractTheseIndices(iProt)};
    deviceName = deviceNames{extractTheseIndices(iProt)};
    capLayout = capLayouts{extractTheseIndices(iProt)};
    
    %% Eye open and eye closed data for OpenBCI
    clear eegData
    if strcmpi(protocolName,'GRF_001') || strcmpi(protocolName,'GRF_002')
        fileName = [subjectName expDate protocolName];
        folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
        folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
        makeDirectory(folderName);
        folderExtract = fullfile(folderName,'extractedData');
        makeDirectory(folderExtract);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % use readtable MATLAB function to read the code
        eegData = readtable(fullfile(folderIn, fileName), 'HeaderLines', 4, 'ReadVariableNames', 1);
        
        % removing line noise
        segmentLength = 20; % seconds
        for iElec = 1:8
            rawData = eegData{:,iElec+1};
            counter = 1;
            while counter < length(rawData)
                if (counter + (segmentLength*Fs)) <= length(rawData)
                    segmentIndices = counter : (counter + (segmentLength*Fs) - 1);
                else
                    segmentIndices = counter : length(rawData);
                end
%                 disp('segmentIndices');
%                 disp([segmentIndices(1) segmentIndices(end)]);
                segmentToBeNoiseCorrected = rawData(segmentIndices);
                fftX = fft(segmentToBeNoiseCorrected);
                absfftX = abs(fftX);
                freqVals = 0:1/(length(segmentIndices)/Fs):Fs-1/(length(segmentIndices)/Fs); 
                freqPos = find(freqVals>20 & freqVals<125);
                maxPos = find(absfftX==max(absfftX(freqPos))); % finding out the frequency with maximum power between 20 and 125 Hz (which is the line noise in our case)
%                 disp('maxFreq');
%                 disp(freqVals(maxPos));
                fftNX = zeros(1,length(fftX));
                fftNX(maxPos) = fftX(maxPos);
                noiseSignal = ifft(fftNX); % calculating the pure noise signal
                noiseCorrectedSegment = segmentToBeNoiseCorrected - noiseSignal';
                rawData(segmentIndices) = noiseCorrectedSegment;
%                 figure();
%                 fig1 = subplot(1,2,1);
%                 plot(fig1,segmentToBeNoiseCorrected);
%                 hold on;
%                 plot(fig1,noiseCorrectedSegment);
%                 legend(fig1,'old','new');
%                 fig2 = subplot(1,2,2);
%                 plot(fig2,freqVals,log10(abs(fftX)));
%                 hold on;
%                 plot(fig2,freqVals,log10(abs(fft(noiseCorrectedSegment))))
%                 pause;
                counter = counter + (segmentLength*Fs) - 1;
                %disp(['counter: ' num2str(counter)])

            end
            eegData{:,iElec+1} = rawData;
        end
        analogInputNums = 1:8;
        disp(['Total number of Analog channels recorded: ' num2str(length(analogInputNums))]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%% EEG Decomposition %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        analysisTimeToBeUsed = 60; % in seconds
        analysisOnsetTimes = 3:1:analysisTimeToBeUsed-1; %goodStimTimes + timeStartFromBaseLine; 
        %starting from 3rd second to remove starting artefacts from
        %recording
        times = 0.004 * (1:height(eegData)); % This is in milliseconds
        deltaT = 1.000; % in seconds;
        
        if (~isempty(analogInputNums))
            
            % Set appropriate time Range
            numSamples = deltaT*Fs;
            timeVals = (1/Fs:1/Fs:deltaT);
            
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
            
            for i=1:8
                disp(['elec' num2str(analogInputNums(i))]);
                
                clear analogData
                analogData = zeros(totalStim,numSamples);
                for j=1:totalStim
                    analogData(j,:) = eegData{goodStimPos(j)+1:goodStimPos(j)+numSamples,i+1};
                end
                analogInfo = struct('label', electrodeLabels(i)); %#ok<*NASGU>
                save(fullfile(outputFolder,['elec' num2str(analogInputNums(i)) '.mat']),'analogData','analogInfo');
            end
            
            % Write LFP information. For backward compatibility, we also save
            % analogChannelsStored which is the list of electrode data
            electrodesStored = analogInputNums;
            analogChannelsStored = electrodesStored;
            save(fullfile(outputFolder,'lfpInfo.mat'),'analogChannelsStored','electrodesStored','analogInputNums','goodStimPos','timeVals');
        end

    end
    
    %% Eye open and eye closed for BrainProducts
    
    if strcmpi(protocolName,'GRF_004') || strcmpi(protocolName,'GRF_005')
        fileName = [subjectName expDate protocolName '.vhdr'];
        folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
        folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
        makeDirectory(folderName);
        folderExtract = fullfile(folderName,'extractedData');
        makeDirectory(folderExtract);
        
        % Following code is adapted from getEEGDataBrainProducts under
        % LabCommonPrograms
        % (Programs/CommonPrograms/ReadData/getEEGDataBrainProducts
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%                 disp('segmentIndices');
%                 disp([segmentIndices(1) segmentIndices(end)]);
                segmentToBeNoiseCorrected = rawData(segmentIndices);
                fftX = fft(segmentToBeNoiseCorrected);
                absfftX = abs(fftX);
                freqVals = 0:1/(length(segmentIndices)/Fs):Fs-1/(length(segmentIndices)/Fs); 
                freqPos = find(freqVals>20 & freqVals<125);
                maxPos = find(absfftX==max(absfftX(freqPos)));
%                 disp('maxFreq');
%                 disp(freqVals(maxPos));
                fftNX = zeros(1,length(fftX));
                fftNX(maxPos) = fftX(maxPos);
                noiseSignal = ifft(fftNX);
                noiseCorrectedSegment = segmentToBeNoiseCorrected - noiseSignal;
                rawData(segmentIndices) = noiseCorrectedSegment;
%                 figure();
%                 fig1 = subplot(1,2,1);
%                 plot(fig1,segmentToBeNoiseCorrected);
%                 hold on;
%                 plot(fig1,noiseCorrectedSegment);
%                 legend(fig1,'old','new');
%                 fig2 = subplot(1,2,2);
%                 plot(fig2,freqVals,log10(abs(fftX)));
%                 hold on;
%                 plot(fig2,freqVals,log10(abs(fft(noiseCorrectedSegment))))
%                 pause;
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
        
        analysisTimeToBeUsed = 60; % in seconds
        analysisOnsetTimes = 0:1:analysisTimeToBeUsed-1; %goodStimTimes + timeStartFromBaseLine;
        times = eegInfo.times/1000; % This is in ms
        deltaT = 1.000; % in seconds;
        
        if (cAnalog>0)
            
            % Set appropriate time Range
            numSamples = deltaT*Fs;
            timeVals = (1/Fs:1/Fs:deltaT);
            
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

    end
    
    %% SF-ORI protocol for OpenBCI
        if strcmpi(protocolName,'GRF_003')
            
            %based on stimulus type, we can select how we want to segment the data 
			% i.e. how much time before the stim onset to how much time after
            timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
            timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
            timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;

            type = stimTypes{extractTheseIndices(iProt)};
            deltaT = deltaTList(type);
            timeStartFromBaseLine = timeStartFromBaseLineList(type);
            ML = saveMLDataNoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType);
            
            % Extract the trial error codes (the codes which indicate whether fixation was 
            % broken or not) from the saved ML data
            folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
            folderExtract = fullfile(folderName,'extractedData');
            trialError = load(fullfile(folderExtract,'ML.mat'), 'data');
            trialError = trialError.data;
            trialErrorCodes = zeros(1, length(trialError));
            for i=1:length(trialError)
                trialErrorCodes(i) = trialError(i).TrialError;
            end	
            % Read digital data from OpenBCI
            [digitalTimeStamps,digitalEvents]=extractDigitalDataOBCINoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType);

            % Compare ML behavior and OBCI files
            if ~isequal(ML.allCodeNumbers,digitalEvents)
                error('Digital and ML codes do not match');
            else
                disp('Digital and ML codes match!');
                clf;
                subplot(211);
                plot(1000*diff(digitalTimeStamps),'b'); hold on;
                plot(diff(ML.allCodeTimes),'r--');
                ylabel('Difference in  succesive event times (ms)');

                subplot(212);
                plot(1000*diff(digitalTimeStamps)-diff(ML.allCodeTimes));
                ylabel('Difference in ML and OBCI code times (ms)');
                xlabel('Event Number');

                % Stimulus Onset 
                stimPos = find(digitalEvents==9);
                stimPosCorrectedTrials = stimPos(trialErrorCodes==0); %only the trials with trialErrorCode=0 are correct trials.
                goodStimTimes = digitalTimeStamps(stimPos+1); % the digital event after the trial start event is the one that marks the stimulus onset
                goodStimTimesCorrectedTrials = digitalTimeStamps(stimPosCorrectedTrials+1);
                stimNumbers = digitalEvents(stimPos+1);
                stimNumbersCorrectedTrials = digitalEvents(stimPosCorrectedTrials+1);
            end

            StartPos = find(digitalEvents==9);
            startTimes = digitalTimeStamps(StartPos);
            EndPos = find(digitalEvents==18);
            endTimes = digitalTimeStamps(EndPos);

            %folderStringName = fullfile(folderSourceString,'AnalysisDetails',subjectName,expDate,protocolName,'Analysis');
            %makeDirectory(folderStringName);
            %save(fullfile(folderStringName,'startTimes.mat'),'startTimes');
            %save(fullfile(folderStringName,'endTimes.mat'),'endTimes');

            folderExtract = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName,'extractedData');
            getStimResultsMLOBCI(folderExtract,stimNumbersCorrectedTrials);
            goodStimNums=1:length(stimNumbersCorrectedTrials);
            getDisplayCombinationsGRF(folderExtract,goodStimNums); % Generates parameterCombinations
            save(fullfile(folderExtract,'digitalEvents.mat'),'digitalTimeStamps','digitalEvents');

            getEEGDataOBCINoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimesCorrectedTrials,timeStartFromBaseLine,deltaT,electrodeLabels);

        end
    
    %% SF-ORI protocol for BrainProducts
    if strcmpi(protocolName,'GRF_006')
        timeStartFromBaseLineList(1) = -0.55; deltaTList(1) = 1.024; % in seconds
        timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
        timeStartFromBaseLineList(3) = -1.5; deltaTList(3) = 4.096;

        type = stimTypes{extractTheseIndices(iProt)};
        deltaT = deltaTList(type);
        timeStartFromBaseLine = timeStartFromBaseLineList(type);
        ML = saveMLDataNoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType);
        % Extract the trial error codes from the saved ML data
        folderName = fullfile(folderSourceString,'data',[subjectName 'NoiseFiltered'],gridType,expDate,protocolName);
        folderExtract = fullfile(folderName,'extractedData');
        trialError = load(fullfile(folderExtract,'ML.mat'), 'data');
        trialError = trialError.data;
        trialErrorCodes = zeros(1, length(trialError));
        for i=1:length(trialError)
            trialErrorCodes(i) = trialError(i).TrialError;
        end	
        % Read digital data from BrainProducts
        [digitalTimeStamps,digitalEvents]=extractDigitalDataBrainProductsNoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,5);
        % Compare ML behavior and BP files
        if ~isequal(ML.allCodeNumbers,digitalEvents)
            error('Digital and ML codes do not match');
        else
            disp('Digital and ML codes match!');
            clf;
            subplot(211);
            plot(1000*diff(digitalTimeStamps),'b'); hold on;
            plot(diff(ML.allCodeTimes),'r--');
            ylabel('Difference in  succesive event times (ms)');

            subplot(212);
            plot(1000*diff(digitalTimeStamps)-diff(ML.allCodeTimes));
            ylabel('Difference in ML and BP code times (ms)');
            xlabel('Event Number');

            % Stimulus Onset
            stimPos = find(digitalEvents==9);
            stimPosCorrectedTrials = stimPos(trialErrorCodes==0);
            goodStimTimes = digitalTimeStamps(stimPos+1);
            goodStimTimesCorrectedTrials = digitalTimeStamps(stimPosCorrectedTrials+1);
            stimNumbers = digitalEvents(stimPos+1);
            stimNumbersCorrectedTrials = digitalEvents(stimPosCorrectedTrials+1);
        end

        StartPos = find(digitalEvents==9);
        startTimes = digitalTimeStamps(StartPos);
        EndPos = find(digitalEvents==18);
        endTimes = digitalTimeStamps(EndPos);

%         folderStringName = fullfile(folderSourceString,'AnalysisDetails',[subjectName 'NoiseFiltered'],expDate,protocolName,'Analysis');
%         makeDirectory(folderStringName);
%         save(fullfile(folderStringName,'startTimes.mat'),'startTimes');
%         save(fullfile(folderStringName,'endTimes.mat'),'endTimes');
        save(fullfile(folderExtract,'digitalEvents.mat'),'digitalTimeStamps','digitalEvents');

        getStimResultsMLOBCI(folderExtract,stimNumbersCorrectedTrials);
        goodStimNums=1:length(stimNumbersCorrectedTrials);
        getDisplayCombinationsGRF(folderExtract,goodStimNums); % Generates parameterCombinations
        getEEGDataBrainProductsNoiseFiltered(subjectName,expDate,protocolName,folderSourceString,gridType,goodStimTimesCorrectedTrials,timeStartFromBaseLine,deltaT);



    end
    
    
end
