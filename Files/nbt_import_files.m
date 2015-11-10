% filename = nbt_import_files(sourcedirectory, destinydirectory,
%  LoadHandle, LoadHandleSwitch)
%
% Function: will convert all the files into NBT format:
%   - one file containing the data in a matrix (columns are channels),
%   - one file containing the info about that data in an Info-object
%
% Usage:
%   nbt_import_files
%   or
%   filename = nbt_import_files;
%   or
%   nbt_import_files(sourcedirectory, destinydirectory, LoadHandle);
%
% Inputs:
%   sourcedirectory     - Path to the directory that contains the files to be
%   converted. Can be text files, mat files, egi raw files or EEGlab set files.
%
% Output (optional): name of the file following NBT convention
%
% Example:
%   nbt_import_files
%
% References:
%
% See also:
%   nbt_info, nbt_CreateInfoObject
%

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2009), see NBT website for current email address
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



function filename = nbt_import_files(sourcedirectory, destinydirectory, LoadHandle, LoadHandleSwitch)
%% check inputs
disp('updated')
error(nargchk(0,4,nargin))
%% assigning directory and other fields
persistent allfiles
persistent SegmentOption
allfiles = 1;
if(~exist('sourcedirectory','var') | isempty(sourcedirectory))
    sourcedirectory=(uigetdir([],'Select directory with files to be imported'));
    if sourcedirectory==0  % cancelled
        return
    end
end

if(~exist('destinydirectory','var')| isempty(destinydirectory))
    destinydirectory=(uigetdir(sourcedirectory,'Select directory to store NBT files'));
    if destinydirectory == 0 % cancelled
        return
    end
end


nbt_writeCommand(['nbt_import_files(',char(39),sourcedirectory,char(39),',',char(39),destinydirectory,char(39),')']);

delete([sourcedirectory '/.DS_Store']) %--- for Mac
directory=dir(sourcedirectory);
directory=directory(~[directory.isdir]);%--- remove directories
[d1,d2,extension]=fileparts(directory(1).name);

if strcmp(extension,'.fdt')
    extension = '.set';
end
%% Check for multiple file structures
ExtMulti = input('Does the source folder contain different types of files? (y/n) ','s');
if strcmpi(ExtMulti,'y')
    extension = input('Please specify target file extension (e.g., .raw) ', 's');
end

%% Get info, also for NBT file name
disp('File names in NBT should be: <ProjectID>.S<SubjectID>.<DateOfRecording [yymmdd]>.<Condition>, for example NBT.S0099.090212.EOR1')
NameConvention=input('Is the filename already according to the NBT convention? (y/n) ','s');
% NameConvention='y';

if strcmpi(NameConvention,'n')
    disp('Generating filenames  (note use nbt_Rename for automatic renaming:')
    ProjectID=input('Please write ProjectID: ','s');
end

if ~(strcmp(extension,'.raw') || strcmp(extension,'.set'))
    Fs=input('What is the sample frequency? ');
end

if (strcmp(extension, '.txt') || strcmp(extension, '.mat'))
    Columns=input('channels in rows (type r) or in columns (type c)? ','s');
end

if (strcmp(extension,'.raw') || strcmp(extension,'.mat') || strcmp(extension,'.dat') || strcmp(extension,'.set'))
    resample=input('Do you want to downsample the signals? (y/n) ','s');
    if strcmpi(resample,'y')
        resamplefreq=input('Resample at how many Hz? ');
    else
        resamplefreq=input('What is the sample frequency? ');
    end
else
    resamplefreq = Fs;
end

doReadLoc=input('Do you want to read a special channel location file (answer n to use standard channel location file) (y/n) ','s');
if strcmpi(doReadLoc,'y')
    ReadLocFilename = input('Channel location filename: ', 's');
end


if (~(strcmp(extension,'.txt') || strcmp(extension,'.dat')  || strcmp(extension,'.raw') || strcmp(extension,'.set') || strcmp(extension,'.mat')) && ~exist('LoadHandle','var'))
    LoadHandle = eval(input('Please specify a load handle for your signal (with @ in front!): ','s'));
    if(~strcmpi('y', input('Is this an EEGlab based load handle? Answer y for yes, n for no ','s')))
        LoadHandleSwitch = 1;
    end
end
%% test read in for text files

if strcmp(extension,'.txt')
    disp(['Test read in of ',directory(1).name])
    D=importdata([sourcedirectory,'/',directory(1).name]);
    try
        Signal = D.data;
    catch
        Signal = D;
    end
    %Signal=D;
    if strcmp(Columns,'r')
        Signal=Signal';
    end
    disp(['Number of channels = ',num2str(size(Signal,2)),' Number of samples = ',num2str(size(Signal,1))])
    OK=input('read in OK? (y/n) ','s');
end


