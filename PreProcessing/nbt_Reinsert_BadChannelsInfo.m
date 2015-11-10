function newInfo = Reinsert_BadChannelsInfo(Info)
%Rewrites channel labels.  For those channels that are missing they are
%labelled as NaN.
%Assumes Cz channel has not been removed, and that order is always kept the
%same

offset = 0;
newInfo = Info;
newInfo.BadChannels = zeros(129,1);
clear newInfo.Interface.EEG.chanlocs
for i = 1:128
    
    if i == str2num(Info.Interface.EEG.chanlocs(i+offset).labels(:,2:end))
        newInfo.Interface.EEG.chanlocs(i) = Info.Interface.EEG.chanlocs(i+offset);
    else
%        newInfo.Interface.EEG.chanlocs(i + offset).labels = sprintf('E%i',i+offset);
        newInfo.Interface.EEG.chanlocs(i).labels = 'NaN';
        newInfo.BadChannels(i) = 1;
        offset = offset - 1;
    end
end
newInfo.Interface.EEG.chanlocs(129) = Info.Interface.EEG.chanlocs(end);

end
