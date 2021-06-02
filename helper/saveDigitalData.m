% This function is used to save the digital data. It is independent of the
% protocol or recording hardware.

function saveDigitalData(digitalEvents,digitalTimeStamps,folderExtract,useSingleITC18Flag)

if ~exist('useSingleITC18Flag','var');     useSingleITC18Flag=1;        end

% Special cases in case a singleITC is used.
if useSingleITC18Flag
    % First, find the reward signals
    rewardOnPos = find(rem(digitalEvents,2)==0);
    rewardOffPos = rewardOnPos + 1;
    
    if max(abs((digitalEvents(rewardOnPos) - digitalEvents(rewardOffPos))+1))>0
        disp('Reward on and reward off digital codes do not match!!');
    else
        rewardPos = [rewardOnPos(:) ; rewardOffPos(:)];
        disp([num2str(length(rewardOnPos)) ' are reward signals and will be discarded' ]);
        digitalEvents(rewardPos)=[];
        digitalTimeStamps(rewardPos)=[];
    end
    digitalEvents=digitalEvents-1;
end

% All digital codes all start with a leading 1, which means that they are greater than hex2dec(8000) = 32768.
modifiedDigitalEvents = digitalEvents(digitalEvents>32768) - 32768;
allCodesInDec = unique(modifiedDigitalEvents);
disp(['Number of distinct codes: ' num2str(length(allCodesInDec))]);
allCodesInStr = convertDecCodeToStr(allCodesInDec,useSingleITC18Flag);

clear identifiedDigitalCodes badDigitalCodes
count=1; badCount=1;
for i=1:length(allCodesInDec)
    if ~digitalCodeDictionary(allCodesInStr(i,:))
        disp(['Unidentified digital code: ' allCodesInStr(i,:) ', bin: ' dec2bin(allCodesInDec(i),16) ', dec: ' num2str(allCodesInDec(i)) ', occured ' num2str(length(find(modifiedDigitalEvents==allCodesInDec(i))))]);
        badDigitalCodes(badCount) = allCodesInDec(i);
        badCount=badCount+1;
    else
        identifiedDigitalCodes(count) = allCodesInDec(i);
        count=count+1;
    end
end

if badCount>1
    disp(['The following Digital Codes are bad: ' num2str(badDigitalCodes)]);
end

numDigitalCodes = length(identifiedDigitalCodes);
disp(['Number of distinct codes identified: ' num2str(numDigitalCodes)]);

for i=1:numDigitalCodes
    digitalCodeInfo(i).codeNumber = identifiedDigitalCodes(i); %#ok<*AGROW>
    digitalCodeInfo(i).codeName = convertDecCodeToStr(identifiedDigitalCodes(i));
    clear codePos
    codePos = find(identifiedDigitalCodes(i) == digitalEvents-32768);
    digitalCodeInfo(i).time = digitalTimeStamps(codePos);
    if (digitalCodeInfo(i).codeNumber <=256) % simple codes that are not followed by any value
        digitalCodeInfo(i).value = 0;
    else
        digitalCodeInfo(i).value = getValue(digitalEvents(codePos+1),useSingleITC18Flag);
    end
end

% Write the digitalCodes
makeDirectory(folderExtract);
save(fullfile(folderExtract,'digitalEvents.mat'),'digitalCodeInfo','digitalTimeStamps','digitalEvents');
end
function outNum = getValue(num,useSingleITC18Flag)

for i=1:length(num)
    if num(i) > 16384
        num(i)=num(i)-32768;
    end
end

if useSingleITC18Flag
    outNum=num/2;
end
end