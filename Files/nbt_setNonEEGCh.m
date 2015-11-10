function nbt_setNonEEGCh

NonEEGch = input('Please specify the Non-EEG channels: ') ;
SignalName = input('Specify the SignalName: ','s');

nbt_NBTcompute(@nbt_setNonEEGChInner,SignalName,pwd,pwd,[],[],NonEEGch,SignalName)
end

function nbt_setNonEEGChInner(Signal, SignalInfo, SignalPath,NonEEGch, SignalName)
SignalInfo.NonEEGch = NonEEGch;
nbt_SaveSignal(Signal, SignalInfo, SignalPath,1,SignalName)
end