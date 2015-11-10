% This function generates a grand average power spectrum based on the
% PeakFit object. 

% Copyright (C) 2014  Simon-Shlomo Poil
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
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function nbt_plotGrandAveragePSD(FileList, channelId,colorIndex)


load(FileList(1).name)
PeakFitName=nbt_ExtractObject('nbt_PeakFit');
PeakFitName = PeakFitName{1}; %we assume only one PeakFit object in the analysis files.
eval(['GrandPSD = nan(size(' PeakFitName '.p{1,1},1),length(FileList));'])
eval(['Frequency = ' PeakFitName '.f;'])
for i=1:length(FileList)
    disp(['Loading: ' FileList(i).name] )
    load(FileList(i).name, PeakFitName) 
    eval(['GrandPSD(:,i) =' PeakFitName '.p{channelId,1};'])
    eval(['clear ' PeakFitName] )
end

MeanPSD = mean(GrandPSD,2);
SEM    = std(GrandPSD,1,2)/length(FileList);
hold on

plot(Frequency,MeanPSD,colorIndex)
plot(Frequency,MeanPSD+SEM,[colorIndex ':'])
plot(Frequency,MeanPSD-SEM,[colorIndex ':'])
end