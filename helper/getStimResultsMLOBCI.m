% This program takes the stimulus numbers (1-12) and gives out values which indicate which SF and Ori type each stimulus belongs to.

function getStimResultsMLOBCI(folderExtract,stimNumbers)

dummyList = zeros(1,length(stimNumbers));
stimResults.azimuth = dummyList;
stimResults.elevation = dummyList;
stimResults.contrast = dummyList;
stimResults.temporalFrequency = dummyList;
stimResults.radius = dummyList;
stimResults.sigma = dummyList;
stimNumbers = stimNumbers - 19;
quotientVals = floor(stimNumbers./4);
remVals = mod(stimNumbers, 4);
stimResults.orientation = remVals;
stimResults.spatialFrequency = quotientVals;

save(fullfile(folderExtract,'stimResults.mat'),'stimResults');
end