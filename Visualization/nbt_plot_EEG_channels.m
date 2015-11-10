
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (C) 2008  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%  Usage:
%   nbt_plot_EEG_channels(channels,cmin,cmax,chanlocs)

% Inputs:
%   channels: vector of length 129
%  cmin: color axis minimum
%  cmax: color axis maximum
%  chanlocs:  EEG data chanlocs structure

% Example:
%
% nbt_plot_EEG_channels(1:129,[],[],SignalInfo.Interface.EEG.chanlocs)

%  Function: will plot vector channels color coded at locations defined by
%  chanlocs and by function nbt_loadintxinty
%%


function[] = nbt_plot_EEG_channels(varargin)

channels=varargin{1};
chanlocs = varargin{4};

%% get color scale
if ~isempty(varargin{2})
    cmin=varargin{2};
    cmax=varargin{3};
else
    m=max(abs(min(channels)),abs(max(channels)));
    cmin=-m;
    cmax=m;
end
color=jet(1001);
step=(cmax-cmin)/1000;
for i=1:length(channels)
    temp(i)= round((channels(i)-cmin)/step)+1;
end
temp(temp>1000)=1000;
temp(temp<1) = 1;

%% load locations
[intx,inty]=nbt_loadintxinty(chanlocs);

%% plot
for i=1:length(channels)
    try
        hh(i)=uicontextmenu;
        plot(inty(i),intx(i),'.','color',color(temp(i),:),'markersize',15,'displayname',['Channel ',num2str(i)],'uicontextmenu',hh(i));
        uimenu(hh(i), 'Label', ['Channel ',num2str(i)]);    
        hold on
    catch
    end
end

caxis([cmin cmax])
axis off
hold off

end
