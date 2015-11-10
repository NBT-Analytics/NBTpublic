% nbt_AutoRejectTransient(Signal,SignalInfo,method)
%
%
%
% Usage:
%
%
% Inputs:
%
%    
% Outputs:
%
% Example:
%
%
% References:
% 
% See also: 
%
  
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2012), see NBT website for current
% email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2012 Simon-Shlomo Poil  
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% ---------------------------------------------------------------------------------------


function [Signal, SignalInfo]=nbt_AutoRejectTransient(Signal, SignalInfo, NonEEGCh)
% This algorithm uses the combined solution of two algorithms
eeg_chans = nbt_negSearchVector(1:size(Signal,2),NonEEGCh);
[Signal, SignalInfo, RemovedData, OldChanlocs] = nbt_RemoveChan(Signal,SignalInfo, NonEEGCh);
%convert to EEG structure
EEG = nbt_NBTtoEEG(Signal, SignalInfo, []);

try
    EEG = eeg_interp(EEG, nbt_negSearchVector(find(EEG.NBTinfo.BadChannels),NonEEGCh));
catch
end
[Signal, SignalInfo]=nbt_EEGtoNBT(EEG, [] , []);
[Signal, SignalInfo] =nbt_AddChan(Signal,SignalInfo, RemovedData, NonEEGCh, OldChanlocs);

EEG = nbt_NBTtoEEG(Signal, SignalInfo, []);

% disp('High-pass filter 0.5 Hz - low-pass filter 45 Hz')
% data = nbt_filter_fir(EEG.data',0.5,45,EEG.srate,4);
% % adjust filter offset
% disp('adjusting filter offset 2000 ms')
% EEG.data = data((2*EEG.srate):end,:)';
 posA =nbt_highdiff(EEG.data');

%faster method
% need to epoch here> to 1 second
EEGold = EEG;
% first epoch data
lag = 1;
ntrials=floor((EEG.xmax-EEG.xmin)/lag);
nevents=length(EEG.event);
for index=1:ntrials
    EEG.event(index+nevents).type=[num2str(lag) 'sec'];
    EEG.event(index+nevents).latency=1+(index-1)*lag*EEG.srate; %EEG.srate is the sampling frequency
    latency(index)=1+(index-1)*lag*EEG.srate;
end;

EEG=eeg_checkset(EEG,'eventconsistency');

EEG = pop_epoch( EEG, {  [num2str(lag) 'sec']  }, [0 lag], 'newname', [EEG.setname '_ep' num2str(lag)] , 'epochinfo', 'yes');
% removing baseline
EEG = pop_rmbase( EEG, []);
EEG = eeg_checkset(EEG);


list_properties = epoch_properties(EEG,eeg_chans);
rejection_options.measure=ones(1,size(list_properties,2)); % values of the statistical parameters (see flow chart)
rejection_options.z=3*ones(1,size(list_properties,2)); % Z-score threshold
[fasterPosA] = min_z(list_properties,rejection_options); % rejected epochs

fasterPosA = find(fasterPosA)*EEG.srate;

%union of FasterPosA and posA
posA = union(fasterPosA, posA);

%build posAtimes 
posAtimes = zeros(length(posA),2);
rejlag = (lag+0.5)*EEG.srate;
rejlagback = (lag+1)*EEG.srate;
for i=1:length(posA)
    posAtimes(i,1) = posA(i)-rejlagback;
    posAtimes(i,2) = posA(i)+rejlag;
end

posAtimes(posAtimes(:,1) <= 0,1) = 1;
posAtimes(posAtimes(:,2) > size(EEGold.data,2),2) = size(EEGold.data,2); 

EEGold=eeg_eegrej(EEGold, posAtimes);
[Signal, SignalInfo]=nbt_EEGtoNBT(EEGold, [] , []);
end
