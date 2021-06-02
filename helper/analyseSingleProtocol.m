% This function analyses each protocol for a given subject.
function [stPowerVsFreq,blPowerVsFreq,freqVals,tfPower,timeValsTF,freqValsTF,erp]=analyseSingleProtocol(eegData,timeVals,stRange,blRange,params,referenceType,analogChannelsStored,commonBadElecs,bipolarEEGChannels,protocolType)
%The input arguments are these:
% eegData: (array sized nElec * nTrials * timeVals)
% timeVals: from lfpInfo.mat
% stRange and blRange is the times for stimulus and baseline periods when stimulus is starting at t=0
% params (optional) are the parameters for multitaper analysis.
% referenceType: (string) unipolar OR bipolar
% analogChannelsStored: from lfpInfo
% commonBadElecs(optional): list of bad electrodes
% bipolarEEGChannels: (list of lists) detailing which electrodes are part of the bipolar pairs
% protocolType: (string) 'sfori' or 'notsfori'

if ~exist('stRange','var') || isempty(stRange); stRange = [0.1 0.95]; end
if ~exist('blRange','var') || isempty(blRange); blRange = [-0.95 -0.1]; end
if ~exist('params','var'); params=[]; end
if ~exist('bipolarEEGChannels','var') || isempty(bipolarEEGChannels)
    bipolarEEGChannels(1,:) = [3 4 8 6 7];
    bipolarEEGChannels(2,:) = [1 1 5 2 2];
end
if ~exist('commonBadElecs','var'); commonBadElecs = []; end
if ~exist('protocolType','var'); protocolType = 'sfori'; end

Fs = round(1 / (timeVals(2) - timeVals(1)));  % sampling frequency for the EEG

% get stimulus and baseline positions
if round(diff(blRange) * Fs) ~= round(diff(stRange) * Fs)
    disp('baseline and stimulus ranges are not the same');
else
    range = blRange;
    rangePos = round(diff(range) * Fs);  % number of samples in bl/stRange
    blPos = find(timeVals >= blRange(1),1) + (1:rangePos);  % positions for the baseline period
    stPos = find(timeVals >= stRange(1),1) + (1:rangePos);  % positions for the stimulus period
end


% set multitaper parameters
if ~exist('params','var') || isempty(params)
    params.tapers   = [1 1];
    params.pad      = -1;
    params.Fs       = Fs;
    params.fpass    = [];
    params.trialave = 0;
end

movingwin = [0.32 0.032];  % to calculate t-f spectrogram (window size, step size)

% removing bad electrodes
unipolarEEGChannelsStored = setdiff(analogChannelsStored,commonBadElecs);
badIndices = [];
for i = commonBadElecs  % find all bipolar pairs where one of the electrodes is a bad electrode
    badIndices = [badIndices find(bipolarEEGChannels(1,:)==i)];
    badIndices = [badIndices find(bipolarEEGChannels(2,:)==i)];
end
badIndices = unique(badIndices);
bipolarEEGChannels =  bipolarEEGChannels(:, setdiff(1:5, badIndices));  % remove the bad pairs
% high pass filtering (not needed)
% Fc = 1;
% [b,a] = butter(4,Fc/(Fs/2),'high');

%% get ERP, PSD and Time-Frequency spectrogram from eegData:

% all the spectral powers are trial-wise, i.e. NOT averaged across trials or electrodes or SF Ori combinations;
% ERP is for all trials, i.e. all 12 SF Ori combinations
% TODO: remove bad trials for erp.
    if strcmpi(referenceType,'unipolar')
        for iElec = unipolarEEGChannelsStored
            clear analogData
            analogData = eegData(iElec,:,:);
            analogData = squeeze(analogData);  % single electrode data
            %analogData = filtfilt(b,a,analogData);  % only needed with high-pass filtering
            if strcmpi(protocolType,'sfori')
                % correct for DC Shift (baseline correction)
                erp(iElec,:) = mean((analogData - repmat(mean(analogData(:,blPos),2),1,size(analogData,2))),1); %#ok<*AGROW>
                analogData = detrend(analogData);
                [tfPower(iElec,:,:,:),timeValsTF0,freqValsTF] = mtspecgramc(analogData',movingwin,params);  % perform multitaper spectral analysis
                timeValsTF = timeValsTF0 + timeVals(1);  % zero-centering (start of the stimulus at zero)
                stPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(analogData(:,stPos))' ,params);
                blPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(analogData(:,blPos))',params);
            
                if ~isempty(analogData)  % perhaps not needed
                    [~,freqVals]= mtspectrumc(squeeze(analogData(1,stPos))',params);
                else
                    [~,freqVals]= mtspectrumc(squeeze(analogData(:,stPos))',params);
                end
            else
                analogData = detrend(analogData);
                stPowerVsFreq(iElec,:,:) = mtspectrumc(analogData',params);
                [~,freqVals] = mtspectrumc(analogData',params);
                blPowerVsFreq = [];  % these parameters are not needed in non SFOri protocols
                timeValsTF = [];
                tfPower = [];
                freqValsTF = [];
                erp = [];
            end
        end

    end    

    if strcmpi(referenceType,'bipolar')
        for iElec = 1:length(bipolarEEGChannels)
            clear electrode1 electrode2
            electrode1 = eegData(bipolarEEGChannels(1,iElec),:,:);
            electrode2 = eegData(bipolarEEGChannels(2,iElec),:,:);
            bipolarAnalogData = electrode1 - electrode2;
            bipolarAnalogData = squeeze(bipolarAnalogData);

            if strcmpi(protocolType,'sfori')
                % most of the code is same as in the unipolar case
                erp(iElec,:) = mean((bipolarAnalogData - repmat(mean(bipolarAnalogData(:,blPos),2),1,size(bipolarAnalogData,2))),1);
                bipolarAnalogData = detrend(bipolarAnalogData);
                %bipolarAnalogData = filtfilt(b,a,bipolarAnalogData); % needed for highpass only
                [tfPower(iElec,:,:,:),timeValsTF0,freqValsTF] = mtspecgramc(bipolarAnalogData',movingwin,params);
                timeValsTF = timeValsTF0 + timeVals(1);
                stPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(bipolarAnalogData(:,stPos))',params);
                blPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(bipolarAnalogData(:,blPos))',params);

                if ~isempty(bipolarAnalogData)
                    [~,freqVals]= mtspectrumc(squeeze(bipolarAnalogData(1,stPos))',params);
                else
                    [~,freqVals]= mtspectrumc(squeeze(bipolarAnalogData(:,stPos))',params);
                end
            else
                bipolarAnalogData = detrend(bipolarAnalogData);

                stPowerVsFreq(iElec,:,:)= mtspectrumc(bipolarAnalogData',params);
                [~,freqVals] = mtspectrumc(bipolarAnalogData',params);
                blPowerVsFreq = [];
                timeValsTF =[];
                tfPower = [];
                freqValsTF =[];
                erp =[];

            end

        end

    end    
end
