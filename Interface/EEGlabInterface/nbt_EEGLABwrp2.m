%[Signal, SignalInfo] = nbt_EEGLABwrp(funchandle, Signal, SignalInfo,
%SignalPath, UpdateFromBase, varargin)

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and 
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------

function [Signal, SignalInfo] = nbt_EEGLABwrp2(funchandle, Signal, SignalInfo, SignalPath, UpdateFromBase, varargin)
evalin('base', 'clear EEG');
evalin('base', 'clear ALLEEG');
evalin('base', 'clear CURRENTSET');
global EEG
EEG = nbt_NBTtoEEG(Signal, SignalInfo, SignalPath); %some issues with noisy intervals
ALLEEG(1) = EEG;
assignin('base', 'EEG',EEG);
assignin('base', 'ALLEEG',ALLEEG);
assignin('base', 'CURRENTSET', 1);
if(~isempty(varargin))
    %ok let's build input parameters string
    funcstring = ['EEG = funchandle(EEG'];
    for i=1:length(varargin)
        if isempty(varargin{i})
            funcstring = [funcstring ', []'];
        elseif (isnumeric(varargin{i}))
            funcstring = [funcstring ','  num2str(varargin{i})];
        elseif(isstr(varargin{i}))
            funcstring = [funcstring ', ''' varargin{i} ''' '];
        else
            funcstring = [funcstring ', []'];
        end
    end
    funcstring = [funcstring ');'];
    eval(funcstring)
else
    EEG = funchandle(EEG);
end

if(UpdateFromBase)
   % close(findobj('Tag','NBT'))
    h = warndlg('Click OK to return to NBT','NBT external call to EEGLAB');
    uiwait(h)
   % close all 
   % nbt_gui
    EEG = evalin('base', 'EEG');
end
evalin('base', 'clear EEG');
evalin('base', 'clear ALLEEG');
evalin('base', 'clear CURRENTSET');

warning off
try
[Signal, SignalInfo]=nbt_EEGtoNBT(EEG, [], []);
catch
end
warning on
end