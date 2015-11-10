% nbt_Biomarker(NumChannels) - Creates a biomarker object - this is the
% basic NBT biomarker object
%
% Usage:
%   >>  Biomarker = nbt_Biomarker(NumChannels);
%
% Inputs:
%   NumChannels -  Number of Channels
%
% Outputs:
%   Biomarker     - Biomarker object
%
% Example:
%
% References:
%
%
% See also:
%

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2009), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2009 Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group, 
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
% -


classdef nbt_Biomarker
    properties
        MarkerValues % the biomarker values
        NumChannels % number of channels
        Fs % The sampling frequency
        DateLastUpdate %last date this biomarker was updated
        PrimaryBiomarker % the primary biomarker to use in scripts
        Biomarkers % list of all biomarkers in the object
        BiomarkerUnits %list of biomarker units
        ReseacherID % ID of the Reseacher or script that made the last update
        ProjectID % The ID of the project which the biomarker belongs to
        SubjectID % The ID of the subject
        FrequencyRange %Frequency range of processed signal [] means broadband.
        Condition % The condition ID
        SignalName % Name of the signal used to compute the biomaker
        NBTDID %NBTDID of the signal used to compute the biomakrer
        NBTversion
    end
    methods
        function BiomarkerObject = nbt_Biomarker()
            BiomarkerObject.Condition = NaN;
            BiomarkerObject.DateLastUpdate =  datestr(now);
            BiomarkerObject.ReseacherID = NaN;
            BiomarkerObject.SubjectID = NaN;
            BiomarkerObject.ProjectID = NaN;
            BiomarkerObject.FrequencyRange = [];
            BiomarkerObject.Biomarkers = {'MarkerValues'};
            BiomarkerObject.NBTversion = nbt_GetVersion;
        end
        
        function biomarkerObject=nbt_UpdateBiomarkerInfo(biomarkerObject, SignalInfo)
            biomarkerObject.DateLastUpdate = datestr(now);
            [~, biomarkerObject.NBTversion] = nbt_GetVersion;
            biomarkerObject.NBTDID = SignalInfo.NBTDID;
            biomarkerObject.SignalName =  SignalInfo.SignalName;
            biomarkerObject.FrequencyRange = SignalInfo.frequencyRange;
            biomarkerObject.SubjectID = SignalInfo.subjectID;
            biomarkerObject.Condition = SignalInfo.condition;
            biomarkerObject.ProjectID = SignalInfo.projectID;
            biomarkerObject.Fs = SignalInfo.converted_sample_frequency;
            %set Badchannels to NaN
            if(~isa(biomarkerObject,'nbt_ARSQ'))
            if(~isempty(SignalInfo.BadChannels))
                for i=1:length(biomarkerObject.Biomarkers)
                    eval(['biomarker=biomarkerObject.' biomarkerObject.Biomarkers{1,i} ';']);
                    if(iscell(biomarker))
                        for m=1:length(biomarker)
                            if(~iscell(biomarker{m,1}))
                            biomarker{m,1}(find(SignalInfo.BadChannels)) = NaN;
                            else
                                for mm=1:length(biomarker{m,1})
                                    biomarker{m,1}{mm,1}(find(SignalInfo.BadChannels)) = NaN;
                                end
                            end
                        end
                    else
                        biomarker(find(SignalInfo.BadChannels)) = NaN;
                    end
                   eval(['biomarkerObject.' biomarkerObject.Biomarkers{1,i} '=biomarker;']);
               end
            end
            end
        end
    end 
end
