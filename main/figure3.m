% This program generates Figure 3. dataVisualisation.m must be run before
% running this program.
clearvars -except allSubjectData allSubjectDataNoiseFiltered;

dataVisualisation;


fig = figure('units','normalized','Position',[0.092,0.056481481481481,0.826,0.832407407407407], 'Color', [1 1 1]);
[ph gp]=getPlotHandles(11, 6, [0.1 0.11 0.8 0.83], 0.03, 0.008, 1);
nsub = [8,4,9,2,1,11,3,7,10,5,6];
fontsize = 11;
tickdir = 'out';
ticklength = [0.04 0];
colorOBCI = '#aa3700';
colorBP = '#0073aa';
linewidth = 0.75;

for i=nsub
    x = protocolNames(contains(subjectNames,allSubjects(i)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    t = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.timeValsTFBipolar;
    f = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.freqValsTFBipolar;
    p = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.diffTFPowerDB;
    
    %column 1 OpenBCI TF spectra
    subplot(ph(find(nsub == i), 1));
    surf = pcolor(ph(find(nsub == i), 1), t, f, p');
    surf.FaceColor = 'interp';
    surf.EdgeAlpha = 0;
    caxis(ph(find(nsub == i), 1), [-4 4]);
    xlim(ph(find(nsub == i), 1), [-0.5 1.5]);
    ylim(ph(find(nsub == i), 1), [0 100]);
    xticks(ph(find(nsub == i), 1), [0 1]);
    yticks(ph(find(nsub == i), 1), [0 50 100]);
    set(gca, 'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[]);

    
    t = allSubjectDataNoiseFiltered(i).allProtocolsData(nBP).bipolarAnalysis.timeValsTFBipolar;
    f = allSubjectDataNoiseFiltered(i).allProtocolsData(nBP).bipolarAnalysis.freqValsTFBipolar;
    p = allSubjectDataNoiseFiltered(i).allProtocolsData(nBP).bipolarAnalysis.diffTFPowerDB;
    %column 2 BP TF spectra

    subplot(ph(find(nsub == i), 2));
    surf = pcolor(ph(find(nsub == i), 2), t, f, p');
    surf.FaceColor = 'interp';
    surf.EdgeAlpha = 0;
    
    xlim(ph(find(nsub == i), 2), [-0.5 1.5]);
    ylim(ph(find(nsub == i), 2), [0 100]);
    caxis(ph(find(nsub == i), 2), [-4.0 4]);
    xticks(ph(find(nsub == i), 2), [0 1]);
    yticks(ph(find(nsub == i), 2), [0 50 100]);
    set(gca, 'TickDir','out', 'TickLength',[0.03,1], 'Xticklabel',[], 'Yticklabel',[]);

end
colormap('magma');
title(ph(1, 1), 'OBCI', 'fontsize',fontsize);
title(ph(1, 2), 'BP', 'fontsize',fontsize);
xlabel(ph(length(nsub), 1),'Time (s)', 'fontsize',fontsize);
ylabel(ph(6, 1), 'Frequency (Hz)', 'fontsize',fontsize);
yticks(ph(length(nsub), 1), [0 50 100]);
yticklabels(ph(length(nsub), 1),[0 50 100]);
xticks(ph(length(nsub), 1),[0 1]);
xticklabels(ph(length(nsub), 1),[0 1]);
xticks(ph(length(nsub), 2),[0 1]);
xticklabels(ph(length(nsub), 2),[0 1]);
set(ph(length(nsub), 1),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);

set(ph(length(nsub), 2),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);
colorbar(ph(6,1),'Position',[0.019996027877082,0.351501668520582,0.006707471202109,0.343159065628477]);

for i=nsub
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    x = protocolNames(contains(subjectNames,allSubjects(i)));
    freqVals = allSubjectDataNoiseFiltered(i).allProtocolsData(nBP).bipolarAnalysis.freqValsBipolar;
    %column 3 change in PSD from baseline vs frequency
    subplot(ph(find(nsub == i), 3));

    plot(ph(find(nsub == i), 3), freqVals, XdeltaPOBCIFreqWise(i, :), 'color', colorOBCI, 'HandleVisibility','off','linewidth',linewidth);
    hold(ph(find(nsub == i), 3), 'on');
    plot(ph(find(nsub == i), 3), freqVals, YdeltaPBPFreqWise(i, :), 'color', colorBP, 'HandleVisibility','off','linewidth',linewidth);
    xlim(ph(find(nsub == i), 3), [0 100]);
    ylim(ph(find(nsub == i), 3), [-6 4]);

    yticks(ph(find(nsub == i), 3),[-6 0 4]);
    xticks(ph(find(nsub == i), 3),[]);
    set(gca,'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[])
    
    ylimits = ylim(ph(find(nsub == i), 3));
    y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
    s = fill(ph(find(nsub == i), 3),[[8 13] fliplr([8 13])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
    s.FaceColor = '#780046';
    s = fill(ph(find(nsub == i), 3), [[20 34] fliplr([20 34])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
    s.FaceColor = '#096301';
    s = fill(ph(find(nsub == i), 3), [[35 66] fliplr([35 66])], y, 'red', 'FaceAlpha', 0.2,'EdgeAlpha',0);
    s.FaceColor = '#633a01';
    
end
title(ph(1, 3), 'Change - PSD(dB)', 'fontsize',fontsize);
xlabel(ph(length(nsub),3),'Frequency (Hz)');
yticks(ph(length(nsub), 3),[-6 0 4]);
xticks(ph(length(nsub), 3),[0 50 100]);
xticklabels(ph(length(nsub), 3),[0 50 100]);
yticklabels(ph(length(nsub), 3),[-6 0 4]);
set(ph(length(nsub), 3),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);


for i=nsub
    x = protocolNames(contains(subjectNames,allSubjects(i)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    timeValsTF = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.timeValsTFBipolar;
    freqValsTF = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.freqValsTFBipolar;
    diffTFBP = allSubjectDataNoiseFiltered(i).allProtocolsData(nBP).bipolarAnalysis.diffTFPowerDB;
    diffTFOBCI = allSubjectDataNoiseFiltered(i).allProtocolsData(nOBCI).bipolarAnalysis.diffTFPowerDB;

    alphaPowerBP = squeeze(mean(diffTFBP(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
    gammaPower1BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
    gammaPower2BP = squeeze(mean(diffTFBP(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));
    alphaPowerOBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= alphaRange(2), freqValsTF >= alphaRange(1))), 2));
    gammaPower1OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= slowGammaRange(2), freqValsTF >= slowGammaRange(1))), 2));
    gammaPower2OBCI = squeeze(mean(diffTFOBCI(:, and(freqValsTF <= fastGammaRange(2), freqValsTF >= fastGammaRange(1))), 2));
    
    %column 4 change in alpha band power with time
    subplot(ph(find(nsub == i), 4));
    plot(ph(find(nsub == i), 4), timeValsTF, alphaPowerOBCI, 'color', colorOBCI,'linewidth',linewidth);
    hold(ph(find(nsub == i), 4), 'on');
    plot(ph(find(nsub == i), 4), timeValsTF, alphaPowerBP, 'color', colorBP,'linewidth',linewidth);
    xlim(ph(find(nsub == i), 4), [-0.5 1.5]);
    xticks(ph(find(nsub == i), 4), [-0.5 1.5]);
    ylim(ph(find(nsub == i), 4), [-6 4]);
    yticks(ph(find(nsub == i), 4), [-6 0 4]);
    set(gca,'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[])

    ylimits = ylim(ph(find(nsub == i), 4));
    x = [0 1 1 0];
    y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
    fill(ph(find(nsub == i), 4), x, y, 'black', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);
    
    %column 5 change in slow gamma band power with time
    subplot(ph(find(nsub == i), 5));
    plot(ph(find(nsub == i), 5), timeValsTF, gammaPower1OBCI, 'color', colorOBCI,'linewidth',linewidth);
    hold(ph(find(nsub == i), 5), 'on');
    plot(ph(find(nsub == i), 5), timeValsTF, gammaPower1BP, 'color', colorBP,'linewidth',linewidth);
    xlim(ph(find(nsub == i), 5), [-0.5 1.5]);
    ylim(ph(find(nsub == i), 5), [-2 3]);

    xticks(ph(find(nsub == i), 5), [0 1]);
    yticks(ph(find(nsub == i), 5), [-2 0 3]);
    set(gca,'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[])
    ylimits = ylim(ph(find(nsub == i), 5));
    x = [0 1 1 0];
    y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
    fill(ph(find(nsub == i), 5), x, y, 'black', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);
    
    %column 6 change in fast gamma band power with time
    subplot(ph(find(nsub == i), 6));
    plot(ph(find(nsub == i), 6), timeValsTF, gammaPower2OBCI, 'color', colorOBCI,'linewidth',linewidth);
    hold(ph(find(nsub == i), 6), 'on');
    plot(ph(find(nsub == i), 6), timeValsTF, gammaPower2BP, 'color', colorBP,'linewidth',linewidth);
    xlim(ph(find(nsub == i), 6), [-0.5 1.5]);
    xticks(ph(find(nsub == i), 6), [0 1]);
    ylim(ph(find(nsub == i), 6), [-1 2]);
    yticks(ph(find(nsub == i), 6), [-1 0 2]);
    set(gca,'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[])

    ylimits = ylim(ph(find(nsub == i), 6));
    x = [0 1 1 0];
    y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
    fill(ph(find(nsub == i), 6), x, y, 'black', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);

end
title(ph(1, 4), 'alpha', 'fontsize',fontsize)
title(ph(1, 5), 'slow gamma', 'fontsize',fontsize)
title(ph(1, 6), 'fast gamma', 'fontsize',fontsize)
ylabel(ph(6, 4), 'Change in Band Power (dB)', 'fontsize',fontsize);
xlabel(ph(length(nsub), 4), 'Time (s)');
xlabel(ph(length(nsub), 5), 'Time (s)');
xlabel(ph(length(nsub), 6), 'Time (s)');

xticks(ph(length(nsub), 4),[0 1]);
xticks(ph(length(nsub), 5),[0 1]);
xticks(ph(length(nsub), 6),[0 1]);
xticklabels(ph(length(nsub), 4),[0 1]);
xticklabels(ph(length(nsub), 5),[0 1]);
xticklabels(ph(length(nsub), 6),[0 1]);
yticks(ph(length(nsub), 4),[-6 0 4]);
yticks(ph(length(nsub), 5),[-2 0 3]);
yticks(ph(length(nsub), 6),[-1 0 2]);
yticklabels(ph(length(nsub), 4),[-6 0 4]);
yticklabels(ph(length(nsub), 5),[-2 0 3]);
yticklabels(ph(length(nsub), 6),[-1 0 2]);
set(ph(length(nsub), 4),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);
set(ph(length(nsub), 5),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);
set(ph(length(nsub), 6),'FontSize', fontsize,'TickDir',tickdir,'TickLength',ticklength);

legend(ph(6,6),'OBCI','BP','Stimulus','location','eastoutside', 'Position',[0.889601592419685,0.174,0.109733610307844,0.07174638487208],'Box','off');
legend(ph(7,3),'alpha','slow gamma','fast gamma','Position',[0.887381169921707,0.103726362625139,0.13043806508291,0.07174638487208],'Box','off');

%% subject ids
width1 = 0.0353;
height1 = 0.046;
for i = 1:11
    positionPlot1 = get(ph(i,1),'Position');
    positionY = positionPlot1(2); %+ positionPlot1(3) - width;
    annotation('textbox', [0.037,positionY,width1,height1], 'String', ['S' num2str(i)], 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','none')

end