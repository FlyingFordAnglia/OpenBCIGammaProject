% This program preps the spectral data for plotting Figure 3 and getting
% subjects for whom stimulus and baseline was significantly different in
% the three frequency bands

clear allOBCIclosed allOBCIopen allBPclosed allBPopen
clear alphaStOBCI alphaBlOBCI sgammaStOBCI sgammaBlOBCI fgammaStOBCI fgammaBlOBCI
clear alphaStBP alphaBlBP sgammaStBP sgammaBlBP fgammaStBP fgammaBlBP XdeltaPOBCIFreqWise YdeltaPBPFreqWise
clear stPowerOBCIall blPowerOBCIall stPowerBPall blPowerBPall

gridType='EEG'; 
folderSourceString='C:\Users\srivi\Documents\T1\Primate Research Laboratory';
folderOutString='C:\Users\srivi\Documents\T1\Primate Research Laboratory';

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
electrodeLabels = ["O1","O2","T5","P3","Pz","P4","T6","Ref"];
% analyseTheseIndices = 1:30;

bipolarEEGChannelsStored(1,:) = [3 4 8 6 7];
bipolarEEGChannelsStored(2,:) = [1 1 5 2 2];
stRange = [0.2 0.95];
blRange = [-0.75 -0];

allSubjects = unique(subjectNames);

alphaRange=[8 13];
slowGammaRange=[20 34];
fastGammaRange=[35 66];
allOBCIclosed = [];
allOBCIopen = [];
allBPclosed = [];
allBPopen = [];
alphaStOBCI = [];
alphaBlOBCI = [];
sgammaStOBCI = [];
sgammaBlOBCI = [];
fgammaStOBCI = [];
fgammaBlOBCI = [];
alphaStBP = [];
alphaBlBP = [];
sgammaStBP = [];
sgammaBlBP = [];
fgammaStBP = [];
fgammaBlBP = [];
XdeltaPOBCIFreqWise = [];
YdeltaPBPFreqWise = [];
stPowerOBCIall = [];
blPowerOBCIall = [];
stPowerBPall = [];
blPowerBPall = [];

