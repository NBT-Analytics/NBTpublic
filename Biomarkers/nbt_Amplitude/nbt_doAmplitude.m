% nbt_doAmplitude - Computes amplitudes
%
% Usage:
% [amplitude_1_4_Hz amplitude_4_8_Hz amplitude_8_13_Hz amplitude_13_30_Hz amplitude_30_45_Hz ... 
%  amplitude_1_4_Hz_Normalized amplitude_4_8_Hz_Normalized amplitude_8_13_Hz_Normalized  ...
%  amplitude_13_30_Hz_Normalized amplitude_30_45_Hz_Normalized] = nbt_doAmplitude(Signal,SignalInfo);
%
% Inputs:
%
% Signal = NBT Signal matrix
% SignalInfo = NBT Info object
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
function [amplitude_1_4_Hz amplitude_4_8_Hz amplitude_8_13_Hz amplitude_13_30_Hz amplitude_30_45_Hz ...
    amplitude_1_4_Hz_Normalized amplitude_4_8_Hz_Normalized amplitude_8_13_Hz_Normalized  ...
    amplitude_13_30_Hz_Normalized amplitude_30_45_Hz_Normalized] = nbt_doAmplitude(Signal,Info)
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

[p,f]=pwelch(randn(1,nfft),hamming(nfft),0,nfft,FS);

for i=1:5
    interval{i}=find(f>interval_Hz(i,1)&f<interval_Hz(i,2));
end

nr_interv=length(interval);

%% calculated integrated and normalized power for all channels

integrated=zeros(nr_interv,number_of_channels);
normalized=zeros(nr_interv,number_of_channels);

for i=1:number_of_channels
    [p,f]=pwelch(Signal(:,i),hamming(nfft),0,nfft,FS);
    p=sqrt(p); % transform power to amplitude
    
    %%%%  plot spectrum for each channel, push enter to see all
    
    %             intervalall=[];
    %             for i=1:5
    %                 intervalall=[intervalall;interval{i}];
    %             end
    %             plot(f(intervalall),p(intervalall))
    %             drawnow
    %             input('')
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    for j=1:nr_interv
        integrated(j,i) = mean(p(interval{j}));
        normalized(j,i) = mean(p(interval{j}))/sum([mean(p([interval{1}]));mean(p([interval{2}]));mean(p([interval{3}]));mean(p([interval{4}]));mean(p([interval{5}]))]);
    end
end

%% Set Bad Channels to NaNs
integrated(:,find(Info.BadChannels)) = NaN;
normalized(:,find(Info.BadChannels)) = NaN;

%% Create amplitude objects and assign values
amplitude_1_4_Hz=nbt_amplitude(number_of_channels,integrated(1,:),[],0,'\muV');
amplitude_4_8_Hz=nbt_amplitude(number_of_channels,integrated(2,:),[],0,'\muV');
amplitude_8_13_Hz=nbt_amplitude(number_of_channels,integrated(3,:),[],0,'\muV');
amplitude_13_30_Hz=nbt_amplitude(number_of_channels,integrated(4,:),[],0,'\muV');
amplitude_30_45_Hz=nbt_amplitude(number_of_channels,integrated(5,:),[],0,'\muV');
amplitude_1_4_Hz.FrequencyRange = interval_Hz(1,:);
amplitude_4_8_Hz.FrequencyRange = interval_Hz(2,:);
amplitude_8_13_Hz.FrequencyRange = interval_Hz(3,:);
amplitude_13_30_Hz.FrequencyRange = interval_Hz(4,:);
amplitude_30_45_Hz.FrequencyRange = interval_Hz(5,:);

amplitude_1_4_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(1,:)*100,[],1,'%');
amplitude_4_8_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(2,:)*100,[],1,'%');
amplitude_8_13_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(3,:)*100,[],1,'%');
amplitude_13_30_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(4,:)*100,[],1,'%');
amplitude_30_45_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(5,:)*100,[],1,'%');
amplitude_1_4_Hz_Normalized.FrequencyRange = interval_Hz(1,:);
amplitude_4_8_Hz_Normalized.FrequencyRange = interval_Hz(2,:);
amplitude_8_13_Hz_Normalized.FrequencyRange = interval_Hz(3,:);
amplitude_13_30_Hz_Normalized.FrequencyRange = interval_Hz(4,:);
amplitude_30_45_Hz_Normalized.FrequencyRange = interval_Hz(5,:);

