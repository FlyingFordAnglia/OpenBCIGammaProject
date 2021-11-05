% This program requires allSubjectDataNoiseFiltered obtained by running analyseAllDataNoiseFiltered.m

% analyseAllDataNoiseFiltered;
clearvars -except allSubjectData allSubjectDataNoiseFiltered;
exampleSubjectID = 4;
fig1Pos = [0.1 (1-0.1-0.22) 0.22 0.22];
fig2Pos = [(0.1+0.22+0.01 +0.02) (1-0.1-0.22) 0.22 0.22];
fig3Pos = [0.1 (1-0.1-0.22 - 0.01 - 0.22) 0.22 0.22];
fig4Pos = [(0.1+0.22+0.01+0.02) (1-0.1-0.22 - 0.01 - 0.22) 0.22 0.22];
fig5Pos = [0.1 (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];
fig6Pos = [(0.1+0.22+0.01 +0.02) (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];
fig7Pos = [(0.1+0.22+0.03 + 0.1 +0.22 + 0.02) (1-0.07-0.16) 0.22 0.16];
fig8Pos = [(0.1+0.22+0.03 + 0.1 +0.22 + 0.02) (1-0.07-0.16 -0.165) 0.22 0.16];
fig9Pos = [(0.1+0.22+0.03 + 0.1 +0.22 + 0.02) (1-0.07-0.16 -0.165 -0.165) 0.22 0.16];
fig10Pos = [(0.1+0.22+0.03 + 0.1 +0.22 + 0.02) (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];
fig = figure('Position',[268.3333,41.6667,748.6667,599.3333], 'Color', [1 1 1]);
fontsize = 10;
tickdir = 'out';
ticklength = [0.03 0];
colorOBCI = '#aa3700';
colorBP = '#0073aa';
annotation('textbox', [0.052,0.91,0.04,0.045], 'String', "A", 'FontSize',12,'FontWeight','bold', 'EdgeColor','none')
annotation('textbox', [0.60,0.91,0.04,0.045], 'String', "B", 'FontSize',12,'FontWeight','bold', 'EdgeColor','none')
annotation('textbox', [0.052,0.38,0.04,0.045], 'String', "C", 'FontSize',12,'FontWeight','bold', 'EdgeColor','none')
annotation('textbox', [0.60,0.38,0.04,0.045], 'String', "D", 'FontSize',12,'FontWeight','bold', 'EdgeColor','none')

alphaRange = [8 13];
slowGammaRange = [20 34];
fastGammaRange = [35 66];

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);
x = protocolNames(contains(subjectNames,allSubjects(exampleSubjectID)));
nOBCI = find(x == "GRF_003");
nBP = find(x == "GRF_006");


%% Figure 2A - ERP
fig1 = subplot('Position',fig1Pos);
OBCIerp = mean(allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.erpBipolar,1);
timeVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.timeVals;
plot(fig1,timeVals, -1 * -locdetrend(OBCIerp',250,[0.25 0.025]), 'linewidth', 1.0, 'color', colorOBCI);
hold on
ylim([-7.5 7.5]);
ylimits = ylim;
xlim([-0.5 1.5]);
ylabel('ERP (\muV)');
xticks([]);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
title('OpenBCI','color',colorOBCI);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

fig2 = subplot('Position',fig2Pos);
BPerp = mean(allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.erpBipolar,1);
timeVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.timeVals;
plot(fig2,timeVals, -locdetrend(BPerp',250,[0.25 0.025]), 'linewidth', 1.0, 'color', colorBP);
hold on
ylim([ylimits]);
yticks([-5, 0 , 5]);
xticks([0 1]);
xticklabels([]);
yticklabels([]);
xlim([-0.5 1.5]);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(x, y,'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
title('BrainProducts', 'color',colorBP);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;


% TF spectra
fig3 = subplot('Position', fig3Pos);
OBCIdiffTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.diffTFPowerDB;
timeValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.timeValsTFBipolar;
freqValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.freqValsTFBipolar;
surf = pcolor(fig3, timeValsTF, freqValsTF, OBCIdiffTF');
hold on
surf.FaceColor = 'interp';
surf.EdgeAlpha = 0;
colormap('magma');
caxis(fig3, [-4.0 4]);
ylim([0 100]);
ylimits = ylim;
xlim([-0.5 1.5]);
xlimits = xlim;
xticks([0 1]);
line([0 0], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
line([1 1], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
% line([xlimits(1) xlimits(2)],[alphaRange(1) alphaRange(1)],'linestyle','-','color','k', 'linewidth',0.75);
% line([xlimits(1) xlimits(2)],[alphaRange(2) alphaRange(2)],'linestyle','-','color','k', 'linewidth',0.75);
% line([xlimits(1) xlimits(2)],[slowGammaRange(1) slowGammaRange(1)],'linestyle',':','color','c', 'linewidth',0.75);
% line([xlimits(1) xlimits(2)],[slowGammaRange(2) slowGammaRange(2)],'linestyle',':','color','c', 'linewidth',0.75);
% line([xlimits(1) xlimits(2)],[fastGammaRange(1) fastGammaRange(1)],'linestyle','-.','color','y', 'linewidth',0.75);
% line([xlimits(1) xlimits(2)],[fastGammaRange(2) fastGammaRange(2)],'linestyle','-.','color','y', 'linewidth',0.75);
xlabel('Time (s)', 'Position',[0.500000953674317,-15.824873096446709,-1]);
ylabel('Frequency (Hz)');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;


fig4 = subplot('Position', fig4Pos);
BPdiffTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.diffTFPowerDB;
surf = pcolor(fig4, timeValsTF, freqValsTF, BPdiffTF');
hold on
surf.FaceColor = 'interp';
surf.EdgeAlpha = 0;
colormap('magma');
caxis(fig4, [-4.0 4]);
%colorbar('Location','eastoutside')
ylim([0 100]);
ylimits = ylim;
xlim([-0.5 1.5]);
yticks([0 50 100]);
xticks([0 1]);
yticklabels([]);
line([0 0], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
line([1 1], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
cbar();
cb = get(gca);
cb.XTickLabel = [];
cb.YTicks = [-4 -2 0 2 4];
cb.YtickLabel = [-4 -2 0 2 4];
cb.YTickLocation= 'right';
cb.TickDir = tickdir;
cb.TickLength = ticklength;
cb.Position = [0.564934007439127,0.450500556173526,0.015316117542297,0.219132369299221];


%% Figure 2C PSDs
badTrialsOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).badTrials.badTrials;

fig5 = subplot('Position',fig5Pos);
OBCIpowerbl = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar;
OBCIpowerst = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.stPowerVsFreqBipolar;
OBCIpowerbl = mean(mean(log10(OBCIpowerbl(:, :, setdiff(1:size(OBCIpowerbl, 3), badTrialsOBCI))),3),1);
OBCIpowerst = mean(mean(log10(OBCIpowerst(:, :, setdiff(1:size(OBCIpowerst, 3), badTrialsOBCI))),3),1);
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.freqValsBipolar;
plot(fig5, freqVals, OBCIpowerbl,'linewidth',1.0,'color',colorOBCI, 'linestyle',':');
hold on
plot(fig5, freqVals, OBCIpowerst,'linewidth',1.0,'color',colorOBCI);
xlabel('Frequency (Hz)');
ylabel('log10 Power (\muV ^2)');
xlim([0 100]);
ylim([-3 1.0]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
legend(fig5,'BL','ST','location','northeast','linewidth',0.2, 'Position',[0.229,0.3124,0.0894,0.0586]);


badTrialsBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).badTrials.badTrials;

fig6 = subplot('Position',fig6Pos);
BPpowerbl = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar;
BPpowerst = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.stPowerVsFreqBipolar;
BPpowerbl = mean(mean(log10(BPpowerbl(:, :, setdiff(1:size(BPpowerbl, 3), badTrialsBP))),3),1);
BPpowerst = mean(mean(log10(BPpowerst(:, :, setdiff(1:size(BPpowerst, 3), badTrialsBP))),3),1);
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.freqValsBipolar;
plot(fig6, freqVals, BPpowerbl,'linewidth',1.0,'color',colorBP, 'linestyle',':');
hold on
plot(fig6, freqVals, BPpowerst,'linewidth',1.0,'color',colorBP);
xlim([0 100]);
ylim([-3 1.0]);
yticks([-3:1]);
yticklabels([]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
legend(fig6,'BL','ST','location','northeast','linewidth',0.2,'Position',[0.480,0.312,0.0894,0.0586]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

%% Figure 2B 
timeValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.timeValsTFBipolar;
freqValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.freqValsTFBipolar;
diffTFBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.diffTFPowerDB;
diffTFOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.diffTFPowerDB;
alphaPowerBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
gammaPower1BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
gammaPower2BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));
alphaPowerOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
gammaPower1OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
gammaPower2OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));

fig7 = subplot('Position',fig7Pos);
plot(fig7, timeValsTF, alphaPowerOBCI, 'color', colorOBCI,'linewidth',1.0);
hold(fig7, 'on');
plot(fig7, timeValsTF, alphaPowerBP, 'color', colorBP,'linewidth',1.0);
xlim(fig7, [-0.5 1.5]);
ylim((fig7), [-3 3]);
ylimits = ylim(fig7);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(fig7, x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
xticks([]);
yticks([-2 0 2]);
title('Change in Band Power (dB)')
ylabel('alpha');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

fig8 = subplot('Position',fig8Pos);
plot(fig8, timeValsTF, gammaPower1OBCI, 'color', colorOBCI,'linewidth',1.0);
hold(fig8, 'on');
plot(fig8, timeValsTF, gammaPower1BP, 'color', colorBP,'linewidth',1.0);
xlim(fig8, [-0.5 1.5]);
ylim((fig8), [-3 3]);
ylimits = ylim(fig8);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(fig8, x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
xticks([]);
yticks([-2 0 2]);
ylabel('slow gamma');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;


fig9 = subplot('Position',fig9Pos);
plot(fig9, timeValsTF, gammaPower2OBCI, 'color', colorOBCI,'linewidth',1.0);
hold(fig9, 'on');
plot(fig9, timeValsTF, gammaPower2BP, 'color', colorBP,'linewidth',1.0);
xlim(fig9, [-0.5 1.5]);
ylim((fig9), [-3 3]);
ylimits = ylim(fig9);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(fig9, x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
xticks([0 1]);
yticks([-2 0 2]);
xlabel('Time (s)', 'Position',[0.491903787682414,-3.972377622377618,-1]);
ylabel('fast gamma');
legend(fig9,'OBCI','BP','location','northeast', 'position', [0.862592521131705,0.377850673574189,0.108192341941229,0.058676307007786]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

%% Figure 2D
fig10 = subplot('Position',fig10Pos);
stPowerOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.stPowerVsFreqBipolar;
blPowerOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar;
stPowerBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.stPowerVsFreqBipolar;
blPowerBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar;
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(nOBCI).bipolarAnalysis.freqValsBipolar;

%removing bad trials
stPowerOBCI = stPowerOBCI(:, :, setdiff(1:size(stPowerOBCI, 3), badTrialsOBCI));
blPowerOBCI = blPowerOBCI(:, :, setdiff(1:size(blPowerOBCI, 3), badTrialsOBCI));
stPowerBP = stPowerBP(:, :, setdiff(1:size(stPowerBP, 3), badTrialsBP));
blPowerBP = blPowerBP(:, :, setdiff(1:size(blPowerBP, 3), badTrialsBP));



deltaPOBCI = 10*(mean(mean(log10(stPowerOBCI),3),1) - mean(mean(log10(blPowerOBCI),3),1));
deltaPBP = 10*(mean(mean(log10(stPowerBP),3),1) - mean(mean(log10(blPowerBP),3),1));

plot(fig10,freqVals',deltaPOBCI,'color',colorOBCI,'linewidth',1.0,'HandleVisibility','off');
hold on;
plot(fig10,freqVals',deltaPBP,'color',colorBP,'linewidth',1.0,'HandleVisibility','off');
xlim([0 100]);
xlabel('Frequency (Hz)');
ylabel('Change in Power (dB)');
ylim([-3 5]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
legend(fig10,'alpha','slow gamma','fast gamma', 'Orientation','horizontal', 'Position',[0.284131001969123,0.029092045089442,0.419857524487978,0.032258064516129]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;