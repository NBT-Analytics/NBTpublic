% FindBadChannels() - Finds bad channels based on kurtosis and adds them to
% Info.BadChannels
%
% Usage:
%   >>  EEG=FindBadChannels(EEG)
%
% Inputs:
%   EEG     - EEGlab structure
%
% Outputs:
%   EEG     - EEGlab structure
%

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and 
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------

function EEG=nbt_FindBadChannels(EEG,flag, NonEEGCh)
error(nargchk(1, 3, nargin))
auto =1;
if(~(exist('flag')==1) || isempty(flag))
    flag = input('Do you want to use Joint probability, Kurtosis, Faster toolbox, Correlation method, PCA method, or abnormal Spectra? (Write J, K, F, C, P or S) ','s');
    auto = 0;
end
if (strcmp('K', flag) || strcmp('k',flag))
    [ measure indelec ] = rejkurt( EEG.data, 5, [], 2);
    disp('Based on kurtosis the following channels are probably bad')
elseif(strcmp('J', flag) || strcmp('j',flag))
    maxThres = input('Specify maximum threshold: ');
    [ measure indelec ] = jointprob( EEG.data, maxThres, [], 2);
    disp('Based on joint probability the following channels may be bad')
elseif(strcmp('S', flag) || strcmp('s',flag))
    [spec]=spectopo(EEG.data,0,EEG.srate);
    if(auto)
        close all
    end
    temp=sum(spec,2);
    indelec = zeros(size(EEG.data,1),1);
    indelec(find(temp > (1.5*iqr(temp)+median(temp))))= 1;
elseif(strcmp('P',flag) || strcmp('p',flag))
    data = nbt_filter_firHp(EEG.data,0.5,EEG.srate,4);
    [eigvec] = pcsquash(data',10);
    indelec = zeros(size(EEG.data,1),1);
    eigzs = zscore(eigvec(:,1));
    indelec(find(abs(eigzs)>1.5*iqr(eigzs)))= 1;
elseif(strcmp('F',flag) || strcmp('f',flag))
    if(exist('NonEEGCh', 'var')) %remove Non-EEG channels
        list_properties = channel_properties(EEG,nbt_negSearchVector(1:(size(EEG.data,1)),NonEEGCh),EEG.ref);
    else 
        list_properties = channel_properties(EEG,1:(size(EEG.data,1)),EEG.ref);
    end
    rejection_options.measure=ones(1,size(list_properties,2));
    rejection_options.z=3*ones(1,size(list_properties,2));
    [indelec] = min_z(list_properties,rejection_options);
    if(exist('NonEEGCh','var')) %put the channels back *set NonEEGCh as bad
       tmpindelec = ones(size(EEG.data,1),1);
       tmpindelec(nbt_negSearchVector(1:(size(EEG.data,1)), NonEEGCh),1) = indelec;
       indelec = tmpindelec;
    end
elseif (strcmp('C',flag) || strcmp('c',flag))
    data = nbt_filter_fir(EEG.data',0.5,70,EEG.srate,4);
    data = data';
    elecdis = ep_closestChans(EEG.chanlocs);
    channelcorr = nan(EEG.nbchan,1);
    for i=1:EEG.nbchan
        nabochan = find(elecdis(i,:)<3);
        nabochan = nabochan(nabochan ~= 257);
        channelcorr(i) = nanmedian(corr(abs(data(i,4*EEG.srate:end))',abs(data([nabochan],4*EEG.srate:end))','type','spearman'));
    end
    channelcorr = channelcorr(1:end-1);
    indelec = zeros(EEG.nbchan,1);
    indelec(find(channelcorr<0.4)) =1;
else
    disp('This option does not exist!')
end

disp('Bad channels:');
disp(find(indelec));



if(~auto)
    if(~isempty(find(indelec)))
        try
            colors = cell(1,size(EEG.data,1)); colors(:) = { 'k' };
            colors(find(indelec)) = { 'r' }; colors = colors(end:-1:1);
            eegplot(EEG.data,'color',colors); %plot bad channels
            vector = zeros(1,EEG.nbchan);
            vector(indelec) = 1;
            figure
            set(gcf,'numbertitle','off');
            set(gcf,'name','NBT: EEG Topography');
            nbt_plot_EEG_channels_and_numbers(vector,indelec,[],EEG)
        catch
        end
        flag = input('Do you want to change this list? [Y/N]','s');
        if (strcmp('Y', flag) || strcmp('y',flag))
            temp = input('Please specify a new bad channel list (format [1 2 ]):');
            indelec = false(size(indelec,1),size(indelec,2));
            indelec(temp) =1;
        end
        if(~isempty(EEG.NBTinfo.BadChannels))
            EEG.NBTinfo.BadChannels(indelec) = 1;
        else
            EEG.NBTinfo.BadChannels = indelec;
        end
    else
        disp('No bad channels found.')
    end
else
    if(~isempty(EEG.NBTinfo.BadChannels))
        EEG.NBTinfo.BadChannels(indelec) = 1;
    else
        EEG.NBTinfo.BadChannels = indelec;
    end
end
end