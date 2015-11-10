function [Correlation]=nbt_doCorrelations(Signal,Info)
% Usage:nbt_doCorrelations(Signal,Info,Save_dir)
%
% computes correlations between the signals in the NBT Signal matrix
%
% Inputs:
%
% Signal = NBT Signal matrix
% Info = NBT Info object
%
% This function computes correlations and creates a NBT Biomarker object 
% where it stores the biomarker values.
% This NBT biomarker object is saved in a NBT Analysis file.

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

%%    assigning fields:

type='Pearson';% 'Pearson' (the default) to compute Pearson's linear
% correlation coefficient, 'Kendall' to compute Kendall's
% tau, or 'Spearman' to compute Spearman's rho.

disp(' ')
disp('Command window code:')
disp('nbt_doCorrelations(Signal,SignalInfo')
disp(' ')

disp(['Computing correlations for ',Info.file_name])

%% remove artifact intervals:

Signal = nbt_RemoveIntervals(Signal,Info);

%%   Compute correlations
[R,P]=corr(Signal,'type',type);
s=size(R,2);
R(1:s+1:s*s) = NaN;
P(1:s+1:s*s) = NaN;

%% Set analysis results of bad channels to NaNs: (Note, analysis results vectors
 % should have the same length as the number of channels in your data if you want to use the following code)

R(find(Info.BadChannels),:)=NaN;
R(:,find(Info.BadChannels))=NaN;
P(find(Info.BadChannels),:)=NaN;
P(:,find(Info.BadChannels))=NaN;

%%  store and save markers in biomarker objects 

Correlation = nbt_Correlations(R,P); 

%% update biomarker object 

Correlation = nbt_UpdateBiomarkerInfo(Correlation, Info);
end
