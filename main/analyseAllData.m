% This programs takes in the extracted and segmented data of all subjects
% and analyses them to output a struct() which is necessary for all
% downstream analysis and plotting figures.

% The analysis done by this program includes multitaper spectral analysis
% on all protocol data from each subject.

gridType='EEG'; 
folderSourceString='C:\Users\srivi\Documents\T1\Primate Research Laboratory';
folderOutString='C:\Users\srivi\Documents\T1\Primate Research Laboratory';

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;

electrodeLabels = ["O1","O2","T5","P3","Pz","P4","T6","Ref"];

% bipolar electrode pairs
bipolarEEGChannelsStored(1,:) = [3 4 8 6 7];
bipolarEEGChannelsStored(2,:) = [1 1 5 2 2];
stRange = [0.25 0.75];
blRange = [-0.75 -0.25];

allSubjects = unique(subjectNames);
analyseTheseSubjects = [3]; % Only example subject used here
allSubjects = allSubjects(analyseTheseSubjects);
allSubjectData(1,length(allSubjects)) = struct();

for iSub = 1:length(allSubjects)

    allSubjectData(1,iSub).subjectName = allSubjects(iSub);
    protocolNamesSub = protocolNames(contains(subjectNames,allSubjects(iSub)));
    expDatesSub = expDates(contains(subjectNames,allSubjects(iSub)));
    deviceNamesSub = deviceNames(contains(subjectNames,allSubjects(iSub)));
    genderSub = unique(gender(contains(subjectNames,allSubjects(iSub))));
    allSubjectData(1,iSub).allProtocolsData(1,length(protocolNamesSub)) = struct();
    allSubjectData(1,iSub).gender = genderSub{1};
	
    for iProt = 1:length(protocolNamesSub)
        clear elecData
        allSubjectData(1,iSub).allProtocolsData(1,iProt).protocolName = protocolNamesSub(iProt);        
        %allSubjectData(1,iSub).allProtocolsData(1,iProt).expDate = expDatesSub(iProt);
        allSubjectData(1,iSub).allProtocolsData(1,iProt).deviceName = deviceNamesSub(iProt);
		
        if strcmpi(protocolNamesSub(iProt),'GRF_003') || strcmpi(protocolNamesSub(iProt),'GRF_006')
            folderName = fullfile(folderSourceString,'data',allSubjectData(1,iSub).subjectName,gridType,expDatesSub{iProt},protocolNamesSub{iProt});
            folderExtract= fullfile(folderName,'extractedData');
            folderSegment= fullfile(folderName,'segmentedData');
            allSubjectData(1,iSub).allProtocolsData(1,iProt).parameterCombinations = load(fullfile(folderExtract{1,1},'parameterCombinations.mat'),'parameterCombinations');
            allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo = load(fullfile(folderSegment{1,1},'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
            allSubjectData(1,iSub).allProtocolsData(1,iProt).badTrials = load(fullfile(folderSegment{1,1},'badTrials_v5.mat'),'badTrials','badElecs');
            
            for iElec = 1:length(electrodeLabels)
				disp(['elec' num2str(iElec)]);
                clear temp
                temp = load(fullfile(folderSegment{1,1},'LFP',['elec' num2str(iElec) '.mat']),'analogData');
                elecData(iElec,:,:) = temp.analogData; 
            end
			
			% collating all bad electrodes into one list
            commonBadElecs = unique([allSubjectData(1,iSub).allProtocolsData(1,iProt).badTrials.badElecs.flatPSDElecs',allSubjectData(1,iSub).allProtocolsData(1,iProt).badTrials.badElecs.noisyElecs',allSubjectData(1,iSub).allProtocolsData(1,iProt).badTrials.badElecs.badImpedanceElecs']);
            
			timeVals = allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo.timeVals;
            analogChannelsStored = allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo.analogChannelsStored;
            protocolType = 'sfori';
%             [stPowerVsFreqUnipolar,blPowerVsFreqUnipolar,freqValsUnipolar,tfPowerUnipolar,timeValsTFUnipolar,freqValsTFUnipolar,erpUnipolar] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,commonBadElecs,bipolarEEGChannelsStored,protocolType);
%             allSubjectData(1,iSub).allProtocolsData(1,iProt).unipolarAnalysis = struct('stPowerVsFreqUnipolar',stPowerVsFreqUnipolar,'blPowerVsFreqUnipolar',blPowerVsFreqUnipolar,'freqValsUnipolar',freqValsUnipolar,'tfPowerUnipolar',tfPowerUnipolar,'timeValsTFUnipolar',timeValsTFUnipolar,'freqValsTFUnipolar',freqValsTFUnipolar,'erpUnipolar',erpUnipolar);
            
			% multitaper analysis of each protocol
			[stPowerVsFreqBipolar,blPowerVsFreqBipolar,freqValsBipolar,tfPowerBipolar,timeValsTFBipolar,freqValsTFBipolar,erpBipolar] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'bipolar',analogChannelsStored,commonBadElecs,bipolarEEGChannelsStored,protocolType);
            badTrials = allSubjectData(iSub).allProtocolsData(iProt).badTrials.badTrials;
            
			% calculating change in power from baseline in TF spectrogram after removing bad trials
			powerTFmeaned = squeeze(mean(mean(log10(tfPowerBipolar(:,:,:,setdiff(1:size(tfPowerBipolar,4),badTrials))), 4), 1)); %log of trial specific power, then mean across trials, then mean across electrodes
            blPosTF = intersect(find(timeValsTFBipolar >= blRange(1)),find(timeValsTFBipolar < blRange(2)));
            bl = repmat(squeeze(mean(powerTFmeaned(blPosTF, :), 1)), length(timeValsTFBipolar), 1);
            diffTF = 10 * (powerTFmeaned - bl);
            allSubjectData(1,iSub).allProtocolsData(1,iProt).bipolarAnalysis = struct('stPowerVsFreqBipolar',stPowerVsFreqBipolar,'blPowerVsFreqBipolar',blPowerVsFreqBipolar,'freqValsBipolar',freqValsBipolar,'tfPowerBipolar',tfPowerBipolar,'timeValsTFBipolar',timeValsTFBipolar,'freqValsTFBipolar',freqValsTFBipolar,'erpBipolar',erpBipolar,'diffTFPowerDB', diffTF,'timeVals',timeVals);

        else % Eye open eye closed data
            folderName = fullfile(folderSourceString,'data',allSubjectData(1,iSub).subjectName,gridType,expDatesSub{iProt},protocolNamesSub{iProt});
            folderSegment= fullfile(folderName,'segmentedData');
            allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo = load(fullfile(folderSegment{1,1},'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
            for iElec = 1:length(electrodeLabels)
                clear temp
                temp = load(fullfile(folderSegment{1,1},'LFP',['elec' num2str(iElec) '.mat']),'analogData');
                elecData(iElec,:,:) = temp.analogData; 
            end
            %allSubjectData(1,iSub).allProtocolsData(1,iProt).eegData = elecData;
            timeVals = allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo.timeVals;
            analogChannelsStored = allSubjectData(1,iSub).allProtocolsData(1,iProt).lfpInfo.analogChannelsStored;
            protocolType = 'not_sfori';
            [PowerVsFreqUnipolar,~,freqValsUnipolar,~,~,~,~] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,[],bipolarEEGChannelsStored,protocolType);
            allSubjectData(1,iSub).allProtocolsData(1,iProt).unipolarAnalysis = struct('PowerVsFreqUnipolar',PowerVsFreqUnipolar,'freqValsUnipolar',freqValsUnipolar,'timeVals',timeVals);

        end
    end
end