%% in case of 129-channel EEG data, compute values at 6 subregions and check plotting option

if isfield(Info.Interface,'EEG') && number_of_channels==129
    
    % integrated(:,129)=nanmedian(integrated'); % set reference channel to mean of all channels
    % normalized(:,129)=nanmedian(normalized');
    
    for ii=1:nr_interv
        integrated_regions(ii,:)= nbt_plot_subregions(integrated(ii,:),0);
        normalized_regions(ii,:)=nbt_plot_subregions(normalized(ii,:),0);
    end
    normalized = normalized * 100;
    normalized_regions = normalized_regions*100;
    
%     amplitude_1_4_Hz=nbt_amplitude(number_of_channels,integrated(1,:),integrated_regions(1,:),0,'\muV');
%     amplitude_4_8_Hz=nbt_amplitude(number_of_channels,integrated(2,:),integrated_regions(2,:),0,'\muV');
%     amplitude_8_13_Hz=nbt_amplitude(number_of_channels,integrated(3,:),integrated_regions(3,:),0,'\muV');
%     amplitude_13_30_Hz=nbt_amplitude(number_of_channels,integrated(4,:),integrated_regions(4,:),0,'\muV');
%     amplitude_30_45_Hz=nbt_amplitude(number_of_channels,integrated(5,:),integrated_regions(5,:),0,'\muV');
    amplitude_1_4_Hz.FrequencyRange = interval_Hz(1,:);
    amplitude_4_8_Hz.FrequencyRange = interval_Hz(2,:);
    amplitude_8_13_Hz.FrequencyRange = interval_Hz(3,:);
    amplitude_13_30_Hz.FrequencyRange = interval_Hz(4,:);
    amplitude_30_45_Hz.FrequencyRange = interval_Hz(5,:);
    
%     amplitude_1_4_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(1,:),normalized_regions(1,:),1,'%');
%     amplitude_4_8_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(2,:),normalized_regions(2,:),1,'%');
%     amplitude_8_13_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(3,:),normalized_regions(3,:),1,'%');
%     amplitude_13_30_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(4,:),normalized_regions(4,:),1,'%');
%     amplitude_30_45_Hz_Normalized=nbt_amplitude(number_of_channels,normalized(5,:),normalized_regions(5,:),1,'%');
    amplitude_1_4_Hz_Normalized.FrequencyRange = interval_Hz(1,:);
    amplitude_4_8_Hz_Normalized.FrequencyRange = interval_Hz(2,:);
    amplitude_8_13_Hz_Normalized.FrequencyRange = interval_Hz(3,:);
    amplitude_13_30_Hz_Normalized.FrequencyRange = interval_Hz(4,:);
    amplitude_30_45_Hz_Normalized.FrequencyRange = interval_Hz(5,:);
end



%% update biomarker object 
amplitude_1_4_Hz = nbt_UpdateBiomarkerInfo(amplitude_1_4_Hz, Info);
amplitude_4_8_Hz =nbt_UpdateBiomarkerInfo(amplitude_4_8_Hz , Info);
amplitude_8_13_Hz =nbt_UpdateBiomarkerInfo(amplitude_8_13_Hz, Info);
amplitude_13_30_Hz =nbt_UpdateBiomarkerInfo(amplitude_13_30_Hz, Info);
amplitude_30_45_Hz =nbt_UpdateBiomarkerInfo(amplitude_30_45_Hz, Info);
amplitude_1_4_Hz_Normalized =nbt_UpdateBiomarkerInfo(amplitude_1_4_Hz_Normalized, Info);
amplitude_4_8_Hz_Normalized =nbt_UpdateBiomarkerInfo(amplitude_4_8_Hz_Normalized, Info);
amplitude_8_13_Hz_Normalized  =nbt_UpdateBiomarkerInfo(amplitude_8_13_Hz_Normalized, Info);
amplitude_13_30_Hz_Normalized=nbt_UpdateBiomarkerInfo(amplitude_13_30_Hz_Normalized, Info);
amplitude_30_45_Hz_Normalized=nbt_UpdateBiomarkerInfo(amplitude_30_45_Hz_Normalized, Info);

end
