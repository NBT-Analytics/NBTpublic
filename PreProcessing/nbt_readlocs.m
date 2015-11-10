function [SignalInfo] = nbt_readlocs(SignalInfo, ReadLocFilename)
SignalInfo.Interface.EEG.chanlocs = readlocs(ReadLocFilename);
end