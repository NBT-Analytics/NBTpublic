% Phase lag index
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

function PLIobject = nbt_doPLI(Signal,SignalInfo)
%%   give information to the user
disp(['Computing marker values for ',SignalInfo.file_name])

%% remove artifact intervals
Signal = nbt_RemoveIntervals(Signal,SignalInfo);

%% Initialize the biomarker object
numChannels = size(Signal,2);
PLIobject = nbt_PLI(numChannels);

phaseSignal = angle(hilbert(Signal));

for i = 1:(numChannels-1)
    for m = (i+1):numChannels
        PLIobject.pliVal(i,m) = abs(mean(sign(phaseSignal(:,i)-phaseSignal(:,m))));
    end
end

pli = PLIobject.pliVal;
pli = triu(pli);
pli = pli+pli';
pli(eye(size(pli))~=0)=1;
PLIobject.pliVal = pli;

for i=1:numChannels
    pli_chan = pli(i,:);
    PLIobject.Median(i) = nanmedian(pli_chan(pli_chan ~= 1));
    PLIobject.Mean(i) = nanmean(pli_chan(pli_chan ~= 1));
    PLIobject.IQR(i) = iqr(pli_chan(pli_chan ~= 1));
    PLIobject.Std(i) = std(pli_chan(pli_chan ~= 1));
end

%% update biomarker objects (here we used the biomarker template):
PLIobject = nbt_UpdateBiomarkerInfo(PLIobject, SignalInfo);
end
