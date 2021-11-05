% This program requires analyseAllDataNoiseFiltered obtained by running analyseAllDataNoiseFiltered.m

%analyseAllDataNoiseFiltered;
clearvars -except allSubjectDataNoiseFiltered allSubjectData;

figure('Position',[291.6666666666666,41.666666666666664,635.3333333333333,599.3333333333333], 'Color',[1 1 1]);

timeValsTF = allSubjectDataNoiseFiltered(1).allProtocolsData(3).bipolarAnalysis.timeValsTFBipolar;
freqValsTF = allSubjectDataNoiseFiltered(1).allProtocolsData(3).bipolarAnalysis.freqValsTFBipolar;
freqVals = allSubjectDataNoiseFiltered(1).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;
alphaRange = [8 13];
slowGammaRange = [20 34];
fastGammaRange = [35 66];

fontsize = 10;
tickdir = 'out';
ticklength = [0.03 0];

SelfVsCross = table();

alphaTFOBCI = [];
slowGammaTFOBCI = [];
fastGammaTFOBCI = [];
alphaTFBP = [];
slowGammaTFBP = [];
fastGammaTFBP = [];

deltaPVsFreqOBCIAllSub = [];
deltaPVsFreqBPAllSub = [];

subjects = 1:length(allSubjectDataNoiseFiltered);
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);

