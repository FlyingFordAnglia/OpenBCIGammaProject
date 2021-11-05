% This is the main program used to find bad trials in EEG data.

% Note: This program was built on top of findBadTrialsEEG_GAV_v2 to _v5.
% This program was used for finding bad trials for 350 subjects who were
% part of ADGammaProject (DVPS Murty et al. 2021).

% badEEGElectrodes: set of EEG electrodes deemed bad from the beginning and not used for any further analysis. 
% nonEEGElectrodes are other analog electrodes that are not considered for bad trial analysis
% capType: Name of the montage. Set to empty for LFP data

function [badTrials,allBadTrials,badTrialsUnique,badElecs,totalTrials,slopeValsVsFreq] = findBadTrialsWithOBCI(subjectName,expDate,protocolName,folderSourceString,gridType,badEEGElectrodes,nonEEGElectrodes,capType,saveDataFlag,badTrialNameStr,displayResultsFlag)

% if ~exist('gridType','var');        gridType = 'EEG';                   end
% if ~exist('badEEGElectrodes','var');  badEEGElectrodes = [];            end
% if ~exist('nonEEGElectrodes','var');  nonEEGElectrodes = [];       end
% if ~exist('impedanceTag','var');    impedanceTag = 'ImpedanceStart';    end
% if ~exist('capType','var');         capType = 'actiCap64';              end
% if ~exist('saveDataFlag','var');    saveDataFlag = 1;                   end
% if ~exist('badTrialNameStr','var'); badTrialNameStr = '_v5';            end
% if ~exist('displayResultsFlag','var'); displayResultsFlag=0;            end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initializations %%%%%%%%%%%%%%%%%%%%%%%%%%%%
highPassCutOff = 1.6; % Hz
checkPeriod = [-0.5 0.75]; % s
ImpedanceCutOff = 25; % KOhm
time_threshold  = 6;
psd_threshold = 6;
badTrialThreshold = 40; % Percentage of bad trials for an electrode to be marked noisy

tapersPSD = 1; % No. of tapers used for computation of slopes
slopeRange = {[56 86]}; % Hz, slope range used to compute slopes
freqsToAvoid = {[0 0] [8 12] [46 54] [96 104]}; % Hz

checkBaselinePeriod = [-0.5 0]; % For computing slopes for artifact rejection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);
folderSegment = fullfile(folderName,'segmentedData');
fileName = fullfile(folderSegment,'LFP','lfpInfo.mat');
lfpInfo = load(fileName);

timeVals = lfpInfo.timeVals;
analogChannelsStored = lfpInfo.analogChannelsStored;
eegChannelsStored = setdiff(analogChannelsStored,nonEEGElectrodes);
numChannelsStored = length(eegChannelsStored);
clear eegData
hW1 = waitbar(0,'collecting data...');
for i=1:numChannelsStored
    iElec = eegChannelsStored(i);
    waitbar((i-1)/numChannelsStored,hW1,['collecting data from electrode: ' num2str(iElec) ' of ' num2str(numChannelsStored)]);
    
    clear x; x = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat'])); % Load EEG Data
    eegData(iElec,:,:) = (x.analogData); %#ok<AGROW>
    eegElectrodeLabels{iElec} = x.analogInfo.labels; %#ok<AGROW>
    
end
close(hW1);
numElectrodes = size(eegData,1);
%%%%%%%%%%%%%%%%%%%%%% Compare with Montage %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(capType)
   x = load([capType 'Labels.mat']); montageLabels = x.montageLabels(:,2);
   if ~isequal(eegElectrodeLabels(:),montageLabels(:))
       error('Montage labels do not match with channel labels');
   else
       highPriorityElectrodeList = getHighPriorityElectrodes(capType);
   end
else
   highPriorityElectrodeList = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Impedance data %%%%%%%%%%%%%%%%%%%%%%%%
