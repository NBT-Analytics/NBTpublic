% Copyright (C) 2009  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

classdef nbt_AmplitudeCorr < nbt_Biomarker
    properties
        MaxCorr
        MinCorr
        MedianCorr
        MeanCorr
        StdCorr
        IQRCorr
        RangeCorr
    end
    methods
        function BiomarkerObject = nbt_AmplitudeCorr(NumChannels)
            if nargin == 0
                NumChannels = 1;
            end
            BiomarkerObject.MarkerValues = nan(NumChannels,NumChannels);
            BiomarkerObject.MaxCorr = nan(NumChannels,1);
            BiomarkerObject.MinCorr = nan(NumChannels,1);
            BiomarkerObject.MedianCorr = nan(NumChannels,1);
            BiomarkerObject.MeanCorr = nan(NumChannels,1);
            BiomarkerObject.StdCorr = nan(NumChannels,1);
            BiomarkerObject.IQRCorr = nan(NumChannels,1);
            BiomarkerObject.RangeCorr = nan(NumChannels,1);
            
            BiomarkerObject.DateLastUpdate = datestr(now);
            BiomarkerObject.PrimaryBiomarker = 'MarkerValues';
            BiomarkerObject.Biomarkers ={'MarkerValues','MaxCorr', 'MinCorr','MedianCorr','MeanCorr','StdCorr','IQRCorr','RangeCorr'};
        end
        
        function Output=nbt_GetAmplitudeCorr(AmpCorrObject,SubjectRange, ChId1, ChId2)
            % Output=GetAmplitudeCorr(AmpCorrObject,SubjectRange, ChId1, ChId2)
            %
            % Extracts amplitude correlation values from the AmpCorrObject
            %
            % See also AmplitudeCorr, DoAmplitudeCorr
            Output =[];
            for i = SubjectRange
                temp = AmpCorrObject.MarkerValues{i,1};
                Output = [Output temp(ChId1,ChId2)];
            end
            
        end
    end
end