%subjects = [1 3 6];
for iSub = subjects
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
    deltaPVsFreqOBCIAllSub = [deltaPVsFreqOBCIAllSub; deltaPOBCI(freqVals < 100)];
    deltaPVsFreqBPAllSub = [deltaPVsFreqBPAllSub; deltaPBP(freqVals < 100)];

    diffTFBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.diffTFPowerDB;
    diffTFOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.diffTFPowerDB;
    alphaPowerBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
    slowGammaBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
    fastGammaBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));
    alphaPowerOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
    slowGammaOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
    fastGammaOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));

    alphaTFOBCI = [alphaTFOBCI; alphaPowerOBCI'];
    slowGammaTFOBCI = [slowGammaTFOBCI; slowGammaOBCI'];
    fastGammaTFOBCI = [fastGammaTFOBCI; fastGammaOBCI'];
    alphaTFBP = [alphaTFBP; alphaPowerBP'];
    slowGammaTFBP = [slowGammaTFBP; slowGammaBP'];
    fastGammaTFBP = [fastGammaTFBP; fastGammaBP'];

%     disp(iSub);
%     [r1,p1] = corr(alphaPowerOBCI,alphaPowerBP)
%     pause;
    
end

%% Change in PSD vs Freq

DPSDselfCorr = [];
DPSDselfPvals = [];
DPSDcrossCorr = [];

for iSub = subjects
    [rho, pval] = corr(deltaPVsFreqOBCIAllSub(iSub, :)', deltaPVsFreqBPAllSub(iSub, :)','type','Spearman');

    DPSDselfCorr = [DPSDselfCorr rho];
    DPSDselfPvals = [DPSDselfPvals pval];
    temp = [];
    for j=subjects
        if ~(iSub == j)
            [rho2, pval2] = corr(deltaPVsFreqOBCIAllSub(iSub, :)', deltaPVsFreqBPAllSub(j, :)','type','Spearman');
            temp = [temp rho2];
        end
    end
    DPSDcrossCorr = [DPSDcrossCorr; temp];
end


DPSDcrossCorrMeans = median(DPSDcrossCorr, 2);
DPSDcrossCorrFlat = reshape(DPSDcrossCorr.', 1, []);


fig1 = subplot(4,2,1);
for i=subjects
    scatter(fig1, repmat(DPSDselfCorr(i),1,iSub - 1),DPSDcrossCorr(i,:),'k','filled','MarkerFaceColor','k','MarkerFaceAlpha',0.15)
    hold on

end
scatter(fig1, DPSDselfCorr,  DPSDcrossCorrMeans, 'o','k', 'filled','MarkerFaceColor','k', 'linewidth', 2)
hold on;
%scatter(fig1,DPSDselfCorr(DPSDselfPvals >= 0.05),  DPSDcrossCorrMeans(DPSDselfPvals >= 0.05), 'o', 'filled', 'linewidth', 2)
xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1],'color','#aa3700','linewidth',0.5);
xticks([]);
xticklabels([]);
ylabel('Change in Power');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%ylabel('Means of Cross-Correlations')
%legend('p < 0.05', 'p >= 0.05', 'x=y line', 'location', 'best');
fig2 = subplot(4,2,2);
G = [ones(size(DPSDselfCorr))  2*ones(size(DPSDcrossCorrFlat))];
X = [DPSDselfCorr, DPSDcrossCorrFlat];
b = boxplot(X, G, 'notch', 'off', 'Labels', {'Self-Corr', 'cross-corr'},'Colors',[0 0 0; 0 0 0]/255,'symbol','.');
set(b, {'linew'}, {1});
h = findobj(gca,'Tag','Box');
colors = [0 0 0; 0 0 0]/255;
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',0.3);
end
xticks([]);
xticklabels([]);
ylim([-1 1.1])
yticks([-1 -0.5 0 0.5 1]);
yticklabels([-1 -0.5 0 0.5 1]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
% disp('right tailed ttest comparing self correlation and cross correlations of change in power')
% [h,p] = ttest2(DPSDselfCorr,DPSDcrossCorrFlat,'Tail', 'right')
disp('right tailed Mann  WHitney U test comparing self correlation and cross correlations of change in power')
[p2,h2] = ranksum(DPSDselfCorr,DPSDcrossCorrFlat,'tail', 'right')
SelfVsCross{1,:} = {median(DPSDselfCorr),iqr(DPSDselfCorr),median(DPSDcrossCorrFlat),iqr(DPSDcrossCorrFlat),p2};
%% Alpha Band Power vs Time

alphaSelfCorr = [];
alphaSelfPvals = [];
alphaCrossCorr = [];

for iSub = subjects
    [rho, pval] = corr(alphaTFOBCI(iSub, :)', alphaTFBP(iSub, :)','type','Spearman');
    %[pval, rho, crit_corr, est_alpha, seed_state] = mult_comp_perm_corr(XdeltaPOBCIFreqWise(i, :)', YdeltaPBPFreqWise(i, :)',5000,1,0.05,'linear',1);

    alphaSelfCorr = [alphaSelfCorr rho];
    alphaSelfPvals = [alphaSelfPvals pval];
    temp = [];
    for j=subjects
        if ~(iSub == j)
            [rho2, pval2] = corr(alphaTFOBCI(iSub, :)', alphaTFBP(j, :)','type','Spearman');
            temp = [temp rho2];
        end
    end
    alphaCrossCorr = [alphaCrossCorr; temp];
end


alphaCrossCorrMeans = median(alphaCrossCorr, 2);
alphaCrossCorrFlat = reshape(alphaCrossCorr.', 1, []);


fig3 = subplot(4,2,3);
for i=subjects
    scatter(fig3, repmat(alphaSelfCorr(i),1,iSub - 1),alphaCrossCorr(i,:),'k','filled','MarkerFaceColor','k','MarkerFaceAlpha',0.15)
    hold on

end
scatter(fig3, alphaSelfCorr,  alphaCrossCorrMeans, 'o','k', 'filled','MarkerFaceColor','k', 'linewidth', 2)
hold on;
%scatter(fig3,alphaSelfCorr(alphaSelfPvals >= 0.05),  alphaCrossCorrMeans(alphaSelfPvals >= 0.05), 'k^', 'filled', 'linewidth', 2)
xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1],'color','#aa3700','linewidth',0.5);
xticks([]);
xticklabels([]);
%xlabel('Self-Correlation');
ylabel('Alpha');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%legend('p < 0.05', 'p >= 0.05', 'x=y line', 'location', 'best');
fig4 = subplot(4,2,4);
G = [ones(size(alphaSelfCorr))  2*ones(size(alphaCrossCorrFlat))];
X = [alphaSelfCorr, alphaCrossCorrFlat];
b = boxplot(X, G, 'notch', 'off', 'Labels', {'Self-Corr', 'cross-corr'},'Colors',[0 0 0; 0 0 0]/255,'symbol','.');
set(b, {'linew'}, {1});
h = findobj(gca,'Tag','Box');
colors = [0 0 0; 0 0 0]/255;;
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',0.3);
end

% disp('right tailed ttest comparing self correlation and cross correlations of alpha band power')
% [h,p] = ttest2(alphaSelfCorr,alphaCrossCorrFlat,'Tail', 'right')
disp('right tailed Mann  WHitney U test comparing self correlation and cross correlations of alpha band power')
[p2,h2] = ranksum(alphaSelfCorr,alphaCrossCorrFlat,'tail', 'right')
SelfVsCross{2,:} = {median(alphaSelfCorr),iqr(alphaSelfCorr),median(alphaCrossCorrFlat),iqr(alphaCrossCorrFlat),p2};

xticks([]);
xticklabels([]);
ylim([-1 1.1])
yticks([-1 -0.5 0 0.5 1]);
yticklabels([-1 -0.5 0 0.5 1]);

temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;


%% Slow Gamma Band Power vs Time

slowGammaSelfCorr = [];
slowGammaSelfPvals = [];
slowGammaCrossCorr = [];

for iSub = subjects
    [rho, pval] = corr(slowGammaTFOBCI(iSub, :)', slowGammaTFBP(iSub, :)','type','Spearman');
    %[pval, rho, crit_corr, est_slowGamma, seed_state] = mult_comp_perm_corr(XdeltaPOBCIFreqWise(i, :)', YdeltaPBPFreqWise(i, :)',5000,1,0.05,'linear',1);

    slowGammaSelfCorr = [slowGammaSelfCorr rho];
    slowGammaSelfPvals = [slowGammaSelfPvals pval];
    temp = [];
    for j=subjects
        if ~(iSub == j)
            [rho2, pval2] = corr(slowGammaTFOBCI(iSub, :)', slowGammaTFBP(j, :)','type','Spearman');
            temp = [temp rho2];
        end
    end
    slowGammaCrossCorr = [slowGammaCrossCorr; temp];
end


slowGammaCrossCorrMeans = median(slowGammaCrossCorr, 2);
slowGammaCrossCorrFlat = reshape(slowGammaCrossCorr.', 1, []);


fig5 = subplot(4,2,5);
for i=subjects
    scatter(fig5, repmat(slowGammaSelfCorr(i),1,iSub - 1),slowGammaCrossCorr(i,:),'k','filled','MarkerFaceColor','k','MarkerFaceAlpha',0.15)
    hold on

end
scatter(fig5, slowGammaSelfCorr,  slowGammaCrossCorrMeans, 'o','k', 'filled','MarkerFaceColor','k', 'linewidth', 2)
hold on;
%scatter(fig5,slowGammaSelfCorr(slowGammaSelfPvals >= 0.05),  slowGammaCrossCorrMeans(slowGammaSelfPvals >= 0.05), 'k^', 'filled', 'linewidth', 2)
xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1],'color','#aa3700','linewidth',0.5);
xticks([]);
xticklabels([]);
%xlabel('Self-Correlation');
ylabel('Slow Gamma')
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%legend('p < 0.05', 'p >= 0.05', 'x=y line', 'location', 'best');
fig6 = subplot(4,2,6);
G = [ones(size(slowGammaSelfCorr))  2*ones(size(slowGammaCrossCorrFlat))];
X = [slowGammaSelfCorr, slowGammaCrossCorrFlat];
b = boxplot(X, G, 'notch', 'off', 'Labels', {'Self-Corr', 'cross-corr'},'Colors',[0 0 0; 0 0 0]/255,'symbol','.');
set(b, {'linew'}, {1});
h = findobj(gca,'Tag','Box');
colors = [0 0 0; 0 0 0]/255;
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',0.3);
end
% disp('right tailed ttest comparing self correlation and cross correlations of slow gamma band power')
% [h,p] = ttest2(slowGammaSelfCorr,slowGammaCrossCorrFlat,'Tail', 'right')
disp('right tailed Mann  WHitney U test comparing self correlation and cross correlations of slow gamma band power')
[p2,h2] = ranksum(slowGammaSelfCorr,slowGammaCrossCorrFlat,'tail', 'right')
SelfVsCross{3,:} = {median(slowGammaSelfCorr),iqr(slowGammaSelfCorr),median(slowGammaCrossCorrFlat),iqr(slowGammaCrossCorrFlat),p2};

xticks([]);
xticklabels([]);
ylim([-1 1.1])
yticks([-1 -0.5 0 0.5 1]);
yticklabels([-1 -0.5 0 0.5 1]);

temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%% Fast Gamma Band Power vs Time

fastGammaSelfCorr = [];
fastGammaSelfPvals = [];
fastGammaCrossCorr = [];

for iSub = subjects
    [rho, pval] = corr(fastGammaTFOBCI(iSub, :)', fastGammaTFBP(iSub, :)','type','Spearman');
    %[pval, rho, crit_corr, est_fastGamma, seed_state] = mult_comp_perm_corr(XdeltaPOBCIFreqWise(i, :)', YdeltaPBPFreqWise(i, :)',5000,1,0.05,'linear',1);

    fastGammaSelfCorr = [fastGammaSelfCorr rho];
    fastGammaSelfPvals = [fastGammaSelfPvals pval];
    temp = [];
    for j=subjects
        if ~(iSub == j)
            [rho2, pval2] = corr(fastGammaTFOBCI(iSub, :)', fastGammaTFBP(j, :)','type','Spearman');
            temp = [temp rho2];
        end
    end
    fastGammaCrossCorr = [fastGammaCrossCorr; temp];
end


fastGammaCrossCorrMeans = median(fastGammaCrossCorr, 2);
fastGammaCrossCorrFlat = reshape(fastGammaCrossCorr.', 1, []);


fig7 = subplot(4,2,7);
for i=subjects
    scatter(fig7, repmat(fastGammaSelfCorr(i),1,iSub - 1),fastGammaCrossCorr(i,:),'k','filled','MarkerFaceColor','k','MarkerFaceAlpha',0.15)
    hold on

end
scatter(fig7, fastGammaSelfCorr,  fastGammaCrossCorrMeans, 'o','k', 'filled','MarkerFaceColor','k', 'linewidth', 2)
hold on;
%scatter(fig7,fastGammaSelfCorr(fastGammaSelfPvals >= 0.05),  fastGammaCrossCorrMeans(fastGammaSelfPvals >= 0.05), 'k^', 'filled', 'linewidth', 2)
xlim([0 1]);
ylim([0 1]);
plot([0 1], [0 1],'color','#aa3700','linewidth',0.5);
%xlabel('Self-Correlation');
ylabel({'Cross Correlation','Fast Gamma'})
xlabel('Self Correlation');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%ylabel('Cross Correlation');


fig8 = subplot(4,2,8);
G = [ones(size(fastGammaSelfCorr))  2*ones(size(fastGammaCrossCorrFlat))];
X = [fastGammaSelfCorr, fastGammaCrossCorrFlat];
b = boxplot(X, G, 'notch', 'off', 'Labels', {'Self-Corr', 'Cross-Corr'},'Colors',[0 0 0; 0 0 0]/255,'symbol','.');
set(b, {'linew'}, {1});
h = findobj(gca,'Tag','Box');
colors = [0 0 0; 0 0 0]/255;
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',0.3);
end
% disp('right tailed ttest comparing self correlation and cross correlations of fast gamma band power')
% [h,p] = ttest2(fastGammaSelfCorr,fastGammaCrossCorrFlat,'Tail', 'right')
disp('right tailed Mann  WHitney U test comparing self correlation and cross correlations of fast gamma band power')
[p2,h2] = ranksum(fastGammaSelfCorr,fastGammaCrossCorrFlat,'tail', 'right')
SelfVsCross{4,:} = {median(fastGammaSelfCorr),iqr(fastGammaSelfCorr),median(fastGammaCrossCorrFlat),iqr(fastGammaCrossCorrFlat),p2};

ylim([-1 1.1]);
yticks([-1 -0.5 0 0.5 1]);
yticklabels([-1 -0.5 0 0.5 1]);
ylabel('Correlation', 'Position', [0.072734082397004,-0.045980878908425,-1]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;


SelfVsCross.Properties.VariableNames = {'SelfMedian','SelfIQR','CrossMedian','CrossIQR','pval'};
SelfVsCross.Properties.RowNames = {'PSD change','alpha','Sgamma','Fgamma'};
disp(SelfVsCross);