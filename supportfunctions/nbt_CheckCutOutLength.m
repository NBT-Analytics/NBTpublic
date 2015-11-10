function LengthDifference=nbt_CheckCutOutLength(FirstSignal, SecondSignal, LoadDir)
c =0; 
%--- looping through all files in folder
d = dir(LoadDir);
%--- for files copied from a mac
startindex = 0;
for i = 1:length(d)
    if  strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._') 
        startindex = i+1;
    end
end
%---

LengthDifference = nan(length(d) - startindex,1);
for j= startindex:length(d)
    if(~isempty(strfind(d(j).name,'.mat')));
            if isempty(strfind(d(j).name,'info'));         %Skip Info files
                if isempty(strfind(d(j).name,'analysis')); %Skip analysis files
                    disp(d(j).name)
                    %--- load Signal and SignalInfo
                        clear([FirstSignal])
                        clear([SecondSignal])
                        clear([FirstSignal 'Info'])
                        clear([SecondSignal 'Info'])
                        load ([LoadDir,'/',d(j).name])
                        try
                        load ([LoadDir,'/',d(j).name(1:end-4),'_info.mat'])
                        catch
                        end
                        try
                        c=c+1;
                        eval(['LengthDifference(c) = length(' FirstSignal ')/' FirstSignal 'Info.converted_sample_frequency - length(' SecondSignal ')/' SecondSignal 'Info.converted_sample_frequency;']); 
                        catch
                            c = c-1;
                        end
                end
            end
            end
end

disp('Median Cut-out duration [Seconds] ')
disp(nanmedian(LengthDifference))
disp('Range Cut-out duration [Seconds]')
disp(range(LengthDifference))
                        

end