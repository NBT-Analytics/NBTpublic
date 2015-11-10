function EEG=nbt_genericEEGLABImport(filename)
load(filename)
EEG = eeg_emptyset;

EEG.data = 'your variable';
EEG.srate = 'your sample frq';
end