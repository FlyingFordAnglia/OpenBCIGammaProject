% This function converts the 1-D digital codes for all the 12 stimuli (19:30)
% into 2-D codes with orientation (0,1,2,3) and spatial frequency
% (0,1,2) components based on the sequence in which they are saved in the
% monkeylogic conditions file.

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