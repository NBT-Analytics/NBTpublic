function BiomarkerTemplate = nbt_analysis_template(Signal,SignalInfo)

% Template analysis function, to be used with nbt_NBTcompute to be applied to a folder containing NBT signals

% Inputs:
% nbt_Biomarker_template = biomarker object to be updated 
% Signal = NBT Signal matrix for which the biomarkers will be computed
% SignalInfo = NBT Info object
% This function computes the desired biomarkers and updates the NBT Biomarker object 
% with the biomarker values. 

%Output: biomarker object

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%   give information to the user
disp(['Computing marker values for ',SignalInfo.file_name])

%% remove artifact intervals
Signal = nbt_RemoveIntervals(Signal,SignalInfo);

%% Initialize the biomarker object
% Note: you first have to define a new bimarker object if it does not
% exist, see for example nbt_amplitude and nbt_Biomarker_template.
BiomarkerTemplate = nbt_Biomarker_template(size(Signal,2)); %Use an appropriate name for the object that refers to the biomarker

%%   Compute markervalues. Add here your algorithm to compute the biomarker
%%   values, for example:
BiomarkerTemplate.SignalVariance = var(Signal);
BiomarkerTemplate.SignalMean     = mean(Signal);
BiomarkerTemplate.SignalMedian   = median(Signal);

%% update biomarker objects (here we used the biomarker template):
BiomarkerTemplate = nbt_UpdateBiomarkerInfo(BiomarkerTemplate, SignalInfo);
end