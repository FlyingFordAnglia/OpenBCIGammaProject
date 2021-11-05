% This program requires analyseAllDataNoiseFiltered obtained by running analyseAllDataNoiseFiltered.m

%analyseAllData;
%analyseAllDataNoiseFiltered;
clearvars -except allSubjectDataNoiseFiltered allSubjectData;


freqVals = allSubjectDataNoiseFiltered(1).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;

deltaPVsFreqOBCIAllSub = [];
deltaPVsFreqBPAllSub = [];
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);


for iSub = 1:length(allSubjectDataNoiseFiltered)
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");

    stPowerOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.stPowerVsFreqBipolar;
    blPowerOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar;
    stPowerBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.stPowerVsFreqBipolar;
    blPowerBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar;
    
    badtrialsOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).badTrials.badTrials;
    badtrialsBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).badTrials.badTrials;
    
    stPowerOBCI = stPowerOBCI(:,:,setdiff(1:size(stPowerOBCI,3),badtrialsOBCI));
    stPowerBP = stPowerBP(:,:,setdiff(1:size(stPowerBP,3),badtrialsBP));
    blPowerOBCI = blPowerOBCI(:,:,setdiff(1:size(blPowerOBCI,3),badtrialsOBCI));
    blPowerBP = blPowerBP(:,:,setdiff(1:size(blPowerBP,3),badtrialsBP));

    stPowerOBCI = mean(mean(log10(stPowerOBCI),3),1);
    stPowerBP = mean(mean(log10(stPowerBP),3),1);
    blPowerOBCI = mean(mean(log10(blPowerOBCI),3),1);
    blPowerBP = mean(mean(log10(blPowerBP),3),1);
    
    deltaPOBCI = 10 * (stPowerOBCI - blPowerOBCI);
    deltaPBP = 10 * (stPowerBP - blPowerBP);
    
    deltaPVsFreqOBCIAllSub = [deltaPVsFreqOBCIAllSub; deltaPOBCI];
    deltaPVsFreqBPAllSub = [deltaPVsFreqBPAllSub; deltaPBP];
        
    
end


[rho, pval] = corr(deltaPVsFreqOBCIAllSub, deltaPVsFreqBPAllSub,'type', 'Spearman','tail','both');

%[pval, rho, crit_corr, est_alpha, seed_state] = mult_comp_perm_corr(deltaPVsFreqOBCIAllSub,deltaPVsFreqBPAllSub,10000,0,0.05,'rank',1);


figure('Color',[1 1 1]);
rd = diag(rho);
pd = diag(pval);

[h, crit_p, adj_ci_cvrg, corrected_p]=fdr_bh(pd,0.05,'pdep');

scatter(freqVals(corrected_p < 0.05), rd(corrected_p < 0.05), 30, 'o', 'filled', 'linewidth', 1, 'MarkerFaceColor', 'g');
hold on
scatter(freqVals(corrected_p >= 0.05), rd(corrected_p >= 0.05), 30, 'o','filled', 'linewidth', 1, 'MarkerFaceColor', 'k');
xlabel('Frequency (Hz)');
ylabel('Correlation Coefficient');
plot(freqVals, rd, 'k', 'linewidth', 0.5,'HandleVisibility','off');
xlim([0 125]);
ylim([-0.5 1.0]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
legend('p-val < 0.05','p-val > 0.05','alpha','sGamma','fGamma','location','northeast','Position',[0.81081736648184,0.133481646273637,0.146456020495303,0.137931034482758])