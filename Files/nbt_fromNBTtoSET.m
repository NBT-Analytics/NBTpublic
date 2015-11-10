% nbt_fromNBTtoSET - this function convert NBT files in .set files (mainly used when you want load files in FASTER GUI)
%
% Usage:
%  nbt_fromNBTtoSET(path,faster_indir,orig_ref_elect,ref_elect,EmgEog_elect
%  filelocs)
%
% Inputs:
%  path - folder where NBT files are
%  faster_indir - directory where you want to store .set files
%  orig_ref_elect - reference electrode
%  ref_elect - new reference electrode (type [] to keep original referencing)
%  EMGEOG_elect - eye electrodes
%  filelocs - channels location file
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


function nbt_fromNBTtoSET(path,faster_indir,orig_ref_elect,ref_elect,EmgEog_elect,filelocs)
% orig_ref_elect = [];
% ref_elect = 11;
% EMgEog_elect = [8 25 127 14 125 21 128 126];

d = dir(path);
k = 1;
for i = 1:length(d)
    if d(i).name(1) == '.' 
        startindex = k;
        k = k+1;
    end
end
if exist('startindex','var')
d = d(startindex+1:end);
end
if isempty(ref_elect)
    ref_elect = orig_ref_elect;
end
for i = 1:length(d)
    if isempty(findstr(d(i).name,'info'))
        name = d(i).name;
        [Signal,SignalInfo,SignalPath]=nbt_load_file([path name]);
        EEG=nbt_NBTtoEEG(Signal, SignalInfo,SignalPath); %create EEGlab structure
        EEG = pop_reref(EEG,ref_elect, 'exclude', EmgEog_elect,'keepref','on');
        EEG.ref = ref_elect; %update reference 
        EEG.FASTERInfo.orig_ref = orig_ref_elect; %save original reference 
        try
            EEG.chanlocs = readlocs(filelocs);
        catch
            disp('Channels Location is not updated')
        end
        msg_stp3 = sprintf('Data single electrode re-referenced successfully.');
        disp(msg_stp3);
        EEG.data = detrend(EEG.data')';
        msg_stp4 = sprintf('Data detrended successfully.');
        disp(msg_stp4);
        fstr_id = EEG.setname;
        fastsep_ix = strfind(fstr_id,'.');
        fstr_id(fastsep_ix) = '_';
        fstr_id(end+1) = '_';
        EEG.FASTERInfo.fid = fstr_id;
        msg_stp5 = sprintf('Faster file name changed to %s successfully.',fstr_id);
        disp(msg_stp5);
        save_fid = strcat([faster_indir,EEG.FASTERInfo.fid]);
        pop_saveset(EEG,save_fid);
        msg_stp6 = sprintf('File %s saved to EEGlab set successfully.',save_fid);
        disp(msg_stp6);
        clear cur_fid sep_ix path_filename
        clear Signal SignalInfo Path
        clear EEG
        clear fstr_id fastsep_ix
        clear save_fid
    end
end