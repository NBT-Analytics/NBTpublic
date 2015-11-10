function EEG=nbt_MarkICBadChannel(EEG)

answer = inputdlg('ICA components to mark?');
answer = str2num(answer{1});

for i=1:length(answer)
    [dummy BadChannel(i)] = max(abs( EEG.icaweights(answer(i),:)));
    BadChannel(i) = EEG.icachansind(BadChannel(i));
end
indelec =zeros(EEG.nbchan,1);
indelec(BadChannel) = 1;

if(~isempty(EEG.NBTinfo.BadChannels))
    EEG.NBTinfo.BadChannels(find(indelec)) = 1;
else
    EEG.NBTinfo.BadChannels = indelec;
end
disp('Remember to update ICA')
end