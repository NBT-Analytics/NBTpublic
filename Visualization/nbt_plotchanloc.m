function EEG=nbt_plotchanloc(EEG, type)
figure;

if(strcmpi('name',type))
    topoplot([], EEG.chanlocs, 'style', 'blank','electrodes','labelpoint','chaninfo',EEG.chaninfo);
elseif (strcmpi('number',type))
     topoplot([], EEG.chanlocs, 'style', 'blank','electrodes','numpoint','chaninfo',EEG.chaninfo);
end
end