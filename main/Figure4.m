% This program generates figure 5 - ERPs of all subjects.

clearvars -except allSubjectData allSubjectDataNoiseFiltered;

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);
figure('Position',[360,41.666666666666664,500,599.3333333333333],'Color', [1 1 1]);
[ph gp]=getPlotHandles(11, 1, [0.15 0.1 0.5 0.86], 0.008, 0.008, 1);
fontsize = 10;
tickdir = 'out';
ticklength = [0.025 0];
nsub = [8,4,9,2,1,11,3,7,10,5,6];
maxrho = [];
lagtimes = [];
for iSub=nsub
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    OBCIerp = mean(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.erpBipolar,1);
    timeVals = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.timeVals;
    BPerp = mean(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.erpBipolar,1);
    timepoints = find(timeVals>-0.5 & timeVals <1.5);
    subplot(ph(find(nsub == iSub),1));
    plot(ph(find(nsub == iSub),1),timeVals(timepoints),-locdetrend(OBCIerp(timepoints)',250,[0.25 0.025]),'color','#aa3700','linewidth',0.7)
    hold (ph(find(nsub == iSub),1), 'on');
    plot(ph(find(nsub == iSub),1),timeVals(timepoints),locdetrend(BPerp(timepoints)',250,[0.25 0.025]),'color','#0073aa','linewidth',0.7)
    
    %removing lag from OBCI
    [rho,lag] = xcorr(locdetrend(BPerp(timepoints)',250,[0.25 0.025]), -locdetrend(OBCIerp(timepoints)',250,[0.25 0.025]),'normalized');
    index = find(rho == max(rho));
    maxrho = [maxrho rho(index)];
    lagtimes = [lagtimes lag(index)];

    xlim(ph(find(nsub == iSub),1), [-0.5 1.5]);
    ylim(ph(find(nsub == iSub),1), [-10 10]);
    xticks(ph(find(nsub == iSub),1), [0 1]);
    yticks(ph(find(nsub == iSub),1), [-10 0 10]);
    set(gca, 'FontSize',fontsize,'TickDir',tickdir, 'TickLength',ticklength, 'Xticklabel',[], 'Yticklabel',[]);
    ylimits = ylim(ph(find(nsub == iSub),1));

    x = [0 1 1 0];
    y = [ylimits(1) ylimits(1) ylimits(2) ylimits(2)];
    fill(ph(find(nsub == iSub),1), x, y, 'black', 'FaceAlpha', 0.1, 'EdgeAlpha', 0);
    
    % textboxes for reporting lag and correlation
    positionPlot1 = get(ph(find(nsub == iSub),1),'Position');
    positionY = positionPlot1(2);
    width1 = 0.2;
    height1 = positionPlot1(4)-(positionPlot1(4)/10);

    line1 = ['rho = ' num2str(round(rho(index),2))];
    line2 = ['lag = ' num2str(-4 * lag(index)) ' ms'];
    text = [line1 newline line2];
    box = annotation('textbox', [0.7,positionY,width1,height1],'String',text , 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','k');
    set(box,'VerticalAlignment','middle');
        
    width2 = 0.0353;
    height2 = 0.046;
    positionPlot1 = get(ph(find(nsub == iSub),1),'Position');
    positionY = positionPlot1(2); %+ positionPlot1(3) - width;
    annotation('textbox', [0.037,positionY,width2,height2], 'String', ['S' num2str(find(nsub == iSub))], 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','none')

    
end

ylabel(ph(6,1),'ERP in \muVolts');
%ylabel(ph(11,1),'ERP in \muV');
xlabel(ph(find(nsub == iSub),1),'Time (s)');
xticklabels(ph(find(nsub == iSub),1), [0 1]);
yticklabels(ph(find(nsub == iSub),1), [-10 0 10]);
xticks(ph(find(nsub == iSub),1), [0 1]);
yticks(ph(find(nsub == iSub),1), [-10 0 10]);
legend(ph(find(nsub == iSub),1),'OBCI','BP','Position',[0.564749140893471,0.025862068965517,0.15,0.049777530589544]);
[se,bs] = getSEMedian(maxrho');
disp(['Median (+- Standard error) correlation is ' num2str(median(maxrho)) '+-' num2str(se)]);
disp(['Median lag is ' num2str(4 * median(lagtimes)) ' ms']);
