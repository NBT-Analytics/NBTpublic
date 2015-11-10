function nbt_setEyeCh

EyeCh = input('Please specify the Eye channels: ') ;
SignalName = input('Specify the SignalName: ','s');

nbt_NBTcompute(@nbt_setEyeChInner,SignalName,pwd,pwd,[],[],EyeCh,SignalName)
end

function nbt_setEyeChInner(Signal, SignalInfo, SignalPath,EyeCh, SignalName)
SignalInfo.EyeCh = EyeCh;
nbt_SaveSignal(Signal, SignalInfo, SignalPath,1,SignalName)
end