function [elecImpedanceLabels,elecImpedanceValues] = getImpedanceDataOBCI(subjectName,expDate,folderSourceString)

folderIn = fullfile(folderSourceString,'data','rawData',[subjectName expDate]);
fileName = [subjectName expDate 'impedance_start'];
impedanceData = readtable(fullfile(folderIn, fileName), 'ReadVariableNames', 0);
elecImpedanceLabels = transpose(impedanceData{:, 1});
elecImpedanceValues = transpose(impedanceData{:, 2});
end