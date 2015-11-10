% Copyright (C) 2009 Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

function AmplitudeCorrObject = nbt_doAmplitudeCorr(Signal, SignalInfo)

AmplitudeCorrObject = nbt_AmplitudeCorr(size(Signal,2));
Signal = nbt_RemoveIntervals(Signal,SignalInfo);

for i=1:size(Signal(:,:),2)
    [VecCorr, p]=corr(Signal(:,i),Signal(:,:),'type','spearman'); 
    AmplitudeCorrObject.MarkerValues(:,i) = VecCorr.';
    %single index attempts
    AmplitudeCorrObject.MaxCorr(i) = max(VecCorr(VecCorr ~= 1));
    AmplitudeCorrObject.MinCorr(i) = min(VecCorr);
    AmplitudeCorrObject.MedianCorr(i) = nanmedian(VecCorr);
    AmplitudeCorrObject.MeanCorr(i) = nanmean(VecCorr);
    % AmplitudeCorrObject.StdCorr(i) = std(VecCorr);
    AmplitudeCorrObject.StdCorr(i) = sqrt(nanvar(VecCorr));
    AmplitudeCorrObject.IQRCorr(i) = iqr(VecCorr);
    AmplitudeCorrObject.RangeCorr(i) = range(VecCorr);
end
    AmplitudeCorrObject = nbt_UpdateBiomarkerInfo(AmplitudeCorrObject, SignalInfo);    
end
