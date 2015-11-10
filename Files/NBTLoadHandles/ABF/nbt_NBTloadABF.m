

function [Signal, SignalInfo] = nbt_NBTloadABF(filename, SignalPath)

[Signal,si,h]=abfload([SignalPath],'start',0,'stop','e','channels','a');
Fs = h.dataPtsPerChan/(h.recTime(2)-h.recTime(1));
SignalInfo = nbt_CreateInfoObject(filename, [], Fs);

end