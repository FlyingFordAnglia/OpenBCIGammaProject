% mains noise attenuation for OpenBCI

function [eegData] = correctMainsNoiseOBCI(eegData,segmentLength,Fs)

if ~exist('segmentLength','var'); segmentLength = 180; end

        for iElec = 1:8
            rawData = eegData{:,iElec+1};
            counter = 1;
            while counter < length(rawData)
                if (counter + (segmentLength*Fs)) <= length(rawData)
                    segmentIndices = counter : (counter + (segmentLength*Fs) - 1);
                else
                    segmentIndices = counter : length(rawData);
                end
                segmentToBeNoiseCorrected = rawData(segmentIndices);
                fftX = fft(segmentToBeNoiseCorrected);
                absfftX = abs(fftX);
                freqVals = 0:1/(length(segmentIndices)/Fs):Fs-1/(length(segmentIndices)/Fs); 
                freqPos = find(freqVals>40 & freqVals<60);
                maxPos = find(absfftX==max(absfftX(freqPos)));
                fftNX = zeros(1,length(fftX));
                fftNX(maxPos) = fftX(maxPos);
                noiseSignal = ifft(fftNX);
                noiseCorrectedSegment = segmentToBeNoiseCorrected - noiseSignal';
                rawData(segmentIndices) = noiseCorrectedSegment;
                counter = counter + (segmentLength*Fs) - 1;

            end
            eegData{:,iElec+1} = rawData;
        end

end