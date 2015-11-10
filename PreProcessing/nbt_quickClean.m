function [Signal, SignalInfo]=nbt_quickClean(Signal, SignalInfo)

%make EEGlab structure.
EEG=nbt_NBTtoEEG(Signal, SignalInfo, '');

 %EEG = pop_iirfilt(EEG);
 disp('High-pass filter 0.5 Hz - low-pass filter 70 Hz')
 data = nbt_filter_fir(EEG.data',0.5,70,EEG.srate,4);
 % adjust filter offset
 disp('adjusting filter offset 2000 ms')
 EEG.data = data((2*EEG.srate):end,:)';
 EEG.pnts = size(EEG.data,2);

 %remove artifacts
 posA = nbt_highdiff(data(2*EEG.srate:end,:));
 
 if(~isempty(posA))
 for i=1:length(posA)
    EventTimes(i,1) = posA(i) - EEG.srate;
    EventTimes(i,2) = posA(i) + 500+EEG.srate;
 end
 
 if(EventTimes(length(posA),2) > size(EEG.data,2))
    EventTimes(length(posA),2) = size(EEG.data,2); 
 end
 
 if(EventTimes(1,1) < 1)
     EventTimes(1,1) =1;
 end
 
 EEG.event = []
 EEG = eeg_eegrej(EEG,EventTimes);
 end
 
 %Run ICA

EEG = pop_runica(EEG, 'icatype','jader');


% auto reject ICA
[EEG,IcsRejected]  = nbt_AutoRejectICA(EEG,[1 2],0);
 
[Signal, SignalInfo] = nbt_EEGtoNBT(EEG, '', '');

end