[elecImpedanceLabels,elecImpedanceValues] = getImpedanceDataOBCI(subjectName,expDate,folderSourceString);
disp('Impedance Data loaded');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get Eye data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eyeDataDeg,eyeRangeMS,FsEye] = getEyeDataML(folderName);
disp('Eye Data loaded');
%%%%%%%%%%%%%%%%%%%%%%%% Set up MT parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 1/(timeVals(2) - timeVals(1)); %Hz

params.tapers   = [3 5];
params.pad      = -1;
params.Fs       = Fs;
params.fpass    = [0 200];
params.trialave = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%% Bad Trial Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Get bad trials from eye data
if exist('FsEye','var') && ~isempty(FsEye)
    badEyeTrials = findBadTrialsFromEyeData_v2(eyeDataDeg,eyeRangeMS,FsEye,checkPeriod)'; % added by MD 10-09-2017; Modified by MD 03-09-2019
else
    badEyeTrials = [];
end
originalTrialInds = 1:size(eegData,2);
originalTrialInds(badEyeTrials) = [];
clear eyeDataDeg

totalTrials = size(eegData,2);
badTrialsUnique.badEyeTrials = badEyeTrials;


% 2. Get electrode impedances for rejecting noisy electrodes (impedance > 25k)
clear elecInds; elecInds = NaN(1,length(eegElectrodeLabels));
for iML = 1:length(eegElectrodeLabels)
    temp = (eegElectrodeLabels{iML} == elecImpedanceLabels{iML});
    elecInds(iML) = 0 + temp(1);
    %elecInds(iML) = find(strcmp(eegElectrodeLabels(iML),elecImpedanceLabels));

end
%elecImpedanceValues = elecImpedanceValues(elecInds); % Remap the electrodes according to the electrodeList
GoodElec_Z = elecImpedanceValues<ImpedanceCutOff;
GoodElec_Z(badEEGElectrodes)=0; % These electrodes are explicitly labeled as bad. For now they are included in the high-impedance list
nBadElecs{1} = ~GoodElec_Z; % this index is for Selected electrodes

% 3. Analysis for each trial and each electrode
if exist('highPassCutOff','var') || ~isempty(highPassCutOff) % Defining filter
    d1 = designfilt('highpassiir','FilterOrder',8, ...
        'PassbandFrequency',highPassCutOff,'PassbandRipple',0.2, ...
        'SampleRate',Fs);
end

allBadTrials = cell(1,numElectrodes);
hW1 = waitbar(0,'Processing electrodes...');