%% read in
for i=1:length(directory)
    [d1,d2, curExt]=fileparts(directory(i).name);
    if ~strcmp(curExt,'.fdt')
        if strcmp(curExt, extension)
            if strcmp(NameConvention,'n')
                stopWhile = 0;
                while (stopWhile==0)
                    disp(['File: ',directory(i).name])
                    stopWhile2 = 0;
                    while (stopWhile2 == 0)
                        SubjectID=input('Subject ID? ','s');
                        if(isnan(str2double(SubjectID)))
                            disp('The SubjectID should be a number')
                        else
                            stopWhile2 = 1;
                        end
                    end
                    Date=input('Date of recording? yyyymmdd ','s');
                    Condition=input('Condition? ','s');
                    Notes=input('Notes? ','s');
                    if(~isempty(Condition)&& ~isempty(Date) && ~isempty(SubjectID))
                        stopWhile = 1;
                    else
                        disp('Empty input parameters are not allowed. Please enter again')
                    end
                end
            else
                FileNameIndex = strfind(directory(i).name,'.');
                ProjectID = directory(i).name(1:(FileNameIndex(1)-1));
                SubjectID = directory(i).name((FileNameIndex(1)+1):(FileNameIndex(2)-1));
                Date  = directory(i).name((FileNameIndex(2)+1):(FileNameIndex(3)-1));
                Condition = directory(i).name((FileNameIndex(3)+1):(FileNameIndex(4)-1));
                Notes=[];
            end
            if strcmpi(SubjectID(1),'S')
                filename=[ProjectID,'.',SubjectID,'.',num2str(Date),'.',Condition];
            else
                filename=[ProjectID,'.S',SubjectID,'.',num2str(Date),'.',Condition];
            end
            if(~exist('LoadHandle', 'var'))
                switch extension
                    case '.txt' % text files
                        disp(['Converting ',directory(i).name])
                        disp('')
                        if strcmp(OK,'y')
                            D=importdata([sourcedirectory,'/',directory(i).name]);
                        else
                            D=uiimport([sourcedirectory,'/',directory(i).name]);
                        end
                        try
                            Signal = D.data;
                        catch
                            Signal = D;
                        end
                        if strcmp(Columns,'r')
                            Signal = double(Signal');
                        end
                        nr_ch=size(Signal,2);
                        if(strcmpi(doReadLoc,'y'))
                            EEG = eeg_emptyset;
                            EEG.chanlocs = readlocs(ReadLocFilename);
                        end
                    case '.mat' % MAT files
                        disp(['Converting ',directory(i).name])
                        disp('')
                        if(exist('LoadHandle','var'))
                            EEG = LoadHandle([sourcedirectory,'/',directory(i).name]);
                            EEG = eeg_checkset(EEG);
                            Fs = EEG.srate;
                            
                            if(size(EEG.data,3) > 1) % to correct for epoched data
                                EEG.event = rmfield(EEG.event,'epoch');
                                Signal = double(EEG.data(:,:,1)');
                                for ee = 2:size(EEG.data,3)
                                    Signal = [Signal; double(EEG.data(:,:,ee)')];
                                end
                            else
                                Signal = double(EEG.data)';
                            end
                        else
                            D=load([sourcedirectory,'/',directory(i).name]);
                            fields=fieldnames(D);
                            Signal=eval(['D.',fields{1}]);
                            if strcmp(Columns,'r')
                                Signal=double(Signal');
                            end
                            nr_ch=size(Signal,2);
                            EEG = eeg_emptyset;
                            if(strcmpi(doReadLoc,'y'))
                                EEG.chanlocs = readlocs(ReadLocFilename);
                            end
                            EEG.nbchan = nr_ch;
                            if strcmp(resample,'y')
                                EEG.data = Signal';
                                EEG.srate = Fs;
                                EEG = eeg_checkset(EEG);
                                EEG=pop_resample(EEG,resamplefreq);
                                Signal = EEG.data';
                                EEG.data = [];
                            end
                        end
                    case '.raw' % RAW files
                        if allfiles == 1
                            SegmentOption=input('Do you want import a segment (1) or all the signal (0)? ');
                        end
                        disp(['Converting ',directory(i).name])
                        disp('')
                        %--- allows to select proper chan loc
                        fid = fopen([sourcedirectory,'/',directory(i).name], 'rb', 'b');
                        if fid == -1, error('Cannot open file'); end
                        head = readegihdr(fid); % read EGI file header
                        nr_ch = head.nchan;
                        fileloc =  ['GSN-HydroCel-' num2str(nr_ch) '.sfp'];
                        %---
                        if SegmentOption == 1
                            EEG = pop_readegi([sourcedirectory,'/',directory(i).name],[1:10]);
                            ReadSegment = input('Specify the segment interval as [Start:End] (in seconds): ');
                            if(~isempty(ReadSegment))
                                ReadSegment = [(ReadSegment(1)*EEG.srate+1):(ReadSegment(end)*EEG.srate+1)];
                                disp('Reading file.... Please Wait')
                                EEG = pop_readegi([sourcedirectory,'/',directory(i).name], ReadSegment,[],fileloc);
                                
                            else
                                EEG = pop_readegi([sourcedirectory,'/',directory(i).name],[],[],fileloc);
                            end
                        else
                            EEG = pop_readegi([sourcedirectory,'/',directory(i).name],[],[],fileloc);
                            allfiles = 0;
                            SegmentOption = 0;
                        end
                        Fs=EEG.srate;
                        
                        if strcmp(resample,'y')
                            EEG=pop_resample(EEG,resamplefreq);
                        end
                        if (nr_ch-EEG.nbchan) ~= 0
                            EEG.data(nr_ch,:) = zeros(1,size(EEG.data,2)); %added due to eeglab bug!
                        end
                        EEG.nbchan = nr_ch;
                        if(strcmpi(doReadLoc,'y'))
                            EEG.chanlocs = readlocs(ReadLocFilename);
                        end
                        %             chanlocs should be already assigned by eeglab
                        EEG.setname = filename;
                        EEG = eeg_checkset(EEG);
                        Signal= double(EEG.data');
                        EEG.data = [];
                        EEG.ref = nr_ch;
                    case '.set' % .set files
                        disp(['Converting ',directory(i).name])
                        disp('')
                        EEG=pop_loadset('filepath',[sourcedirectory,'/',directory(i).name]);
                        EEG.setname = filename;
                        EEG = eeg_checkset(EEG);
                        try
                            Signal=double(EEG.data');
                        catch
                            EEG = eeg_epoch2continuous(EEG);
                            Signal = double(EEG.data');
                        end
                        EEG=rmfield(EEG,'data');
                        Fs=EEG.srate;
                    case '.dat' %BCI2000 .dat files
                        disp('Importing BCI2000 .dat files')
                        disp(['Converting ',directory(i).name])
                        disp('')
                        EEG = nbt_BCI2000import([sourcedirectory,'/',directory(i).name]);
                        EEG.setname = filename;
                        EEG = eeg_checkset(EEG);
                        Signal=EEG.data';
                        EEG=rmfield(EEG,'data');
                        Fs=EEG.srate;
                        nr_ch = EEG.nbchan;
                        fileloc =  ['GSN-HydroCel-' num2str(nr_ch) '.sfp'];
                     
                        if(strcmpi(doReadLoc,'y'))
                            EEG.chanlocs = readlocs(ReadLocFilename);
                        else
                            EEG.chanlocs = readlocs(fileloc);
                        end
                        EEG.ref = EEG.nbchan;
                        
                        if strcmp(resample,'y')
                            EEG.data = Signal';
                            EEG.srate = Fs;
                            EEG = eeg_checkset(EEG);
                            EEG=pop_resample(EEG,resamplefreq);
                            Signal = single(EEG.data');
                            EEG.data = [];
                        end
                    otherwise
                        error('ERROR: No load function for the given extension. You need to provide a function handle')
                end
            else % a LoadHandle has been defined.
                %for backward comp. we assume an EEGlab loadhandle
                if(~exist('LoadHandleSwitch','var'))
                    EEG = LoadHandle([sourcedirectory,'/',directory(i).name]);
                    EEG = eeg_checkset(EEG);
                    Fs = EEG.srate;
                    
                    if(size(EEG.data,3) > 1) % to correct for epoched data
                        EEG.event = rmfield(EEG.event,'epoch');
                        Signal = double(EEG.data(:,:,1)');
                        for ee = 2:size(EEG.data,3)
                            Signal = [Signal; double(EEG.data(:,:,ee)')];
                        end
                    else
                        Signal = double(EEG.data)';
                    end
                else
                    if(LoadHandleSwitch)
                        %Using an NBT loadhandle
                        [Signal, SignalInfo] = LoadHandle(filename, [sourcedirectory,'/',directory(i).name]);
                        if(strcmpi(doReadLoc,'y'))
                            EEG = eeg_emptyset;
                            EEG.chanlocs = readlocs(ReadLocFilename);
                        end
                    else
                        error('Unknown LoadHandleSwitch')
                    end
                end
            end
            
            
            
            %% make Info object
            if(~exist('SignalInfo', 'var'))
                SignalInfo = nbt_CreateInfoObject(filename, [], Fs);
            end
            
            if(exist('resample','var'))
                if strcmpi(resample,'y')
                    SignalInfo.original_sample_frequency = Fs;
                    SignalInfo.converted_sample_frequency = resamplefreq;
                end
            end
            
            if (exist('EEG','var'))
                EEG.data = [];
                SignalInfo.Interface.EEG = EEG;
            end
            
            if strcmp(NameConvention,'n')
                SignalInfo.Interface.original_file_name=directory(i).name;
            end
            
            SignalInfo.Interface.number_of_channels=size(Signal,2);
            
            %% save NBT Signal and info
            
            RawSignal = Signal;
            RawSignalInfo = SignalInfo;
            clear Signal
            clear SignalInfo
            save([destinydirectory,'/',filename,'.mat'],'RawSignal')
            save([destinydirectory,'/',filename,'_info','.mat'],'RawSignalInfo')
            clear RawSignal
            clear RawSignalInfo
        end
    end
end
end


