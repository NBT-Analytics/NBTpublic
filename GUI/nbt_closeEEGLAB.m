close(findobj('Tag','EEGLAB'))
if(exist('EEG','var'))
    if(~isempty(EEG.data))
        disp('Converting EEG set to NBT format...')
        [Signal, SignalInfo,SignalPath] = nbt_EEGlab2NBTsignal(EEG,1);
    end
end

%clean up from EEGlab
clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY EEG LASTCOM STUDY

nbt_gui

