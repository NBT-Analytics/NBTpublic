function PowerObject = nbt_doPower(Signal,SignalInfo);

%%    assigning fields
disp(' ')
disp('Command window code:')
disp(['nbt_power(Signal,SignalInfo)'])
disp(' ')

disp(['Computing Absolute Power for ',SignalInfo.file_name])

nfft=2^10; %number of fast fourier transforms, higher this number and the frequency resolution of the spectrum goes up,
number_of_channels=size(Signal,2);
%% remove artifact intervals	

Signal = nbt_RemoveIntervals(Signal,SignalInfo);

%%       determine intervals at which power is calculated

FS=SignalInfo.converted_sample_frequency;


%%                 calculated integrated and normalized power for all channels

for i=1:number_of_channels
    [p,f]=pwelch(Signal(:,i),hamming(nfft),0,nfft,FS);
    power(i,:) = p;
end
fbins = length(f);

%% Set Bad Channels to NaNs
power(:,find(SignalInfo.BadChannels)) = NaN;
PowerObject = nbt_Power(number_of_channels,fbins,'\muV^2');
PowerObject.Power = power;
PowerObject.Frequencybins = f;
    
PowerObject = nbt_UpdateBiomarkerInfo(PowerObject, SignalInfo);
end
