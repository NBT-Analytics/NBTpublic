function nbt_writebv(Signal, SignalInfo, SignalPath)

EEG = nbt_NBTtoEEG(Signal, SignalInfo, []);

 pop_writebva(EEG, SignalInfo.file_name);
end