% This program needs the struct() allSubjectData obtained by running analyseAllData.m
% Likewise for line noise filtered data.
% 

% Figure 1 from the main manuscript including
% Mean PSD of all subjects and Mean Slopes of these PSDs for both OpenBCI and BrainProducts

% analyseAllData;
% analyseAllDataNoiseFiltered;
clearvars -except allSubjectDataNoiseFiltered allSubjectData



freqVals = allSubjectData(1).allProtocolsData(3).bipolarAnalysis.freqValsBipolar;

% freq range 1 to calculate slope
freqPos1 = find(freqVals <= 38 & freqVals >= 16);

% freq range 2 to calculate slope
freqPos2 = find(freqVals <= 84 & freqVals >= 68);

lastFreqPos = find(freqVals == 125);

OBCIPowerAllSubjects = [];
BPPowerAllSubjects = [];
OBCISlope1AllSubjects = [];
OBCISlope2AllSubjects = [];
BPSlope1AllSubjects = [];
BPSlope2AllSubjects = [];
colors = [170 55 0; 0 115 170]/255;
figure();

for iSub = 1:length(allSubjectData)
    baselinePowerOBCI = allSubjectData(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerOBCI = mean(mean(log10(baselinePowerOBCI),3),1);
    OBCIPowerAllSubjects = [OBCIPowerAllSubjects baselinePowerOBCI'];
    
    baselinePowerBP = allSubjectData(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerBP = mean(mean(log10(baselinePowerBP),3),1);
    BPPowerAllSubjects = [BPPowerAllSubjects baselinePowerBP'];
    
    OBCIslope1 = slopes(allSubjectData(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    OBCISlope1AllSubjects = [OBCISlope1AllSubjects OBCIslope1];
    
    OBCIslope2 = slopes(allSubjectData(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    OBCISlope2AllSubjects = [OBCISlope2AllSubjects OBCIslope2];
    
    BPslope1 = slopes(allSubjectData(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    BPSlope1AllSubjects = [BPSlope1AllSubjects BPslope1];

    BPslope2 = slopes(allSubjectData(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
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
ylimits = ylim;
title('Raw Data');
xlabel('Frequency (Hz)');
ylabel('log10 Power (\muV^2)');

% xticks(fig1,[log10(10) log10(50) log10(100)]);
% xticklabels(fig1,[10,50,100])


fig3 = subplot(2,2,3);
% Slope comparison of OBCI and BP
meanSlopes = [mean(OBCISlope1AllSubjects) mean(BPSlope1AllSubjects); mean(OBCISlope2AllSubjects) mean(BPSlope2AllSubjects)];
semSlopes = [std(OBCISlope1AllSubjects)/sqrt(length(OBCISlope1AllSubjects)) std(BPSlope1AllSubjects)/sqrt(length(BPSlope1AllSubjects)); std(OBCISlope2AllSubjects)/sqrt(length(OBCISlope2AllSubjects)) std(BPSlope2AllSubjects)/sqrt(length(BPSlope2AllSubjects))];
barhandle = bar(fig3,categorical({'16-38 Hz','62-84 Hz'}),meanSlopes,'FaceColor','flat');
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
ylabel('Mean Slope across subjects');


%% Noise corrected

OBCIPowerAllSubjects = [];
BPPowerAllSubjects = [];
OBCISlope1AllSubjects = [];
OBCISlope2AllSubjects = [];
BPSlope1AllSubjects = [];
BPSlope2AllSubjects = [];

for iSub = 1:length(allSubjectDataNoiseFiltered)
    baselinePowerOBCI = allSubjectDataNoiseFiltered(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerOBCI = mean(mean(log10(baselinePowerOBCI),3),1);
    OBCIPowerAllSubjects = [OBCIPowerAllSubjects baselinePowerOBCI'];
    
    baselinePowerBP = allSubjectDataNoiseFiltered(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar;
    baselinePowerBP = mean(mean(log10(baselinePowerBP),3),1);
    BPPowerAllSubjects = [BPPowerAllSubjects baselinePowerBP'];
    
    OBCIslope1 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    OBCISlope1AllSubjects = [OBCISlope1AllSubjects OBCIslope1];
    
    OBCIslope2 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(3).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    OBCISlope2AllSubjects = [OBCISlope2AllSubjects OBCIslope2];
    
    BPslope1 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos1);
    BPSlope1AllSubjects = [BPSlope1AllSubjects BPslope1];

    BPslope2 = slopes(allSubjectDataNoiseFiltered(iSub).allProtocolsData(6).bipolarAnalysis.blPowerVsFreqBipolar, freqVals, freqPos2);
    BPSlope2AllSubjects = [BPSlope2AllSubjects BPslope2];
end




fig2 = subplot(2,2,2);
meanPSDOBCI = squeeze(mean(OBCIPowerAllSubjects,2));
stdPSDOBCI = squeeze(std(OBCIPowerAllSubjects')) / sqrt(size(OBCIPowerAllSubjects, 2));
meanPSDBP = squeeze(mean(BPPowerAllSubjects,2));
stdPSDBP = squeeze(std(BPPowerAllSubjects')) / sqrt(size(BPPowerAllSubjects, 2));
plot(fig2,(freqVals),meanPSDOBCI,'linewidth',1.0,'color','#aa3700');
hold on
plot(fig2,(freqVals),meanPSDBP,'linewidth',1.0,'color','#0073aa');
yUp = meanPSDOBCI + stdPSDOBCI';
yDown = meanPSDOBCI - stdPSDOBCI';
s = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0');
s.FaceColor = '#aa3700';
yUp = meanPSDBP + stdPSDBP';
yDown = meanPSDBP - stdPSDBP';
s2 = fill([freqVals fliplr(freqVals)], [yUp' fliplr(yDown')],'red', 'FaceAlpha', '0.4', 'EdgeAlpha', '0');
s2.FaceColor = '#0073aa';
xlim([0 100]);
ylimits = ylim;
ylabel('log10 Power (\muV^2)');
title('Line Noise Corrected Data');
xlabel('Frequency (Hz)');


fig4 = subplot(2,2,4);
meanSlopes = [mean(OBCISlope1AllSubjects) mean(BPSlope1AllSubjects); mean(OBCISlope2AllSubjects) mean(BPSlope2AllSubjects)];
semSlopes = [std(OBCISlope1AllSubjects)/sqrt(length(OBCISlope1AllSubjects)) std(BPSlope1AllSubjects)/sqrt(length(BPSlope1AllSubjects)); std(OBCISlope2AllSubjects)/sqrt(length(OBCISlope2AllSubjects)) std(BPSlope2AllSubjects)/sqrt(length(BPSlope2AllSubjects))];
barhandle = bar(fig4,categorical({'16-44 Hz','56-84 Hz'}),meanSlopes,'FaceColor','flat');
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
legend(fig4,'location','northeast');
ylim([ylimits2(1) ylimits2(2)]);
for k = 1:size(meanSlopes,2)
    barhandle(k).CData = colors(k,:);
end


%% helper functions

function slopes = slopes(power,freq, freqpos)

% The Power Law equation is:
% Power = A * freq^(-B) + C where A, B and C are free parameters
% Here, in order to assume C = 0, as an approximation of power at freq=infinity, the power
% at max frequency is subtracted from power at every frequency.
power = mean(mean(log10(power),3),1);
unloggedpower = 10.^(power);
CsubtractedPower = unloggedpower - unloggedpower(end);
power = log10(CsubtractedPower);
B = regress(power(freqpos)', [log10(freq(freqpos)); ones(size(freq(freqpos)))]');
slopes = -B(1);

end
