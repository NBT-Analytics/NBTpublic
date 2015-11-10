% nbt_SaveClearObject - Saves the object to the analysis file and clear it.
%
% Usage:
%   nbt_SaveClearObject(ObjectName, SignalInfo, SaveDir);
%
% Inputs:
%   ObjectName     - The name of the object you want to save and clear
%   SignalInfo     - The SignalInfo
%   SaveDir        - The directory you want to save to
%

%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil (2011), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2011  Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group,
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
% ---------------------------------------------------------------------------------------

function nbt_SaveClearObject(ObjectName, SignalInfo, SaveDir, ReloadSwitch)
error(nargchk(3,4,nargin));
%first we get the object to save
eval([ObjectName '= evalin(''caller'', ObjectName );']);

%Then we save it
an_file = [SaveDir,'/',SignalInfo.file_name,'_analysis.mat'];
if(exist(an_file,'file') == 2)
  %  NBTanalysisFile = matfile(an_file,'Writable', true);
 %   eval(['NBTanalysisFile.' ObjectName '= ' ObjectName ';'])
 save(an_file, ObjectName, '-append');
    disp('NBT: Analysis File already exists. Appending to existing file!');
elseif(exist(an_file,'file') == 0)
    save(an_file, ObjectName)
end

%And then we clear it
eval(['evalin(''caller'',''clear ' ObjectName ''');']);

if(exist('ReloadSwitch','var'))
    nbt_loadsavefile(an_file);
end
end
