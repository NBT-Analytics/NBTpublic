function Data=nbt_FindAbnormalData(Data)

%Data(channels, subjects)
%Return Data with NaN

%high/low channel IQR across subjects
chIQR = iqr(Data);
% Data(:,(chIQR > (iqr(chIQR)*2.5+nanmedian(chIQR)))) = nan;
% Data(:,(chIQR < (nanmedian(chIQR)-iqr(chIQR)*2.5))) = nan;

%larger than 1.5 IQR across subjects
%larger than 1.5 IQR across channels
subjIQR = iqr(Data,2);
for i=1:size(Data,2)
    disp(i)
    for chId =1:size(Data,1)
        if(Data(chId,i) > (nanmedian(Data(chId,:))+subjIQR(chId)*2.5)  || Data(chId,i) < (nanmedian(Data(chId,:))-subjIQR(chId)*2.5) )
            Data(chId,i) = nan;
        end
        if(Data(chId,i) > (nanmedian(Data(:,i))+chIQR(i)*2.5)  || Data(chId,i) < (nanmedian(Data(:,i))-chIQR(i)*2.5) )
            Data(chId,i) = nan;
        end
    end
end
end