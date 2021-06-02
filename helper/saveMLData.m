% This program reads and saves data from MonkeyLogic. It has a similar
% function as saveLLData that reads from the Lablib data file. However,
% this program is much simpler because ML is run in a very simple way, as
% explained below:

% ML is used mainly for auditory or meditation experiments. Therefore, the
% subjects do not do any task. Even if they have to do a fixation task, the
% eyes are tracked and the out-of-fixation trials are rejected offline
% later. Therefore, all stimuli are used.

function ML = saveMLData(subjectName,expDate,protocolName,folderSourceString,gridType,folderDestinationString)

if ~exist('folderDestinationString','var'); folderDestinationString=folderSourceString; end

fileName = fullfile(folderSourceString,'data','rawData',[subjectName expDate],[subjectName expDate protocolName '.bhv2']);

if ~exist(fileName,'file')
    error('ML data file does not exist');
else
    disp('Working on ML data file ...');
    folderName    = fullfile(folderDestinationString,'data',subjectName,gridType,expDate,protocolName);
    folderExtract = fullfile(folderName,'extractedData');
    makeDirectory(folderExtract);
    
    [ML,data,MLConfig,TrialRecord] = getStimResultsMLGRF(fileName);
    save(fullfile(folderExtract,'ML.mat'),'ML','data','MLConfig','TrialRecord');
end
end

function [ML,data,MLConfig,TrialRecord] = getStimResultsMLGRF(fileName)

[data,MLConfig,TrialRecord] = mlread(fileName);

numTrials = length(data);

allCodeTimes = [];
allCodeNumbers=[];
allStimulusIndex = [];
allTrialNumbers=[];

for i=1:numTrials
    cT=data(i).BehavioralCodes.CodeTimes + data(i).AbsoluteTrialStartTime;
    cN=data(i).BehavioralCodes.CodeNumbers;
    allCodeTimes = cat(2,allCodeTimes,cT');
    allCodeNumbers = cat(2,allCodeNumbers,cN');
    allStimulusIndex = cat(2,allStimulusIndex,1:length(cN));  
    allTrialNumbers = cat(2,allTrialNumbers,zeros(1,length(cN))+i); 
end

ML.allCodeTimes = allCodeTimes;
ML.allCodeNumbers = allCodeNumbers;
ML.allStimulusIndex = allStimulusIndex;
ML.allTrialNumbers = allTrialNumbers;
end