stimVsbase = table();
totalSub = 11;
for nsub=1:totalSub
    x = protocolNames(contains(subjectNames,allSubjects(nsub)));
    n1 = find(x == "GRF_001"); 
    n2 = find(x == "GRF_002");
    n3 = find(x == "GRF_004");
    n4 = find(x == "GRF_005");
    n5 = find(x == "GRF_003");
    n6 = find(x == "GRF_006");

    eyeOpenOBCI = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n1).unipolarAnalysis.PowerVsFreqUnipolar;
    grf_001freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n1).unipolarAnalysis.freqValsUnipolar;
    
    eyeClosedOBCI = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n2).unipolarAnalysis.PowerVsFreqUnipolar;
    grf_002freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n2).unipolarAnalysis.freqValsUnipolar;
    
    eyeOpenBP = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n3).unipolarAnalysis.PowerVsFreqUnipolar;
    grf_004freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n3).unipolarAnalysis.freqValsUnipolar;
    
    eyeClosedBP = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n4).unipolarAnalysis.PowerVsFreqUnipolar;
    grf_005freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n4).unipolarAnalysis.freqValsUnipolar;
    
    sforiOBCIst = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n5).bipolarAnalysis.stPowerVsFreqBipolar;
    grf_003freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n5).bipolarAnalysis.freqValsBipolar;
    
    sforiOBCIbl = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n5).bipolarAnalysis.blPowerVsFreqBipolar;
    grf_003badtrial = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n5).badTrials.badTrials;
    
    sforiBPst = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n6).bipolarAnalysis.stPowerVsFreqBipolar;
    grf_006freq = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n6).bipolarAnalysis.freqValsBipolar;
    
    sforiBPbl = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n6).bipolarAnalysis.blPowerVsFreqBipolar;
    grf_006badtrial = allSubjectDataNoiseFiltered(nsub).allProtocolsData(n6).badTrials.badTrials;

    
    eyeOpenOBCI = mean(mean(log10(eyeOpenOBCI), 3), 1);
    eyeOpenOBCI = sum(eyeOpenOBCI(:, and(grf_001freq >= alphaRange(1), grf_001freq <= alphaRange(2))));
    allOBCIopen = [allOBCIopen eyeOpenOBCI];
    
    eyeClosedOBCI = mean(mean(log10(eyeClosedOBCI), 3), 1);
    eyeClosedOBCI = sum(eyeClosedOBCI(:, and(grf_002freq >= alphaRange(1), grf_002freq <= alphaRange(2))));
    allOBCIclosed = [allOBCIclosed eyeClosedOBCI];
    
    eyeOpenBP = mean(mean(log10(eyeOpenBP), 3), 1);
    eyeOpenBP = sum(eyeOpenBP(:, and(grf_004freq >= alphaRange(1), grf_004freq <= alphaRange(2))));
    allBPopen = [allBPopen eyeOpenBP];
    
    eyeClosedBP = mean(mean(log10(eyeClosedBP), 3), 1);
    eyeClosedBP = sum(eyeClosedBP(:, and(grf_005freq >= alphaRange(1), grf_005freq <= alphaRange(2))));
    allBPclosed = [allBPclosed eyeClosedBP];
    
    sforiOBCIst = sforiOBCIst(:, :, setdiff(1:size(sforiOBCIst, 3), grf_003badtrial));
    trialWiseOBCIst = squeeze(mean(log10(sforiOBCIst),1));
    sforiOBCIst = mean(mean(log10(sforiOBCIst), 3), 1);
    stPowerOBCIall = [stPowerOBCIall; sforiOBCIst];
    grf_003st = sum(sforiOBCIst(:, and(grf_003freq >= alphaRange(1), grf_003freq <= alphaRange(2))));
    alphaStOBCI = [alphaStOBCI grf_003st];
    grf_003st = sum(sforiOBCIst(:, and(grf_003freq >= slowGammaRange(1), grf_003freq <= slowGammaRange(2))));
    sgammaStOBCI = [sgammaStOBCI grf_003st];
    grf_003st = sum(sforiOBCIst(:, and(grf_003freq >= fastGammaRange(1), grf_003freq <= fastGammaRange(2))));
    fgammaStOBCI = [fgammaStOBCI grf_003st];
    
    sforiOBCIbl = sforiOBCIbl(:, :, setdiff(1:size(sforiOBCIbl, 3), grf_003badtrial));
    trialWiseOBCIbl = squeeze(mean(log10(sforiOBCIbl),1));
    sforiOBCIbl = mean(mean(log10(sforiOBCIbl), 3), 1);
    blPowerOBCIall = [blPowerOBCIall; sforiOBCIbl];

    grf_003bl = sum(sforiOBCIbl(:, and(grf_003freq >= alphaRange(1), grf_003freq <= alphaRange(2))));
    alphaBlOBCI = [alphaBlOBCI grf_003bl];
    grf_003bl = sum(sforiOBCIbl(:, and(grf_003freq >= slowGammaRange(1), grf_003freq <= slowGammaRange(2))));
    sgammaBlOBCI = [sgammaBlOBCI grf_003bl];
    grf_003bl = sum(sforiOBCIbl(:, and(grf_003freq >= fastGammaRange(1), grf_003freq <= fastGammaRange(2))));
    fgammaBlOBCI = [fgammaBlOBCI grf_003bl];
    
    sforiBPst = sforiBPst(:, :, setdiff(1:size(sforiBPst, 3), grf_006badtrial));
    trialWiseBPst = squeeze(mean(log10(sforiBPst),1));
    sforiBPst = mean(mean(log10(sforiBPst), 3), 1);
    stPowerBPall = [stPowerBPall; sforiBPst];

    grf_006st = sum(sforiBPst(:, and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2))));
    alphaStBP = [alphaStBP grf_006st];
    grf_006st = sum(sforiBPst(:, and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2))));
    sgammaStBP = [sgammaStBP grf_006st];
    grf_006st = sum(sforiBPst(:, and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2))));
    fgammaStBP = [fgammaStBP grf_006st];
    
    sforiBPbl = sforiBPbl(:, :, setdiff(1:size(sforiBPbl, 3), grf_006badtrial));
    trialWiseBPbl = squeeze(mean(log10(sforiBPbl),1));
    sforiBPbl = mean(mean(log10(sforiBPbl), 3), 1);
    blPowerBPall = [blPowerBPall; sforiBPbl];

    grf_006bl = sum(sforiBPbl(:, and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2))));
    alphaBlBP = [alphaBlBP grf_006bl];
    grf_006bl = sum(sforiBPbl(:, and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2))));
    sgammaBlBP = [sgammaBlBP grf_006bl];
    grf_006bl = sum(sforiBPbl(:, and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2))));
    fgammaBlBP = [fgammaBlBP grf_006bl];
    
    % baseline subtracted PSD during stimulus at every frequency for
    % OpenBCI in dB
    XdeltaPOBCIFreqWise = [XdeltaPOBCIFreqWise; 10*(sforiOBCIst - sforiOBCIbl)];
    
    % baseline subtracted PSD during stimulus at every frequency for
    % Brain Products in dB
    YdeltaPBPFreqWise = [YdeltaPBPFreqWise; 10*(sforiBPst - sforiBPbl)];
    deltaPalphaOBCI = alphaStOBCI - alphaBlOBCI;
    deltaPalphaBP = alphaStBP - alphaBlBP;
   
    % trial wise average band power of stimulus and baseline for the three
    % frequency bands for OpenBCI and Brain Products
    alphaTrialWiseOBCIst = sum(trialWiseOBCIst(and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2)),:));
    alphaTrialWiseOBCIbl = sum(trialWiseOBCIbl(and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2)),:));
    alphaTrialWiseBPst = sum(trialWiseBPst(and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2)),:));
    alphaTrialWiseBPbl = sum(trialWiseBPbl(and(grf_006freq >= alphaRange(1), grf_006freq <= alphaRange(2)),:));
    slowGammaTrialWiseOBCIst = sum(trialWiseOBCIst(and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2)),:));
    slowGammaTrialWiseOBCIbl = sum(trialWiseOBCIbl(and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2)),:));
    fastGammaTrialWiseOBCIst = sum(trialWiseOBCIst(and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2)),:));
    fastGammaTrialWiseOBCIbl = sum(trialWiseOBCIbl(and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2)),:));
    slowGammaTrialWiseBPst = sum(trialWiseBPst(and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2)),:));
    slowGammaTrialWiseBPbl = sum(trialWiseBPbl(and(grf_006freq >= slowGammaRange(1), grf_006freq <= slowGammaRange(2)),:));
    fastGammaTrialWiseBPst = sum(trialWiseBPst(and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2)),:));
    fastGammaTrialWiseBPbl = sum(trialWiseBPbl(and(grf_006freq >= fastGammaRange(1), grf_006freq <= fastGammaRange(2)),:));
    
    % using ranksum test to see if PSD of st and bl are significantly different in
    % each subject in alpha, sgamma, fgamma in OBCI and BP
    [pOBCIslowGamma,hOBCIslowGamma] = ranksum(slowGammaTrialWiseOBCIst', slowGammaTrialWiseOBCIbl','tail','right');
    [pOBCIfastGamma,hOBCIfastGamma] = ranksum(fastGammaTrialWiseOBCIst', fastGammaTrialWiseOBCIbl','tail','right');
    [pBPslowGamma,hBPslowGamma] = ranksum(slowGammaTrialWiseBPst', slowGammaTrialWiseBPbl','tail','right');
    [pBPfastGamma,hBPfastGamma] = ranksum(fastGammaTrialWiseBPst', fastGammaTrialWiseBPbl','tail','right');
    [pOBCIalpha,hOBCIalpha] = ranksum(alphaTrialWiseOBCIst', alphaTrialWiseOBCIbl','tail','left');
    [pBPalpha,hBPalpha] = ranksum(alphaTrialWiseBPst', alphaTrialWiseBPbl','tail','left');

    stimVsbase(nsub,:) = {pOBCIalpha,pOBCIslowGamma,pOBCIfastGamma,pBPalpha,pBPslowGamma,pBPfastGamma};
