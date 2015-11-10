
%author: Ilse Verweij, Netherlands Institue for Neuroscience
function nr=nbt_FindNrofCompForICA(EEG)
try
if(~isempty(EEG.NBTinfo.BadChannels))
    [COEFF, SCORE, LATENT] = princomp(EEG.data(find(EEG.NBTinfo.BadChannels~=1),:)');
else
    [COEFF, SCORE, LATENT] = princomp(EEG.data');
end
catch
   [COEFF, SCORE, LATENT] = princomp(EEG.data'); 
end
tmp  = cumsum(LATENT);
nr=find(tmp/tmp(end)>0.975,1);
if( length(EEG.data)/nr^2 < 20)
    disp('Data set too short for proper ICA')
    nr = floor(sqrt((length(EEG.data)/20))) - 1 ;
end
end