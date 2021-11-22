% This program needs allSubjectData struct obtained by running analyseAllData.m
% Likewise for line noise filtered data.

% analyseAllData;
% analyseAllDataNoiseFiltered;
clearvars -except allSubjectDataNoiseFiltered allSubjectData
% 
[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,gender] = allProtocolsOBCIGammaProject;
allSubjects = unique(subjectNames);


fontsize = 12;
tickdir = 'both';
ticklength = [0.025 0];



freqVals = allSubjectData(1).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;
freqPos1 = find(freqVals <= 34 & freqVals >= 16); % slope range 1
freqPos2 = find(freqVals <= 88 & freqVals >= 54);% slope range 2
lastFreqPos = find(freqVals == 125); % Nyquist frequency
OBCIPowerAllSubjects = [];
BPPowerAllSubjects = [];
OBCISlope1AllSubjects = [];
OBCISlope2AllSubjects = [];
BPSlope1AllSubjects = [];
BPSlope2AllSubjects = [];
colors = [170 55 0; 0 115 170]/255;
figure('Position', [188.3333333333333,41.666666666666664,672,599.3333333333333],'Color',[1 1 1]);
annotation('textbox', [0.068,0.93,0.04,0.045], 'String', "A", 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','k')
annotation('textbox', [0.51,0.93,0.04,0.045], 'String', "B", 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','k')
annotation('textbox', [0.068,0.48,0.04,0.045], 'String', "C", 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','k')
annotation('textbox', [0.51,0.48,0.04,0.045], 'String', "D", 'FontSize',fontsize,'FontWeight','bold', 'EdgeColor','k')

for iSub = 1:length(allSubjectData)
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");
    baselinePowerOBCI = allSubjectData(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerOBCI = mean(mean(log10(baselinePowerOBCI),3),1);
    OBCIPowerAllSubjects = [OBCIPowerAllSubjects baselinePowerOBCI'];
    
    baselinePowerBP = allSubjectData(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerBP = mean(mean(log10(baselinePowerBP),3),1);
    BPPowerAllSubjects = [BPPowerAllSubjects baselinePowerBP'];
    
    OBCIslope1 = slopes(allSubjectData(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    OBCISlope1AllSubjects = [OBCISlope1AllSubjects OBCIslope1];
    
    OBCIslope2 = slopes(allSubjectData(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    OBCISlope2AllSubjects = [OBCISlope2AllSubjects OBCIslope2];
    
    BPslope1 = slopes(allSubjectData(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    BPSlope1AllSubjects = [BPSlope1AllSubjects BPslope1];

    BPslope2 = slopes(allSubjectData(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    BPSlope2AllSubjects = [BPSlope2AllSubjects BPslope2];
end

fig1 = subplot(2,2,1);
% mean PSD of all subjects for OBCI and BP
meanPSDOBCI = squeeze(mean(OBCIPowerAllSubjects,2));
stdPSDOBCI = squeeze(std(OBCIPowerAllSubjects')) / sqrt(size(OBCIPowerAllSubjects, 2));
meanPSDBP = squeeze(mean(BPPowerAllSubjects,2));
stdPSDBP = squeeze(std(BPPowerAllSubjects')) / sqrt(size(BPPowerAllSubjects, 2));
plot(fig1,(freqVals),meanPSDOBCI,'linewidth',1.0,'color','#aa3700');
hold on
plot(fig1,(freqVals),meanPSDBP,'linewidth',1.0,'color','#0073aa');
yUp = meanPSDOBCI + stdPSDOBCI';
yDown = meanPSDOBCI - stdPSDOBCI';
s = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0');
s.FaceColor = '#aa3700';
yUp = meanPSDBP + stdPSDBP';
yDown = meanPSDBP - stdPSDBP';
s2 = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0');
s2.FaceColor = '#0073aa';
xlim([0 (100)]);
ylim([-3 2]);
title('Raw Data', 'FontSize',14);
ylabel('log10 Power (\muV^2)','FontSize',14);
xlabel('Frequency (Hz)','FontSize',14);
%ylabel('log10 Power (\muV^2)');
% xticks(fig1,[log10(10) log10(50) log10(100)]);
xticklabels(fig1,[0,20,40,60,80,100]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

[rho, pval] = corr(meanPSDOBCI, meanPSDBP, 'type', 'Spearman');
disp('The Spearman correlation coefficient for mean PSD comparison between OpenBCI and BP for raw data is:');
disp(rho);
disp('The pvalue computed using permutation test for this correlation is:');
disp(pval);

fig3 = subplot(2,2,3);
% Slope comparison of OBCI and BP
meanSlopes = [mean(OBCISlope1AllSubjects) mean(BPSlope1AllSubjects); mean(OBCISlope2AllSubjects) mean(BPSlope2AllSubjects)];
semSlopes = [std(OBCISlope1AllSubjects)/sqrt(length(OBCISlope1AllSubjects)) std(BPSlope1AllSubjects)/sqrt(length(BPSlope1AllSubjects)); std(OBCISlope2AllSubjects)/sqrt(length(OBCISlope2AllSubjects)) std(BPSlope2AllSubjects)/sqrt(length(BPSlope2AllSubjects))];
barhandle = bar(fig3,categorical({'16-34 Hz','54-88 Hz'}),meanSlopes,'FaceColor','flat');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(meanSlopes);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = barhandle(i).XEndPoints;
end
hold on;
er = errorbar(fig3,x',meanSlopes,semSlopes,semSlopes,'k','linestyle','none','HandleVisibility','off');    
set(barhandle,{'DisplayName'},{'OBCI','BP'}');
ylimits2 = ylim;
for k = 1:size(meanSlopes,2)
    barhandle(k).CData = colors(k,:);
end
ylabel('Mean Slope');
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%% Significance testing

% Slope range 1

[p,h] = ranksum(OBCISlope1AllSubjects', BPSlope1AllSubjects');
%[h,p2] = ttest(OBCISlope1AllSubjects', BPSlope1AllSubjects');
disp('P-value for Mann Whitney U test comparing 16-34Hz slope between OBCI and BP is:');
disp(p);
% disp('P-value for paired t-test comparing 16-34Hz slope between OBCI and BP is:');
% disp(p2);

% Slope range 2
[p,h] = ranksum(OBCISlope2AllSubjects', BPSlope2AllSubjects');
%[h,p2] = ttest(OBCISlope2AllSubjects', BPSlope2AllSubjects');
disp('P-value for Mann Whitney U test comparing 54-88Hz slope between OBCI and BP is:');
disp(p);
% disp('P-value for paired t-test comparing 54-88Hz slope between OBCI and BP is:');
% disp(p2);

%% Noise corrected

OBCIPowerAllSubjects = [];
BPPowerAllSubjects = [];
OBCISlope1AllSubjects = [];
OBCISlope2AllSubjects = [];
BPSlope1AllSubjects = [];
BPSlope2AllSubjects = [];

for iSub = 1:length(allSubjectDataNoiseFiltered)
    x = protocolNames(contains(subjectNames,allSubjects(iSub)));
    nOBCI = find(x == "GRF_003");
    nBP = find(x == "GRF_006");

    baselinePowerOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerOBCI = mean(mean(log10(baselinePowerOBCI),3),1);
    OBCIPowerAllSubjects = [OBCIPowerAllSubjects baselinePowerOBCI'];
    
    baselinePowerBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerBP = mean(mean(log10(baselinePowerBP),3),1);
    BPPowerAllSubjects = [BPPowerAllSubjects baselinePowerBP'];
    
    OBCIslope1 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    OBCISlope1AllSubjects = [OBCISlope1AllSubjects OBCIslope1];
    
    OBCIslope2 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nOBCI).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    OBCISlope2AllSubjects = [OBCISlope2AllSubjects OBCIslope2];
    
    BPslope1 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    BPSlope1AllSubjects = [BPSlope1AllSubjects BPslope1];

    BPslope2 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(nBP).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    BPSlope2AllSubjects = [BPSlope2AllSubjects BPslope2];
end




fig2 = subplot(2,2,2);
meanPSDOBCI = squeeze(mean(OBCIPowerAllSubjects,2));
stdPSDOBCI = squeeze(std(OBCIPowerAllSubjects')) / sqrt(size(OBCIPowerAllSubjects, 2));
meanPSDBP = squeeze(mean(BPPowerAllSubjects,2));
stdPSDBP = squeeze(std(BPPowerAllSubjects')) / sqrt(size(BPPowerAllSubjects, 2));
plot(fig2,(freqVals),meanPSDOBCI,'linewidth',1.0,'color','#aa3700', 'HandleVisibility','on');
hold on
plot(fig2,(freqVals),meanPSDBP,'linewidth',1.0,'color','#0073aa', 'HandleVisibility','on');
yUp = meanPSDOBCI + stdPSDOBCI';
yDown = meanPSDOBCI - stdPSDOBCI';
s = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0', 'HandleVisibility','off');
s.FaceColor = '#aa3700';
yUp = meanPSDBP + stdPSDBP';
yDown = meanPSDBP - stdPSDBP';
s2 = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0', 'HandleVisibility','off');
s2.FaceColor = '#0073aa';
xlim([0 100]);
ylim([-3 2]);
ylimits = ylim;
title('Line Noise Corrected Data');
xlabel('Frequency (Hz)');
%ylabel('log10 Power (\muV^2)');
xticklabels(fig2,[0,20,40,60,80,100]);
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;

[rho, pval] = corr(meanPSDOBCI, meanPSDBP, 'type', 'Spearman');
disp('The Spearman correlation coefficient for mean PSD comparison between OpenBCI and BP for noise corrected data is:');
disp(rho);
disp('The pvalue computed using permutation test for this correlation is:');
disp(pval);

fig4 = subplot(2,2,4);
meanSlopes = [mean(OBCISlope1AllSubjects) mean(BPSlope1AllSubjects); mean(OBCISlope2AllSubjects) mean(BPSlope2AllSubjects)];
semSlopes = [std(OBCISlope1AllSubjects)/sqrt(length(OBCISlope1AllSubjects)) std(BPSlope1AllSubjects)/sqrt(length(BPSlope1AllSubjects)); std(OBCISlope2AllSubjects)/sqrt(length(OBCISlope2AllSubjects)) std(BPSlope2AllSubjects)/sqrt(length(BPSlope2AllSubjects))];
barhandle = bar(fig4,categorical({'16-34 Hz','54-88 Hz'}),meanSlopes,'FaceColor','flat');
% Calculate the number of groups and number of bars in each group
[ngroups,nbars] = size(meanSlopes);
% Get the x coordinate of the bars
x = nan(nbars, ngroups);
for i = 1:nbars
    x(i,:) = barhandle(i).XEndPoints;
end
hold on;
er = errorbar(fig4,x',meanSlopes,semSlopes,semSlopes,'k','linestyle','none','HandleVisibility','off');    
set(barhandle,{'DisplayName'},{'OBCI','BP'}');
legend(fig4,'Location','northeast', 'Position',[0.773,0.384,0.1285,0.0676]);
ylim([ylimits2(1) ylimits2(2)]);
for k = 1:size(meanSlopes,2)
    barhandle(k).CData = colors(k,:);
end
temp = gca;
temp.FontSize = fontsize;
temp.TickDir = tickdir;
temp.TickLength = ticklength;
%% Significance testing

% Slope range 1

[p,h] = ranksum(OBCISlope1AllSubjects', BPSlope1AllSubjects');
% [h,p2] = ttest(OBCISlope1AllSubjects', BPSlope1AllSubjects');
disp('P-value for Mann Whitney U test comparing 16-34Hz slope between OBCI and BP (noise corrected) is:');
disp(p);
% disp('P-value for paired t-test comparing 16-34Hz slope between OBCI and BP (noise corrected) is:');
% disp(p2);

% Slope range 2
[p,h] = ranksum(OBCISlope2AllSubjects', BPSlope2AllSubjects');
% [h,p2] = ttest(OBCISlope2AllSubjects', BPSlope2AllSubjects');
disp('P-value for Mann WHitney U test comparing 54-88Hz slope between OBCI and BP (noise corrected) is:');
disp(p);
% disp('P-value for paired t-test comparing 54-88Hz slope between OBCI and BP (noise corrected) is:');
% disp(p2);
%% shorted electrodes plots

%raw data
electrodeLabels = ["O1","O2","T5","P3","Pz","P4","T6","Ref"];
gridType='EEG'; 
folderSourceString='C:\Users\srivi\Documents\T1\Primate Research Laboratory';

bipolarEEGChannelsStored(1,:) = [3 4 8 6 7];
bipolarEEGChannelsStored(2,:) = [1 1 5 2 2];
stRange = [0.25 1.0];
blRange = [-0.75 0];
clear elecData

folderName = fullfile(folderSourceString,'data','test',gridType,'160621','GRF_003');
folderSegment= fullfile(folderName,'segmentedData');
OBCIlfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
for iElec = 1:length(electrodeLabels)
    clear temp
    temp = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat']),'analogData');
    elecData(iElec,:,:) = temp.analogData; 
end

timeVals = OBCIlfpInfo.timeVals;
analogChannelsStored = OBCIlfpInfo.analogChannelsStored;
protocolType = 'sfori';
[~,PowerVsFreqUnipolarOBCI,freqValsUnipolarOBCI,~,~,~,~] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,[],bipolarEEGChannelsStored,protocolType,[]);
PowerVsFreqUnipolarOBCI = PowerVsFreqUnipolarOBCI(2,:,:) - PowerVsFreqUnipolarOBCI(1,:,:);
PowerVsFreqUnipolarOBCI = mean(mean(log10(PowerVsFreqUnipolarOBCI),3),1);

clear elecData
folderName = fullfile(folderSourceString,'data','test',gridType,'160621','GRF_006');
folderSegment= fullfile(folderName,'segmentedData');
BPlfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
for iElec = 1:length(electrodeLabels)
    clear temp
    temp = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat']),'analogData');
    elecData(iElec,:,:) = temp.analogData; 
end

protocolType = 'sfori';
[~,PowerVsFreqUnipolarBP,freqValsUnipolarBP,~,~,~,~] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,[],bipolarEEGChannelsStored,protocolType,[]);

PowerVsFreqUnipolarBP = PowerVsFreqUnipolarBP(2,:,:) - PowerVsFreqUnipolarBP(1,:,:);
PowerVsFreqUnipolarBP = mean(mean(log10(PowerVsFreqUnipolarBP),3),1);

plot(fig1,freqValsUnipolarBP, PowerVsFreqUnipolarBP, 'color', '#0073aa', 'linewidth',1, 'linestyle','-.');
hold on;
plot(fig1,freqValsUnipolarOBCI, PowerVsFreqUnipolarOBCI, 'color', '#aa3700', 'linewidth',1, 'linestyle','-.');
%legend(fig1,'OBCI-head', 'BP-head', 'Position',[0.3335,0.858,0.128,0.0675]);
xlim(fig1, [0 100]);
ylim(fig1, [-4 2.5]);



% noise corrected data
clear elecData

folderName = fullfile(folderSourceString,'data','testNoiseFiltered',gridType,'160621','GRF_003');
folderSegment= fullfile(folderName,'segmentedData');
OBCIlfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
for iElec = 1:length(electrodeLabels)
    clear temp
    temp = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat']),'analogData');
    elecData(iElec,:,:) = temp.analogData; 
end

timeVals = OBCIlfpInfo.timeVals;
analogChannelsStored = OBCIlfpInfo.analogChannelsStored;
protocolType = 'sfori';
[~,PowerVsFreqUnipolarOBCI,freqValsUnipolarOBCI,~,~,~,~] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,[],bipolarEEGChannelsStored,protocolType,[]);
PowerVsFreqUnipolarOBCI = PowerVsFreqUnipolarOBCI(2,:,:) - PowerVsFreqUnipolarOBCI(1,:,:);
PowerVsFreqUnipolarOBCI = mean(mean(log10(PowerVsFreqUnipolarOBCI),3),1);

clear elecData
folderName = fullfile(folderSourceString,'data','testNoiseFiltered',gridType,'160621','GRF_006');
folderSegment= fullfile(folderName,'segmentedData');
BPlfpInfo = load(fullfile(folderSegment,'LFP','lfpInfo.mat'),'timeVals','analogChannelsStored');
for iElec = 1:length(electrodeLabels)
    clear temp
    temp = load(fullfile(folderSegment,'LFP',['elec' num2str(iElec) '.mat']),'analogData');
    elecData(iElec,:,:) = temp.analogData; 
end

protocolType = 'sfori';
[~,PowerVsFreqUnipolarBP,freqValsUnipolarBP,~,~,~,~] = analyseSingleProtocol(elecData,timeVals,stRange,blRange,[],'unipolar',analogChannelsStored,[],bipolarEEGChannelsStored,protocolType,[]);

PowerVsFreqUnipolarBP = PowerVsFreqUnipolarBP(2,:,:) - PowerVsFreqUnipolarBP(1,:,:);
PowerVsFreqUnipolarBP = mean(mean(log10(PowerVsFreqUnipolarBP),3),1);

plot(fig2,freqValsUnipolarOBCI, PowerVsFreqUnipolarOBCI, 'color', '#aa3700', 'linewidth',1, 'linestyle','-.', 'HandleVisibility','on');
hold on;
plot(fig2,freqValsUnipolarBP, PowerVsFreqUnipolarBP, 'color', '#0073aa', 'linewidth',1, 'linestyle','-.', 'HandleVisibility','on');

legend(fig2,'OBCI-head', 'BP-head','OBCI-Saline','BP-Saline', 'Position', [0.768981140566189,0.795884315906563,0.207837301587301,0.129310344827586]);

xlim(fig2, [0 100]);
ylim(fig2, [-4 2.5]);



%% helper functions

function slopes = slopes(Power,freq, freqpos)

% The Power Law equation is:
% Power = A * freq^(-B) + C where A, B and C are free parameters
% Here, in order to assume C = 0, as an approximation of power at freq=infinity, the power
% at max frequency is subtracted from power at every frequency.
Power = mean(mean(log10(Power),3),1);
unloggedpower = 10.^(Power);
CsubtractedPower = unloggedpower - unloggedpower(end);
Power = log10(CsubtractedPower);
B = regress(Power(freqpos)', [log10(freq(freqpos)); ones(size(freq(freqpos)))]');
slopes = -B(1);

end
