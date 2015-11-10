% Copyright (C) 2010  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

function EEG=nbt_rejectICAcomp(EEG,filterfunction, offset, state)
if(state==1)
    EEG.NBTEEGtmp = EEG.data;
    hh = findobj('Tag','NBTICAfilter');
    set(hh,'Enable','off');
    hh = findobj('Tag','NBTICAreject');
    set(hh,'Enable','on');
    disp(filterfunction)
    eval(filterfunction)
    EEG.data = EEG.data';
    EEG.data = EEG.data(:,(offset*EEG.srate):end);
    EEG.pnts = size(EEG.data,2);
    EEG.icaact = [];
    EEG.icawinv = [];
    hh = findobj('Tag','NBTICAreject');
    set(hh,'Enable','on');
    disp('Done')
elseif(state ==2)
    EEG.data = EEG.NBTEEGtmp;
    EEG = rmfield(EEG,'NBTEEGtmp');
    EEG.pnts = size(EEG.data,2);
    EEG.icaact = [];
    EEG.icawinv = [];
    EEG = eeg_checkset(EEG);
    EEG = pop_subcomp( EEG );
    hh = findobj('Tag','NBTICAreject');
    set(hh,'Enable','off');
    hh = findobj('Tag','NBTICAfilter');
    set(hh,'Enable','on');    
    disp('Done')
end
end