end
%[corrected_p, h]=bonf_holm(table2array(stimVsbase),0.05);

% Controlling False Discovery rate using BH method
format long;
[h, corrected_p, adj_ci_cvrg, adj_p]=fdr_bh(table2array(stimVsbase),0.05);

stimVsbasep = array2table(adj_p);
stimVsbaseh = array2table(h);
stimVsbasep.Properties.VariableNames = {'OBCIalpha','OBCIslowGamma','OBCIfastGamma','BPalpha','BPslowGamma','BPfastGamma'};
stimVsbaseh.Properties.VariableNames = {'OBCIalpha','OBCIslowGamma','OBCIfastGamma','BPalpha','BPslowGamma','BPfastGamma'};
stimVsbasep.Properties.RowNames = {'S5','S4','S7','S2','S10','S11','S8','S1','S3','S9','S6'};
stimVsbaseh.Properties.RowNames = {'S5','S4','S7','S2','S10','S11','S8','S1','S3','S9','S6'};


subjectsWithAlphaResponseBP = find(table2array(stimVsbaseh(:,4)) == true);
subjectsWithSlowGammaResponseBP = find(table2array(stimVsbaseh(:,5)) == true);
subjectsWithFastGammaResponseBP = find(table2array(stimVsbaseh(:,6)) == true);

subjectsWithAllThreeBands =  [2 4 8 9];
disp(stimVsbasep);
disp(stimVsbaseh);
% 
% % p vals less than 0.05 are colored green
% fig = uifigure();
% uit = uitable(fig);
% uit.Data = stimVsbasep;
% styleIndices = table2array(stimVsbasep) < 0.05;
% [row,col] = find(styleIndices);
% s = uistyle('BackgroundColor','#a9e8ba');
% addStyle(uit,s,'cell',[row,col]);