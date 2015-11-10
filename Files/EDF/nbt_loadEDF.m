function EEG = nbt_loadEDF(filewithpath)

EEG = pop_biosig(filewithpath);
%temp for specific import
% EEG.data = EEG.data(1:26,:);
% EEG.nbchan = 26;
% EEG.chanlocs = readlocs('rTMSchanlocs.sfp');
%temp end

end