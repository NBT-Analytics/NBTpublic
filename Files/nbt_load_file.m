% [Signal,SignalInfo,path] = nbt_load_file(varargin)
%
% Load Files
%
% Usage:
%   [Signal,SignalInfo,path] = nbt_load_file;
%   or 
%   [Signal,SignalInfo,path] = nbt_load_file([path\filename]);
%
% Inputs:
%    
% Outputs:
%   Signal
%   SignalInfo
%   path
%
% Example:
%   [Signal,SignalInfo,path] = nbt_load_file;
%
% References:
% 
% See also: 
%  nbt_import_files
  
%------------------------------------------------------------------------------------
% Originally created by Simon-Shlomo Poil, Rick Jansen (2010), see NBT website for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2010 Simon-Shlomo Poil, and Rick Jansen  (Neuronal Oscillations and Cognition group, 
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

function[Signal,SignalInfo,path]=nbt_load_file(varargin)

%% if file name not specified, select file from pop up window
if isempty(varargin)
    % if file name not specified, select file from pop up window
    [file,path]=uigetfile('','Select NBT file to load');
else
    path_filename=varargin{1};
    
    stringindex = findstr(path_filename,filesep);
    if(~isempty(stringindex))
        path = path_filename(1:stringindex(end)); % path
        file = path_filename(stringindex(end)+1:end);  % file name
    else
        path = [pwd filesep];
        file = path_filename;
    end
end

if file ==0  % if cancel is selected in uipopup
    Signal=[];
    SignalInfo=[];
    path=[];
    return
end

disp(' ')
disp('Command window code:')
disp(['load(',char(39),path,file,char(39),')'])
disp(['load(',char(39),path,file(1:end-4),'_info.mat',char(39),')'])
disp(' ')

%% load NBT signal
disp('NBT signal is loading...')
warning off
Loaded=load([path file]);
delete([path '.DS_Store']) % for Mac
warning on

%% load NBT info 
try
    LoadedInfo=load([path file(1:end-4),'_info.mat']);
catch
    warning('NBTInfoFile', 'nbt_load_file: No Info file found.')
    fprintf('No Info file found. \n')
    fprintf('Conversion to NBT Data Format... \n')
    filename = nbt_import_files(path,path);
    directory=dir(path);
    directory=directory(~[directory.isdir]);% remove directories
    [d1,d2,extension]=fileparts(directory(1).name);
    
    for i = 1:size(directory,1);
        [d1,d2,extension]=fileparts(directory(i).name);
        if ~isempty(findstr([filename '_info'], d2))
            file = [d2 '.mat' ];
        end
    end
    Loaded=load([path filename '.mat']);
    LoadedInfo=load([path filename,'_info.mat']);
end
    
%% check if there are more signals (i.e. rawsignal, clean signal...)
fi=fields(LoadedInfo);
if length(fields(LoadedInfo))>1
    [index] =listdlg('Liststring',fi,'promptstring','Which of the following Signals do you want to load?');
    name=fi{index};
    try
    Signal=eval(['Loaded.',name(1:(end-4))]);
    catch
        fi2=fields(Loaded);
        [index] =listdlg('Liststring',fi2,'promptstring','Specify your core Signal?');
        Signal=eval(['Loaded.',fi2{index}]);
    end
    SignalInfo=eval(['LoadedInfo.',name]);
    disp('NBT Signal and Info Object loaded')
else
    fi = fields(Loaded);
    Signal=eval(['Loaded.',fi{1}]);
    try
    SignalInfo=eval(['LoadedInfo.',fi{1},'Info']);
    catch
        SignalInfo = LoadedInfo.SignalInfo;
    end
    disp('NBT Signal and Info Object loaded')
end

%% make into double

Signal = double(Signal(:,:));