for iElec=1:numElectrodes    
    waitbar((iElec-1)/numElectrodes,hW1,['Processing electrode: ' num2str(iElec) ' of ' num2str(numElectrodes)]);
    if ~GoodElec_Z(iElec); allBadTrials{iElec} = NaN; continue; end % Analyzing only those electrodes with impedance < 25k
    analogData = squeeze(eegData(iElec,:,:));
    analogData(badEyeTrials,:) = [];
    
    % determine indices corresponding to the check period
    checkPeriodIndices = timeVals>=checkPeriod(1) & timeVals<checkPeriod(2);
    analogData = analogData(:,checkPeriodIndices);
    
    clear analogDataSegment; analogDataSegment = analogData;
    
    if exist('highPassCutOff','var') || ~isempty(highPassCutOff)    % high pass filter
        clear analogData; analogData = filtfilt(d1,analogDataSegment')';
    end
    
    % subtract dc
    analogData = analogData - repmat(mean(analogData,2),1,size(analogData,2));
    
    % Check time-domain waveforms
    numTrials = size(analogData,1);                            % excluding bad eye trials
    meanTrialData = nanmean(analogData,1);                     % mean trial trace
    stdTrialData = nanstd(analogData,[],1);                    % std across trials
    
    tDplus = (meanTrialData + (time_threshold)*stdTrialData);    % upper boundary/criterion
    tDminus = (meanTrialData - (time_threshold)*stdTrialData);   % lower boundary/criterion
    
    tBoolTrials = sum((analogData > ones(numTrials,1)*tDplus) | (analogData < ones(numTrials,1)*tDminus),2);
    
    clear badTrialsTimeThres
    badTrialsTimeThres = find(tBoolTrials>0);
    
    % Check PSD
    clear powerVsFreq;
    [powerVsFreq,~] = mtspectrumc(analogDataSegment',params);
    powerVsFreq = powerVsFreq';
    
    clear meanTrialData stdTrialData tDplus
    meanTrialData = nanmean(powerVsFreq(setdiff(1:size(powerVsFreq,1),badTrialsTimeThres),:),1);                     % mean trial trace
    stdTrialData = nanstd(powerVsFreq(setdiff(1:size(powerVsFreq,1),badTrialsTimeThres),:),[],1);                    % std across trials
    
    tDplus = (meanTrialData + (psd_threshold)*stdTrialData);    % upper boundary/criterion
    clear tBoolTrials; tBoolTrials = sum((powerVsFreq > ones(numTrials,1)*tDplus),2);
    clear badTrialsFreqThres; badTrialsFreqThres = find(tBoolTrials>0);
    
    tmpBadTrialsAll = unique([badTrialsTimeThres;badTrialsFreqThres]);
    
    % Remap bad trial indices to original indices
    allBadTrials{iElec} = originalTrialInds(tmpBadTrialsAll);
    
    % Calculate number of unique bad trials for each thresholding criterion
    badTrialsUnique.timeThres{iElec} = originalTrialInds(badTrialsTimeThres);
    badTrialsUnique.freqThres{iElec} = originalTrialInds(setdiff(badTrialsFreqThres,badTrialsTimeThres));
end
close(hW1);

% 4. Remove electrodes containing more than x% bad trials
badTrialUL = (badTrialThreshold/100)*numTrials;
badTrialLength=cellfun(@length,allBadTrials);
disp(['Bad trial length is:' num2str(badTrialLength)]);
badTrialLength(nBadElecs{1})=NaN; % Removing the bad impedance electrodes
nBadElecs{2} = logical(badTrialLength>badTrialUL)';
allBadTrials(nBadElecs{2}) = {NaN};

% 5. Find common bad trials across all electrodes subject to conditions
commonBadTrialsAllElecs = trimBadTrials(allBadTrials);

% 6. Find common bad trials across visual electrodes
commonBadTrialsVisElecs=[];
for iElec=1:length(highPriorityElectrodeList)
    if ~isnan(allBadTrials{1,highPriorityElectrodeList(iElec)}); commonBadTrialsVisElecs=union(commonBadTrialsVisElecs,allBadTrials{highPriorityElectrodeList(iElec)}); end
end

badTrialsUnique.commonBadTrialsAllElecs = commonBadTrialsAllElecs;
badTrialsUnique.commonBadTrialsVisElecs = commonBadTrialsVisElecs;
badTrials = union(commonBadTrialsVisElecs,commonBadTrialsAllElecs);

% 6. PSD Slope calculation across baseline period
checkPeriodIndicesPSD = timeVals>=checkBaselinePeriod(1) & timeVals<checkBaselinePeriod(2);
params.tapers   = [(tapersPSD+1)/2 tapersPSD];
slopeValsVsFreq = cell(1,numElectrodes);

eegData = eegData(:,setdiff(originalTrialInds,badTrials),checkPeriodIndicesPSD);
for iElec=1:numElectrodes
    if isnan(allBadTrials{1,iElec}); slopeValsVsFreq{iElec} = {NaN,NaN}; goodSlopeFlag(iElec) = false; continue; end %#ok<AGROW>
    
    % Computing slopes
    analogDataPSD = squeeze(eegData(iElec,:,:));
    %         analogDataPSD = analogDataPSD - repmat(mean(analogDataPSD,2),1,size(analogDataPSD,2));
    
    clear powerVsFreq freqVals
    [powerVsFreq,freqVals] = mtspectrumc(analogDataPSD',params);
    slopeValsVsFreq{iElec} = getSlopesPSDBaseline_v2((log10(mean(powerVsFreq,2)))',freqVals,slopeRange,[],freqsToAvoid);
    goodSlopeFlag(iElec) = slopeValsVsFreq{iElec}{2}>0; %#ok<AGROW>
end

nanElecs = find(cell2mat(cellfun(@(x)any(isnan(x)),allBadTrials,'UniformOutput',false))); % MD: 09-09-2019

badElecs.elecImpedance = elecImpedanceValues;
badElecs.badImpedanceElecs = find(nBadElecs{1});
badElecs.noisyElecs = find(nBadElecs{2});
badElecs.flatPSDElecs = setdiff(find(~goodSlopeFlag),nanElecs)';
badElecs.declaredBadElectrodes = badEEGElectrodes;

if saveDataFlag
    disp(['Saving ' num2str(length(union(badTrialsUnique.badEyeTrials,badTrials))) ' bad trials']);
    badTrialsFileName = fullfile(folderSegment,['badTrials' badTrialNameStr '.mat']);
    if exist(badTrialsFileName,'file'); delete(badTrialsFileName); end
    save(badTrialsFileName,'badTrials','allBadTrials','badTrialsUnique','badElecs','totalTrials','slopeValsVsFreq','eegElectrodeLabels','highPriorityElectrodeList','elecImpedanceValues');
else
    disp('Bad trials will not be saved..');
end

if displayResultsFlag
    displayBadElectrodes(subjectName,expDate,protocolName,folderSourceString,gridType,capType,badTrialNameStr);
end
end

function [newBadTrials] =  trimBadTrials(allBadTrials)
badElecThreshold = 10; % Percentage

% a. Taking union across bad electrodes for conditions 1 and 2
newBadTrials=[];
numElectrodes = length(allBadTrials);
for iElec=1:numElectrodes
    if ~isnan(allBadTrials{1,iElec}); newBadTrials=union(newBadTrials,allBadTrials{iElec}); end
end

% b. Co-occurence condition - Counting the trials which occurs in more than x% of the electrodes
badTrialElecs = zeros(1,length(newBadTrials));
for iTrial = 1:length(newBadTrials)
    for iElec = 1:numElectrodes
        if isnan(allBadTrials{1,iElec}); continue; end % Discarding the electrodes where the bad trials are NaN because of this NaN entries in badTrials have zero in 'badTrialElecs'
        if find(newBadTrials(iTrial)==allBadTrials{1,iElec})
            badTrialElecs(iTrial) = badTrialElecs(iTrial)+1;
        end
    end
end
newBadTrials(badTrialElecs<(badElecThreshold/100.*numElectrodes))=[];
end
function [eyeData,eyeRangeMS,FsEye] = getEyeDataML(folderName)

dataFile = fullfile(folderName, 'extractedData', 'ML.mat');
dataMain = load(dataFile, 'data');
eyeData = struct('eyeDataDegX', [], 'eyeDataDegY', []);
FsEye = 1000;
FixationDurationMS = 1000;
StimDurationMS = 1000;
eyeRangeMS = [-FixationDurationMS, StimDurationMS];
eyeTrackDuration = FixationDurationMS + StimDurationMS;
for i=1:length(dataMain.data)
    if dataMain.data(1, i).TrialError == 0
        t1 = dataMain.data(1, i).AnalogData.Eye((end-eyeTrackDuration):end, 1)';
        t2 = dataMain.data(1, i).AnalogData.Eye((end-eyeTrackDuration):end, 2)';
        eyeData.eyeDataDegX = [eyeData.eyeDataDegX; t1];
        eyeData.eyeDataDegY = [eyeData.eyeDataDegY; t2];
    end
end
end
