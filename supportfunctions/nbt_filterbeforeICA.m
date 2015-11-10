% EEG = nbt_filterbeforeICA(EEG, filterfunction,offset)
%
% This function applies a 0.5 Hz high-pass filter before ICA
%
% Usage:
%   EEG = nbt_filterbeforeICA(EEG, filterfunction,offset)
%
% Inputs:
%   EEG
%   filterfunction
%   offset
%    
% Outputs:
%   EEG
%
% Example:
%   EEG = nbt_filterbeforeICA(EEG, filterfunction,offset)
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by "" (year), see NBT website for current email address
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
% ---------------------------------------------------------------------------------------


function EEG=nbt_filterbeforeICA(EEG, filterfunction,offset,varargin)


if(isfield(EEG,'NBTEEGtmp'))
    if(~isempty(EEG.NBTEEGtmp))
        EEG.data = EEG.NBTEEGtmp;
        EEG.pnts = size(EEG.data,2);
        hh = findobj('Tag','NBTICAreject');
        set(hh,'Enable','off');
        hh = findobj('Tag','NBTICAfilter');
        set(hh,'Enable','on');
    end
end

if isempty (varargin)
    nrpca = inputdlg('Number of components? (write 0 for automatic)' );
    nrpca = str2double(nrpca{1});
else
    nrpca = varargin{1};
end


EEGtmp = EEG;

if(~isempty(filterfunction))
    disp(filterfunction)
    eval(filterfunction)
    EEG.data = EEG.data';
    EEG.data = EEG.data(:,(offset*EEG.srate):end);
    EEG.pnts = size(EEG.data,2);
end
EEG.icaweights = [];
EEG.icasphere = [];
EEG.icahansind = [];
EEG.icawinv = [];
EEGtmp.icaweights = [];
EEGtmp.icasphere = [];
EEGtmp.icahansind = [];
EEGtmp.icawinv = [];

switch nrpca
    case 0
        disp('Calculating number of components')
        EEG = nbt_pop_runicaBadChannels(EEG,'pca',nbt_FindNrofCompForICA(EEG),'extended',1);
    case -1 
        EEG = nbt_pop_runicaBadChannels(EEG,'extended',1);
    otherwise
        EEG = nbt_pop_runicaBadChannels(EEG,'pca',nrpca,'extended',1);
end
EEGtmp.icaweights = EEG.icaweights;
EEGtmp.icasphere = EEG.icasphere;
EEGtmp.icachansind = EEG.icachansind;
EEG = EEGtmp;
end