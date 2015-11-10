% nbt_doSpecificAmplitude - Computes amplitudes
%
% Usage:
% [amplitude amplitude_Normalized] = nbt_doSpecificAmplitude(Signal,SignalInfo,FrequencyRange);
%
% Inputs:
%
% Signal = NBT Signal matrix
% SignalInfo = NBT Info object
% FrequencyRange 1x2 vector indicating lower and higher frquency range
%
% Outputs: several amplitude biomarker objects
%
% This function creates amplitude biomarker objects, where it stores integrated amplitudes in several frequency bands per channel and per sub region.
% Optionally, it plots integrated amplitudes in several frequency bands in
% three different ways: per channel color coded, spatially interpolated,
% and the mean in 6 subregions color coded.

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2012), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group,
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research,
% Neuroscience Campus Amsterdam, VU University Amsterdam)
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
% -------------------------------------------------------------------------
function [amplitude amplitude_Normalized] = nbt_doSpecificAmplitude(Signal,Info,FrequencyRange)
%--- input checks
% error(nargchk(4,4,nargin))

%%   give information to the user
disp(['Computing Amplitudes for ',Info.file_name])

%%    assigning fields
coolWarm = load('nbt_CoolWarm','coolWarm');
coolWarm = coolWarm.coolWarm;
color_scale = '0-max'; %'min-max'; % '0-max' # set color scale: from zero to max or from min to max
save_pdf_plot=0;
plotting=0;
nfft=2^10; %number of fast fourier transforms, higher this number and the frequency resolution of the spectrum goes up,
number_of_channels=size(Signal,2);

%% remove artifact intervals
Signal = nbt_RemoveIntervals(Signal,Info);

%% determine intervals at which power is calculated

FS=Info.converted_sample_frequency;

interval_Hz(1,:)=[1 4];
interval_Hz(2,:)=[4 8];
interval_Hz(3,:)=[8 13];
interval_Hz(4,:)=[13 30];
interval_Hz(5,:)=[30 45];

selected_Hz(1,:) = FrequencyRange;

[p,f]=pwelch(randn(1,nfft),hamming(nfft),0,nfft,FS);

for i=1:size(interval_Hz,1);
    interval{i}=find(f>interval_Hz(i,1)&f<interval_Hz(i,2));
end
interval{end+1} = find(f>selected_Hz(1,1)&f<selected_Hz(1,2));
nr_interv=length(interval);

%% calculated integrated and normalized power for all channels

integrated=zeros(nr_interv,number_of_channels);
normalized=zeros(nr_interv,number_of_channels);

for i=1:number_of_channels
    [p,f]=pwelch(Signal(:,i),hamming(nfft),0,nfft,FS);
    p=sqrt(p); % transform power to amplitude
    
        integrated(1,i) = mean(p(interval{end}));
        norm_dividende = 0;
        for j = 1:length(interval)-1
            norm_dividende = norm_dividende + mean(p(interval{j}));
        end
        normalized(1,i) = mean(p(interval{end}))/norm_dividende;
%     end
end


%% Set Bad Channels to NaNs
integrated(:,find(Info.BadChannels)) = NaN;
normalized(:,find(Info.BadChannels)) = NaN;

%% Create amplitude objects and assign values
amplitude = nbt_amplitude(number_of_channels,integrated(1,:),[],0,'\muV');
amplitude.FrequencyRange = FrequencyRange;
amplitude_Normalized = nbt_amplitude(number_of_channels,normalized(1,:)*100,[],1,'%');
amplitude_Normalized.FrequencyRange = FrequencyRange;



end