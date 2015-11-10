% nbt_OscBursts - Creates a Oscillation Bursts object for 'NumSubjects' number of
    % subjects, and 'NumChannels' numbers of channels
%
% Usage:
%   OscBobject = nbt_OscBursts(NumChannels)
%
% Inputs:
%   NumChannels
%
% Outputs:
%     
%
% Example:
%   
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2008), see NBT website (http://www.nbtwiki.net) for current email address
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

classdef nbt_OscBursts < nbt_Biomarker
    %% OscBobject class constructor
    % nbt_OscBursts(NumSubjects, NumChannels) - Creates a Oscillation Bursts object for 'NumSubjects' number of
    % subjects, and 'NumChannels' numbers of channels
    %% Copyright (c) 2008, Simon-Shlomo Poil (Center for Neurogenomics and Cognitive Research (CNCR), VU University Amsterdam)
    %% ChangeLog - remember to set NBTversion property
    %$ Version 1.0 - 22 June 2009 : Modified by Simon-Shlomo Poil, simonshlomo.poil@cncr.vu.nl$
    % Implementing new matlab object structure.
    
    properties
        lifetimes
        sizes
        waitingtimes
        AvalancheShape
        CumulativeLifetime
        CumulativeSize
        IntraBurstsCorr
        ShapeMarker
        Pxx
        threshold
        WindowSwitch
        WindowSize
    end
    methods
        function OscBobject = nbt_OscBursts(NumChannels)
            if nargin == 0
                NumChannels = 1;
            end
            
            %% Define vector containers for life-time and waiting-times
            OscBobject.lifetimes = cell(NumChannels,1);
            OscBobject.waitingtimes = cell(NumChannels,1);
            OscBobject.sizes = cell(NumChannels,1);
            OscBobject.AvalancheShape = cell(NumChannels,1);
            OscBobject.CumulativeLifetime = nan(NumChannels, 1);
            OscBobject.CumulativeSize = nan(NumChannels, 1);
            OscBobject.ShapeMarker = nan(NumChannels, 1);
            OscBobject.IntraBurstsCorr = nan(NumChannels, 1);
            
            %% Define fields for additional information
            OscBobject.threshold = 0.5;
            OscBobject.Pxx = 0.95;
            OscBobject.WindowSwitch = 0;
            OscBobject.WindowSize = NaN;
            OscBobject.Fs = NaN;
            OscBobject.PrimaryBiomarker = 'CumulativeLifetime';
            OscBobject.Biomarkers = {'CumulativeLifetime', 'ShapeMarker', 'CumulativeSize', 'IntraBurstsCorr'};
        end
    end
end