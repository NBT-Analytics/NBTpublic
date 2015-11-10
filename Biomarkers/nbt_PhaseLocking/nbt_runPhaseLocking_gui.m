% nbt_runPhaseLocking_gui(Signal, SignalInfo, SaveDir) - GUI support function for
% running PLV
%
% Usage:
% nbt_runPhaseLocking_gui(Signal, SignalInfo, SaveDir)
%
% Inputs:
%   Signal
%   SignalInfo
%   SaveDir
%
% Outputs:
%
% Example:    
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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

function nbt_runPhaseLocking_gui(Signal, SignalInfo, SaveDir)
SettingsPLV = evalin('base','SettingsPLV');
duration = floor(size(Signal,1)/SignalInfo.converted_sample_frequency);
display(['Signal duration: ' num2str(duration) ' sec' ])
if isempty(SettingsPLV)
Frange = input('Specify frequency range in Hz [lowF highF] (i.e. [8 13]): ');
Trange = input('Specify time interval in sec (i.e. [0 5] or all): ','s');
if strcmp(Trange,'all')
    Trange = [0 length(Signal)/SignalInfo.converted_sample_frequency];
else
    Trange = str2num(Trange);
end
filterorder = 2/Frange(1);
windowleng = [];
overlap = [];
indexPhase = [1 1];
SettingsPLV.Frange = Frange;
SettingsPLV.Trange = Trange;
SettingsPLV.windowleng = windowleng;
SettingsPLV.filterorder = filterorder;
SettingsPLV.overlap = overlap;
SettingsPLV.indexPhase = indexPhase ;
assignin('base','SettingsPLV',SettingsPLV);
else
Frange = SettingsPLV.Frange;
Trange = SettingsPLV.Trange;
windowleng = SettingsPLV.windowleng;
filterorder = SettingsPLV.filterorder;
overlap = SettingsPLV.overlap;
indexPhase = SettingsPLV.indexPhase;
end
name = genvarname (['PhaseLocking' num2str(Frange(1)) '_' num2str(Frange(2)) 'Hz' num2str(Trange(1)) '_' num2str(Trange(2)) 'sec']); 
% compute biomarker
eval([name '= nbt_doPhaseLocking(Signal,SignalInfo,Frange,Trange,filterorder,windowleng,overlap,indexPhase)']);
% save biomarker
nbt_SaveClearObject(name,SignalInfo,SaveDir);
eval(['evalin(''caller'',''clear ' name ''');']);
end