% nbt_fromSETtoNBT(path,path2,opt) - this function convert .set files generated
% by faster to NBT files 
%
% Usage:
%  nbt_fromSETtoNBT(path,path2,opt)
%
% Inputs:
%  path - folder where faster .set files are 
%  path2 - directory where you want to store the clean files in NBT format
%
% Example:
%   
%
% References:
% 
% See also: 
% 
  
%------------------------------------------------------------------------------------
% Originally created by Alexander Diaz, later modified by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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
% --------------

function nbt_fromSETtoNBT(path,path2,opt)
d = dir(path);
k = 1;
for i = 1:length(d)
    if d(i).name(1) == '.'  
        startindex = k;
        k = k+1;
    end
end
d = d(startindex+1:end);

for i = 1:length(d)
if ~isempty(findstr(d(i).name,'set'))
    
    name = d(i).name;
    disp('Read interpolated channels and removed epochs from FASTER .log file ...')
    [intchans,remepochs] = nbt_badchans_remep_faster_logs(path,[name(1:end-4) '.log']);
    EEG = pop_loadset([path '/' name]); %retrieve subject specific set file
    FASTERInfo.trials = EEG.trials;
    FASTERInfo.pnts = EEG.pnts;
    FASTERInfo.xmax = EEG.xmax;
    FASTERInfo.times = EEG.times;
    FASTERInfo.event = EEG.event;
    FASTERInfo.urvent = EEG.urevent;
    FASTERInfo.eventdescription = EEG.eventdescription;
    FASTERInfo.epoch = EEG.epoch;
    FASTERInfo.remepochs = remepochs;
    FASTERInfo.intchans = intchans;
    EEG.FASTERInfo = FASTERInfo;
    if isempty(opt)
        [yesnan] = lower(input('Do you want to put interpolated channels to nan? [y/n] ','s'));
    else
        yesnan = opt;
    end
    
    EEG.epoch = [];
    EEG.eventdescription = {};
    EEG.urevent = [];
    EEG.event = [];
    %EEG.icaact = reshape(EEG.icaact,size(EEG.icaact,1),EEG.pnts*EEG.trials);
    EEG.icaact = [];
    EEG.data = reshape(EEG.data,size(EEG.data,1),EEG.pnts*EEG.trials);
    EEG.xmax = EEG.pnts./EEG.srate;
    EEG.pnts = EEG.trials .* EEG.srate;
    EEG.trials = 1;
    EEG.FASTERInfo.remepochs = remepochs;
    EEG.FASTERInfo.intchans = intchans;
    newname = regexprep(name(1:end),'_','.');
    newname = newname(1:end-4);
    if strcmp(newname(end),'.')
        newname = newname(1:end-1);
    end
    FSTR_CleanSignal = EEG.data'; % Signal object
    FSTR_CleanSignalInfo=EEG.NBTinfo; %Signal Info
    if yesnan == 'y'
        Badchans = zeros(1,size(EEG.data,1));
        Badchans(intchans) = 1;
        FSTR_CleanSignalInfo.BadChannels = Badchans;
    end
    %--- set to empty EEG field
    EEG.data=[];
    EEG.history = [];
    EEG.icaact = [];
    %---
    FSTR_CleanSignalInfo.converted_sample_frequency = EEG.srate;
    
    FSTR_CleanSignalInfo.notes= EEG.FASTERInfo; %Not working: class
    EEG = rmfield(EEG,'FASTERInfo');
    EEG = rmfield(EEG,'NBTinfo');
    FSTR_CleanSignalInfo.Interface.EEG=EEG;
    
    sig_name = 'FSTR_CleanSignal';
    disp('Convert and save to NBT file format ...')
    save([path2, '/',newname,'.mat'],sig_name);
    save([path2, '/',newname,'_info','.mat'],[sig_name 'Info']);
end

end
