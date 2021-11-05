% This program requires struct allSubjectDataNoiseFiltered obtained by running allSubjectDataNoiseFiltered.m

%analyseAllDataNoiseFiltered;
clearvars -except allSubjectDataNoiseFiltered allSubjectData;

alphaRange = [8 13];
slowGammaRange = [20 34];
fastGammaRange = [35 66];
freqVals = allSubjectDataNoiseFiltered(1).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;
alphaPos = find(freqVals >= alphaRange(1) & freqVals <= alphaRange(2));
slowGammaPos = find(freqVals >= slowGammaRange(1) & freqVals <= slowGammaRange(2));
fastGammaPos = find(freqVals >= fastGammaRange(1) & freqVals <= fastGammaRange(2));

fig = figure('Position',[18.333333333333332,292.3333333333333,1242,325.6666666666667], 'Color', [1 1 1]);
fontsize = 12;
tickdir = 'both';
ticklength = [0.03 0];

femaleIndices = [];

alphaPOBCIAllSubjects = [];
slowGammaPOBCIAllSubjects = [];
fastGammaPOBCIAllSubjects = [];
alphaPBPAllSubjects = [];
slowGammaPBPAllSubjects = [];
fastGammaPBPAllSubjects = [];

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);

for iSub = 1:length(allSubjectDataNoiseFiltered)
    if strcmpi(allSubjectDataNoiseFiltered(iSub).gender,'F')
        femaleIndices = [femaleIndices iSub];
    end
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
    
    alphaOBCI = mean(deltaPOBCI(alphaPos));
    alphaPOBCIAllSubjects = [alphaPOBCIAllSubjects alphaOBCI];
    alphaBP = mean(deltaPBP(alphaPos));
    alphaPBPAllSubjects = [alphaPBPAllSubjects alphaBP];

    slowGammaOBCI = mean(deltaPOBCI(slowGammaPos));
    slowGammaPOBCIAllSubjects = [slowGammaPOBCIAllSubjects slowGammaOBCI];
    slowGammaBP = mean(deltaPBP(slowGammaPos));
    slowGammaPBPAllSubjects = [slowGammaPBPAllSubjects slowGammaBP];

    fastGammaOBCI = mean(deltaPOBCI(fastGammaPos));
    fastGammaBP = mean(deltaPBP(fastGammaPos));
    fastGammaPOBCIAllSubjects = [fastGammaPOBCIAllSubjects fastGammaOBCI];
    fastGammaPBPAllSubjects = [fastGammaPBPAllSubjects fastGammaBP];

    
end

maleIndices = setdiff([1:length(allSubjectDataNoiseFiltered)],femaleIndices);

%% Alpha 
fig1 = subplot(1,3,1);

%males
scatter(fig1,alphaPOBCIAllSubjects(maleIndices), alphaPBPAllSubjects(maleIndices), 30,'k','o','filled', 'linewidth', 2);
hold on;
%females
scatter(fig1,alphaPOBCIAllSubjects(femaleIndices), alphaPBPAllSubjects(femaleIndices), 30,'k','o', 'linewidth', 2);
xlabel(fig1,'Change in Band Power (dB) OBCI');
ylabel(fig1,'Change in Band Power (dB) BP');
ylimits = ylim;
xlim(ylimits);
ylim(ylimits);
xticks([ylimits(1):ylimits(2)]);
yticks([ylimits(1):ylimits(2)]);
xticklabels([ylimits(1):ylimits(2)]);
yticklabels([ylimits(1):ylimits(2)]);

plot(fig1, ylimits, ylimits,'k-.','linewidth',0.8);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
title(fig1,'Alpha');
[rho, pval] = corr(alphaPOBCIAllSubjects', alphaPBPAllSubjects', 'type', 'Spearman');
disp('correlation coefficient-Spearman, alpha');
disp(rho);
disp('p-value based on permutation test')
disp(pval);

%regression line
%b = regress(alphaPBPAllSubjects', [alphaPOBCIAllSubjects; ones(length(alphaPOBCIAllSubjects))]');
%plot(ylimits,[b(1) * ylimits(1) + b(2), b(1) * ylimits(2) + b(2)],'color','k', 'linewidth',1.2);

%% Slow Gamma
fig2 = subplot(1,3,2);

%males
scatter(fig2,slowGammaPOBCIAllSubjects(maleIndices), slowGammaPBPAllSubjects(maleIndices), 30,'k','o','filled', 'linewidth', 2)
hold on;
%females
scatter(fig2,slowGammaPOBCIAllSubjects(femaleIndices), slowGammaPBPAllSubjects(femaleIndices), 30,'k','o', 'linewidth', 2)
xlim([-1 3]);
ylim([-1 3]);
xticks([-1:3]);
yticks([-1:3]);
xticklabels([-1:3]);
yticklabels([-1:3]);

