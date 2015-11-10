function [Signal, SignalInfo] = nbt_removeNaN(Signal, SignalInfo, NonEEGCh)


[TimeIndex,ChannelIndex] = find(isnan(Signal));
[Signal, SignalInfo, RemovedData, OldChanlocs] = nbt_RemoveChan(Signal,SignalInfo, NonEEGCh);
%convert to EEG structure
EEG = nbt_NBTtoEEG(Signal, SignalInfo, []);

% only interpolate data with NaN
EEGtmp = EEG;
EEGtmp.data = EEGtmp.data(:,unique(TimeIndex));


try
    EEGtmp = eeg_interp(EEGtmp, unique(ChannelIndex));
catch
end
EEG.data(:,unique(TimeIndex)) = EEGtmp.data;
[Signal, SignalInfo] = nbt_EEGtoNBT(EEG, [] , []);
[Signal, SignalInfo] = nbt_AddChan(Signal,SignalInfo, RemovedData, NonEEGCh, OldChanlocs);

% Final check for NaN data - just remove all  (obviously not perfect)
[TimeIndex,ChannelIndex] = find(isnan(Signal));
Signal = Signal(nbt_negSearchVector(1:size(Signal,1), TimeIndex),:);


end