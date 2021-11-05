% This function takees the eeg data from one protocol and outputs the erp, power
% vs frequency and time frequency spectral decomposition using multitaper
% method

function [stPowerVsFreq,blPowerVsFreq,freqVals,tfPower,timeValsTF,freqValsTF,erp]=analyseSingleProtocol(eegData,timeVals,stRange,blRange,params,referenceType,analogChannelsStored,commonBadElecs,bipolarEEGChannels,protocolType,badTrials)

%The input arguments are these:
%3. referenceType is a string: unipolar OR bipolar
%5. bipolarEEGChannels is a list of lists detailing which electrodes are
%   part of the bipolar pairs

if ~exist('stRange','var') || isempty(stRange); stRange = [0.25 1.0]; end
if ~exist('blRange','var') || isempty(blRange); blRange = [-0.75 -0]; end
if ~exist('params','var'); params=[]; end
if ~exist('bipolarEEGChannels','var') || isempty(bipolarEEGChannels)
    bipolarEEGChannels(1,:) = [3 4 8 6 7];
    bipolarEEGChannels(2,:) = [1 1 5 2 2];
end
if ~exist('commonBadElecs','var'); commonBadElecs = []; end
if ~exist('protocolType','var'); protocolType = 'sfori'; end
% Get stimulus and baseline indices
Fs = round(1/(timeVals(2)-timeVals(1)));
if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
    disp('baseline and stimulus ranges are not the same');
else
    range = blRange;
    rangePos = round(diff(range)*Fs);
    blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
    stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);
end


% Set Multitaper parameters
if ~exist('params','var') || isempty(params)
    params.tapers   = [1 1];
    params.pad      = -1;
    params.Fs       = Fs;
    params.fpass    = [];
    params.trialave = 0;
end

movingwin = [0.25 0.025]; % this is in seconds - gives 4Hz frequency resolution

% removing bad electrodes
unipolarEEGChannelsStored = setdiff(analogChannelsStored,commonBadElecs);
badIndices = [];
commonBadElecs = reshape(commonBadElecs,1,[]);
for i = commonBadElecs
    badIndices = [badIndices find(bipolarEEGChannels(1,:)==i)];
    badIndices = [badIndices find(bipolarEEGChannels(2,:)==i)];
end
badIndices = unique(badIndices);
bipolarEEGChannels =  bipolarEEGChannels(:, setdiff(1:5, badIndices));
% %High pass filtering
% % Fc = 2;
% % [b,a] = butter(5,Fc/(Fs/2),'high');

% Get ERP, PSD and Time-Frequency spectrogram from eegData:

% All the spectral powers are trial-wise, i.e. NOT averaged across trials
% or electrodes or SF Ori combinations;
% ERP is for all trials, i.e. all 12 SF Ori combinations
%% unipolar
    if strcmpi(referenceType,'unipolar')
        for iElec = unipolarEEGChannelsStored
            clear analogData
            analogData = eegData(iElec,:,:);
            analogData = squeeze(analogData);
            %analogData = filtfilt(b,a,analogData);
            if strcmpi(protocolType,'sfori')

                erp(iElec,:) = mean((analogData - repmat(mean(analogData(:,blPos),2),1,size(analogData,2))),1); %#ok<*AGROW> % Correct for DC Shift (baseline correction)
                analogDataFlipped = detrend(analogData');
                analogData = analogDataFlipped';
                [tfPower(iElec,:,:,:),timeValsTF0,freqValsTF] = mtspecgramc(analogData',movingwin,params);
                timeValsTF = timeValsTF0 + timeVals(1);
                stPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(analogData(:,stPos))' ,params);
                blPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(analogData(:,blPos))',params);
            
                if ~isempty(analogData)
                    [~,freqVals]= mtspectrumc(squeeze(analogData(1,stPos))',params);
                else
                    [~,freqVals]= mtspectrumc(squeeze(analogData(:,stPos))',params);
                end
            else
                analogData = detrend(analogData);
                stPowerVsFreq(iElec,:,:)= mtspectrumc(analogData',params);
                [~,freqVals] = mtspectrumc(analogData',params);
                blPowerVsFreq = [];
                timeValsTF =[];
                tfPower = [];
                freqValsTF =[];
                erp =[];
            end
        end

    end    

%% bipolar

    if strcmpi(referenceType,'bipolar')
        for iElec = 1:length(bipolarEEGChannels)
            clear electrode1 electrode2
            electrode1 = eegData(bipolarEEGChannels(1,iElec),:,:);
            electrode2 = eegData(bipolarEEGChannels(2,iElec),:,:);
            bipolarAnalogData = squeeze((electrode1)-(electrode2));
            
            % sfori
            if strcmpi(protocolType,'sfori')
                % removing bad trials
                badtrialSubtractedBipolarAnalogData = (bipolarAnalogData(setdiff(1:size(bipolarAnalogData,1),badTrials),:));
                erp(iElec,:) = mean((badtrialSubtractedBipolarAnalogData - repmat(mean(badtrialSubtractedBipolarAnalogData(:,blPos),2),1,size(badtrialSubtractedBipolarAnalogData,2))),1); % Correct for DC Shift (baseline correction)
                
                %linear detrending after erp. If linear detrending is 
                %not done, the large slow drifts cause large spectral 
                %leakage at low frequencies dominating the signal
                bipolarAnalogDataFlipped = detrend(bipolarAnalogData');
%               bipolarAnalogDataFlipped = locdetrend(bipolarAnalogData',Fs,[0.25 0.025]); %linear detrending after erp. If linear detrending is not done, the large slow drifts cause multitaper to malfunction weirdly
                bipolarAnalogData = bipolarAnalogDataFlipped';
                %bipolarAnalogData = filtfilt(b,a,bipolarAnalogData); % highpass
                
                %TF spectra
                [tfPower(iElec,:,:,:),timeValsTF0,freqValsTF] = mtspecgramc(bipolarAnalogData',movingwin,params);
                timeValsTF = timeValsTF0 + timeVals(1); % centering the stimulus onset at 0
                
                % PSD
                stPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(bipolarAnalogData(:,stPos))',params);
                blPowerVsFreq(iElec,:,:)= mtspectrumc(squeeze(bipolarAnalogData(:,blPos))',params);
        %          freqVals = 0:1/diff(blRange):Fs;
        %          stPowerVsFreq(elec,:,:)= abs(fft(squeeze(bipolarAnalogData(:,stPos))'));
        %          blPowerVsFreq(elec,:,:)= abs(fft(squeeze(bipolarAnalogData(:,blPos))'));

                if ~isempty(bipolarAnalogData)
                    [~,freqVals]= mtspectrumc(squeeze(bipolarAnalogData(1,stPos))',params);
                else
                    [~,freqVals]= mtspectrumc(squeeze(bipolarAnalogData(:,stPos))',params);
                end
            else % eye open eye closed protocols
                bipolarAnalogDataFlipped = detrend(bipolarAnalogData');%linear detrending after erp. If linear detrending is not done, the large slow drifts cause multitaper to malfunction weirdly
%                 bipolarAnalogDataFlipped = locdetrend(bipolarAnalogData',Fs,[0.25 0.025]); %linear detrending after erp. If linear detrending is not done, the large slow drifts cause multitaper to malfunction weirdly
                bipolarAnalogData = bipolarAnalogDataFlipped';
                
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
