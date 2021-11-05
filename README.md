This folder contains all files pertinent to the OpenBCI_GammaProject. For details on protocol, methods and results, please refer to the paper.

### Data format:

1. **Raw Data**: as obtained directly from the EEG recording systems ([OpenBCI](https://openbci.com/) and [BrainProducts](https://www.brainproducts.com/)) and the stimulus presenting software ([MonkeyLogic](https://monkeylogic.nimh.nih.gov/)). The data for each subject is stored in a separate folder inside the directory `data/rawData`.
2. **Segmented data**: Segments of data around the stimulus onset are extracted and saved from Raw Data. The data for each subject is stored in a separate folder for noisy and noise corrected data inside the directory `data`. Each protocol for every subject has the following subfolders:
    2a. `extractedData`: this contains para-EEG data like monkeylogic data and digital events data.
    2b. `segmentedData`: this contains electrode wise data for each protocol and some auxiliary information in lfpInfo.mat.

### Programs:

The codes are divided into two folders : `main` and `helper`. All subfolders in this folder must be added to MATLAB path. Other dependencies include [Chronux toolbox](http://chronux.org/) and [EEGLab](https://sccn.ucsd.edu/~scott/ica.html).

1. To generate Segmented Data from Raw Data, run `runExtractAllProtocolsOBCIGammaProject.m` from the `main` folder. (To generate line noise corrected version of the same, run `runExtractAllProtocolsOBCIGammaProjectNoiseCorrected.m`). The source folder and output folder paths must changed according to the location in which the data folders are present before running these programs.

2. To perform spectral analysis on the Segmented Data, run `analyseAllData.m` from the `main` folder. (`analyseAllDataNoiseCorrected.m` for the line noise corrected version of the same). This program outputs a struct which is necessary to run the subsequent figure codes. The source folder path must changed according to the user's preference before running these programs.

3. The figure codes include the scripts for each figure independently (both main figures and supplementary figures), which can be run independently after the first two steps.

### MonkeyLogic files:

This folder consists of the stimuli that were presented to the subjects and the files needed to run NIMH MonkeyLogic (the sfOriConditions.txt is the conditions file and the timing_script_1.m is the instruction file that determines the sequence of images to be presented and event markers to send).

### Protocol names
- GRF001 and GRF002: one minute eye open and eye closed recordings from OpenBCI respectively
- GRF003: Visual fixation task for stimulus induced gamma experiment for OpenBCI
- GRF004 and GRF005: one minute eye open and eye closed recordings from Brain Products respectively
- GRF006: Visual fixation task for stimulus induced gamma experiment for Brain Products