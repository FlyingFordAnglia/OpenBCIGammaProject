
%% number of electrodes rejected in each subject
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);
analyseTheseSubjects = [1:11];
allSubjects = allSubjects(analyseTheseSubjects);

for iSub = 1:length(allSubjects)
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");

    commonBadElecsOBCI = unique([allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nOBCI).badTrials.badElecs.flatPSDElecs,allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nOBCI).badTrials.badElecs.noisyElecs',allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nOBCI).badTrials.badElecs.badImpedanceElecs]);
    disp(['Subject ID ' num2str(iSub) ' OBCI']);
    disp(commonBadElecsOBCI);

    commonBadElecsBP = unique([allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nBP).badTrials.badElecs.flatPSDElecs,allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nBP).badTrials.badElecs.noisyElecs',allSubjectDataNoiseFiltered(1,iSub).allProtocolsData(1,nBP).badTrials.badElecs.badImpedanceElecs]);
    disp(['Subject ID ' num2str(iSub) ' BP']);
    disp(commonBadElecsBP);


end


%% average total trials
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);
analyseTheseSubjects = [1:11];
allSubjects = allSubjects(analyseTheseSubjects);
avgT = [];
for iSub = 1:11
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");

    totalTrialsOBCI = size(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.stPowerVsFreqBipolar);
    totalTrialsBP = size(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.stPowerVsFreqBipolar);
    avg = (totalTrialsBP(3) + totalTrialsOBCI(3))/ 2;
    avgT = [avgT avg];
    
end
disp(['Mean number of trials per session per subject is ' num2str(mean(avgT))]);
disp(['STD is ' num2str(std(avgT))]);

%% mean bad trials 
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);
analyseTheseSubjects = [1:11];
allSubjects = allSubjects(analyseTheseSubjects);
badTrialsOBCIAll = [];
badTrialsBPAll = [];
for iSub = 1:11
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    badTrailsOBCI = length(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).badTrials.badTrials);
    badTrailsBP = length(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).badTrials.badTrials);
    badTrialsOBCIAll = [badTrialsOBCIAll badTrailsOBCI];
    badTrialsBPAll = [badTrialsBPAll badTrailsBP];
end

disp('Percentage trials rejected for OpenBCI (mean,std):');
disp([mean(badTrialsOBCIAll),std(badTrialsOBCIAll)] * 100/(mean(avgT)));
disp('Percentage trials rejected for BP (mean,std):');
disp([mean(badTrialsBPAll),std(badTrialsBPAll)] * 100/(mean(avgT)));
