% This program requires allSubjectData obtained by running analyseAllData.m
% OR the line noise corrected version. 

% analyseAllData;
%analyseAllDataNoiseFiltered;
clearvars -except allSubjectData allSubjectDataNoiseFiltered;

exampleSubjectID = 1;

%% subplot positions
fig1Pos = [0.1 (1-0.1-0.22) 0.22 0.22];
fig2Pos = [(0.1+0.22+0.01) (1-0.1-0.22) 0.22 0.22];
fig3Pos = [0.1 (1-0.1-0.22 - 0.01 - 0.22) 0.22 0.22];
fig4Pos = [(0.1+0.22+0.01) (1-0.1-0.22 - 0.01 - 0.22) 0.22 0.22];
fig5Pos = [0.1 (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];
fig6Pos = [(0.1+0.22+0.01) (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];
fig7Pos = [(0.1+0.22+0.01 + 0.1 +0.22) (1-0.07-0.16) 0.22 0.16];
fig8Pos = [(0.1+0.22+0.01 + 0.1 +0.22) (1-0.07-0.16 -0.165) 0.22 0.16];
fig9Pos = [(0.1+0.22+0.01 + 0.1 +0.22) (1-0.07-0.16 -0.165 -0.165) 0.22 0.16];
fig10Pos = [(0.1+0.22+0.01 + 0.1 +0.22) (1-0.1-0.22 - 0.01 - 0.22 - 0.08 -0.25) 0.22 0.25];


%% Figure 2 from the main manuscript

fig = figure('Position',[268.3333,41.6667,748.6667,599.3333]);

%sgtitle('Example Subject');


fig1 = subplot('Position',fig1Pos);
OBCIerp = mean(allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.erpBipolar,1);
timeVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.timeVals;
plot(fig1,timeVals, OBCIerp, 'linewidth', 1.0, 'color', 'k');
hold on
ylimits = ylim;
xlim([-0.5 1.5]);
ylabel('ERP (\muV)');
xticks([]);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
title('OpenBCI');


fig2 = subplot('Position',fig2Pos);
BPerp = mean(allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.erpBipolar,1);
timeVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.timeVals;
plot(fig2,timeVals, -1 * BPerp, 'linewidth', 1.0, 'color', 'k');
hold on
ylim([ylimits]);
yticks([]);
xticks([]);
xlim([-0.5 1.5]);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(x, y,'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
title('BrainProducts');


fig3 = subplot('Position', fig3Pos);
OBCIdiffTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.diffTFPowerDB;
timeValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.timeValsTFBipolar;
freqValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.freqValsTFBipolar;
surf = pcolor(fig3, timeValsTF, freqValsTF, OBCIdiffTF');
hold on
surf.FaceColor = 'interp';
surf.EdgeAlpha = 0;
colormap('magma');
caxis(fig3, [-4.0 4]);
ylimits = ylim;
xlim([-0.5 1.5]);
xticks([0 1]);
line([0 0], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
line([1 1], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
xlabel('Time');
ylabel('Frequency');



fig4 = subplot('Position', fig4Pos);
BPdiffTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.diffTFPowerDB;
surf = pcolor(fig4, timeValsTF, freqValsTF, BPdiffTF');
hold on
surf.FaceColor = 'interp';
surf.EdgeAlpha = 0;
colormap('magma');
caxis(fig4, [-4.0 4]);
%colorbar('Location','eastoutside')
ylimits = ylim;
xlim([-0.5 1.5]);
yticks([]);
xticks([0 1]);
line([0 0], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');
line([1 1], [ylimits(1) ylimits(2)], 'linestyle', '--', 'color', 'k');


fig5 = subplot('Position',fig5Pos);
OBCIpowerbl = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar;
OBCIpowerst = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.stPowerVsFreqBipolar;
OBCIpowerbl = mean(mean(log10(OBCIpowerbl),3),1);
OBCIpowerst = mean(mean(log10(OBCIpowerst),3),1);
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;
plot(fig5, freqVals, OBCIpowerbl,'linewidth',1.0,'color','k');
hold on
plot(fig5, freqVals, OBCIpowerst,'linewidth',1.0,'color','red');
xlabel('Frequency (Hz)');
ylabel('log10 Power (\muV ^2)');
xlim([0 80]);
ylim([-3 1.0]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';


fig6 = subplot('Position',fig6Pos);
BPpowerbl = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar;
BPpowerst = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.stPowerVsFreqBipolar;
BPpowerbl = mean(mean(log10(BPpowerbl),3),1);
BPpowerst = mean(mean(log10(BPpowerst),3),1);
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.freqValsBipolar;
plot(fig6, freqVals, BPpowerbl,'linewidth',1.0,'color','k');
hold on
plot(fig6, freqVals, BPpowerst,'linewidth',1.0,'color','red');
xlim([0 80]);
ylim([-3 1.0]);
yticks([]);
ylimits = ylim;
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
legend(fig6,'BL','ST','location','northeast','linewidth',0.2);


alphaRange = [8 13];
slowGammaRange = [20 34];
fastGammaRange = [35 66];

timeValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.timeValsTFBipolar;
freqValsTF = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.freqValsTFBipolar;
diffTFBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.diffTFPowerDB;
diffTFOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.diffTFPowerDB;
alphaPowerBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
gammaPower1BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
gammaPower2BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));
alphaPowerOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
gammaPower1OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
gammaPower2OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));

fig7 = subplot('Position',fig7Pos);
plot(fig7, timeValsTF, alphaPowerOBCI, 'color', 'red','linewidth',1.0);
hold(fig7, 'on');
plot(fig7, timeValsTF, alphaPowerBP, 'color', 'black','linewidth',1.0);
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

fig8 = subplot('Position',fig8Pos);
plot(fig8, timeValsTF, gammaPower1OBCI, 'color', 'red','linewidth',1.0);
hold(fig8, 'on');
plot(fig8, timeValsTF, gammaPower1BP, 'color', 'black','linewidth',1.0);
xlim(fig8, [-0.5 1.5]);
ylim((fig8), [-3 3]);
ylimits = ylim(fig8);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(fig8, x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
xticks([]);
yticks([-2 0 2]);
ylabel('slowGamma');


fig9 = subplot('Position',fig9Pos);
plot(fig9, timeValsTF, gammaPower2OBCI, 'color', 'red','linewidth',1.0);
hold(fig9, 'on');
plot(fig9, timeValsTF, gammaPower2BP, 'color', 'black','linewidth',1.0);
xlim(fig9, [-0.5 1.5]);
ylim((fig9), [-3 3]);
ylimits = ylim(fig9);
x = [0 1 1 0];
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill(fig9, x, y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = 'k';
xticks([0 1]);
yticks([-2 0 2]);
ylabel('fastGamma');
legend(fig9,'OBCI','BP','location','northeast');

fig10 = subplot('Position',fig10Pos);
stPowerOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.stPowerVsFreqBipolar;
blPowerOBCI = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar;
stPowerBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.stPowerVsFreqBipolar;
blPowerBP = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar;
freqVals = allSubjectDataNoiseFiltered(exampleSubjectID).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;

deltaPOBCI = 10*(mean(mean(log10(stPowerOBCI),3),1) - mean(mean(log10(blPowerOBCI),3),1));
deltaPBP = 10*(mean(mean(log10(stPowerBP),3),1) - mean(mean(log10(blPowerBP),3),1));

plot(fig10,freqVals',deltaPOBCI,'color','red','linewidth',1.0,'HandleVisibility','off');
hold on;
plot(fig10,freqVals',deltaPBP,'color','black','linewidth',1.0,'HandleVisibility','off');
xlim([0 80]);
xlabel('Frequency (Hz)');
ylabel('Change in Power (dB)');
ylimits = ylim(fig10);
y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
s = fill([[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#780046';
s = fill([[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#096301';
s = fill([[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
s.FaceColor = '#633a01';
legend(fig10,'alpha','slowGamma','fastGamma');