ylimits = ylim;
plot(fig2, ylimits, ylimits,'k-.','linewidth',0.8);

title(fig2,'Slow Gamma');
[rho, pval] = corr(slowGammaPOBCIAllSubjects', slowGammaPBPAllSubjects','type', 'Spearman');
disp('correlation coefficient-Spearman, slow gamma');
disp(rho);
disp('p-value based on permutation test')
disp(pval);
% xlimits = xlim;
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
% b = regress(slowGammaPBPAllSubjects', [slowGammaPOBCIAllSubjects; ones(length(slowGammaPOBCIAllSubjects))]');
% plot(xlimits,[b(1) * xlimits(1) + b(2), b(1) * xlimits(2) + b(2)],'color','k', 'linewidth',1.2);


%% Fast Gamma
fig3 = subplot(1,3,3);

%males
scatter(fig3,fastGammaPOBCIAllSubjects(maleIndices), fastGammaPBPAllSubjects(maleIndices), 30,'k','o','filled', 'linewidth', 2);
hold on;
%females
scatter(fig3,fastGammaPOBCIAllSubjects(femaleIndices), fastGammaPBPAllSubjects(femaleIndices), 30,'k','o', 'linewidth', 2);
xlim([-1 3]);
ylim([-1 3]);
xticks([-1:3]);
yticks([-1:3]);
xticklabels([-1:3]);
yticklabels([-1:3]);
ylimits = ylim;
plot(fig3, ylimits, ylimits,'k-.','linewidth',0.8);

title(fig3,'Fast Gamma');
[rho, pval] = corr(fastGammaPOBCIAllSubjects', fastGammaPBPAllSubjects','type', 'Spearman');
disp('correlation coefficient-Spearman, fast gamma');
disp(rho);
disp('p-value based on permutation test');
disp(pval);
xlimits = xlim;
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
% b = regress(fastGammaPBPAllSubjects', [fastGammaPOBCIAllSubjects; ones(length(fastGammaPOBCIAllSubjects))]');
% plot(xlimits,[b(1) * xlimits(1) + b(2), b(1) * xlimits(2) + b(2)],'color','k', 'linewidth',1.2);
legend(fig3,'Males','Females','X=Y',  'location','southeast','box','on', 'Position',[0.84621578099839,0.2,0.108158883521202,0.205430327868852]);



%% amplitude change comparison
dataVisualisation;
DeltaBandPowers = table();
figure();
%alpha in subjects who showed significant st different from bl
OBCI = alphaPOBCIAllSubjects(subjectsWithAlphaResponseBP);
BP = alphaPBPAllSubjects(subjectsWithAlphaResponseBP);
[p,h] = ranksum(OBCI',BP','tail', 'both');
%[h,p] = ttest(OBCI',BP','tail', 'both');
DeltaBandPowers(1,:) = {mean(OBCI),std(OBCI),mean(BP),std(BP),p};
fig1 = subplot(1,3,1);
boxplot([OBCI', BP'], 'Labels',{'OBCI','BP'});
title('Alpha')
% slow Gamma
OBCI = slowGammaPOBCIAllSubjects(subjectsWithSlowGammaResponseBP);
BP = slowGammaPBPAllSubjects(subjectsWithSlowGammaResponseBP);
%[h,p] = ttest(OBCI',BP','tail', 'both');
[p,h] = ranksum(OBCI',BP','tail', 'both');
DeltaBandPowers(2,:) = {mean(OBCI),std(OBCI),mean(BP),std(BP),p};
fig2 = subplot(1,3,2);
boxplot([OBCI', BP'], 'Labels',{'OBCI','BP'});
title('Slow Gamma')
% fast Gamma
OBCI = fastGammaPOBCIAllSubjects(subjectsWithFastGammaResponseBP);
BP = fastGammaPBPAllSubjects(subjectsWithFastGammaResponseBP);
%[h,p] = ttest((OBCI'- BP'))
[p,h] = ranksum(OBCI',BP','tail', 'both');
DeltaBandPowers(3,:) = {mean(OBCI),std(OBCI),mean(BP),std(BP),p};
fig3 = subplot(1,3,3);
boxplot([OBCI', BP'], 'Labels',{'OBCI','BP'});
title('Fast Gamma')
DeltaBandPowers.Properties.VariableNames = {'OBCImedian','OBCIIQR','BPmedian','BPIQR','p-val'};
DeltaBandPowers.Properties.RowNames  = {'alpha','slow gamma','fast gamma'};
format short;
disp(DeltaBandPowers);