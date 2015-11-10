function [Info]= gather_info

% This script will gather the info belonging to an EEG recording, convert the corresponding EEG data from .raw file to .mat,
% and store the info and EEG data in a NBT file, and also the info in a seperate file that will stay at the EEG lab for
% bookkeeping. Run this script before or after each recording. This script will first look if a this subject has had
% an earlier recording within this project. If not, a new Info file is made, and all fields have to be filled in.
% If there is an earlier recording, a copy is made of the info file of the earlier recording, and only the fields
% that differ between this and the earlier recording have to be filled in.

% SET THE FOUR DIRECTORY NAMES IN FIRST CELL BEFORE YOU START!!!!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% assign save directories

RAW_dir='/home/humann/Desktop/rawfiles/';
Info_save_dir='/home/humann/Desktop/infofiles/';
NBT_save_dir='/home/humann/Desktop/NBTfiles/';
NBT_save_dir_students= uigetdir('/var/www/humneurophys','Please group folder');

%% ask for file name, which is the same as the .raw file that contains the EEG data, and will be the name of the NBT data
% file to which the data is converted.

disp('Enter file name for experiment in this format: ')
disp('<ProjectID>.S<SubjectID>.<DateOfRecording [yymmdd]>.<Condition>');
disp('for example: NBT.S0099.090212.EOR1')
file_name=input('','s');
file_name_format='<ProjectID>.S<SubjectID>.<DateOfRecording [yymmdd]>.<Condition>';


%% look in Info save directory, if info file from subject is present

index=strfind(file_name,'.');
short_name=file_name(1:index(2)-1);
directory=dir(Info_save_dir);
present=0;

for i=3:length(directory)
    if ~isempty(findstr(short_name,directory(i).name))
        present=1;
        disp('Info file from this subject in this project was found')
        found_file_name=directory(i).name;
    end
end

%% make new one if not present

if present==0
    disp('Info file from this subject in this project was not found')
    % information about experiment

    %     description_project=input('Enter hypothesis of project, protocol and explain (coding of) conditions ','s');
    description_project='subject was asked to fall asleep during 20 minutes. This file contains first or last five minutes (see file name) of recording';

    time_of_recording=input('Enter time of recording (in the format: hhmm, for example 1233) ');
    original_sample_frequency=500;
    %     original_sample_frequency=input('Enter sample frequency of original recording ');
    %     converted_sample_frequency=input('Enter sample frequency of conversion into matlab ');
    converted_sample_frequency=250;
    researcher_ID=input('Enter your ID ','s');

    % information about subject
    subject_gender=input('Enter gender of subject (m/f) ','s');
    subject_age=input('Enter age of subject ');
    subject_headsize=input('Enter headsize of subject ');
    subject_handedness=input('Enter handedness of subject (l/r) ','s');
    subject_medication=input('Enter medication of subject (if any) ','s');

    notes=input('Enter notes ','s');

    Info = Info_Object(file_name,file_name_format,description_project,time_of_recording, ...
        original_sample_frequency,converted_sample_frequency,researcher_ID, subject_gender,subject_age, ...
        subject_headsize, subject_handedness,subject_medication,notes);

    Info.Info.fell_asleep=input('Did the subject fall asleep? (1,2,3,4 or 5) ');
    Info.Info.thought_control=input('Did the subject have trouble remembering his/her thoughts? (1,2,3,4 or 5) ');
    Info.Info.ESS = input('Please enter ESS? ');
end

%% if present, copy existing one and add experiment specific info

if present==1
    load([Info_save_dir found_file_name])
    Info.file_name=file_name;
    Info.researcher_ID=input('Enter your ID ','s');
    Info.time_of_recording=input('Enter time of recording (in the format: hhmm, for example 1233)');
    Info.notes=input('Enter notes ','s');
    Info.Info.fell_asleep=input('Did the subject fall asleep? (1,2,3,4 or 5) ');
    Info.Info.thought_control=input('Did the subject have trouble remembering his/her thoughts? (1,2,3,4 or 5) '); 
end


%% convert corresponding .raw file and save NBT file


[RawSignal,RawSignalInfo]=Convert_one_EGIraw_file_ToNBT(RAW_dir,Info,file_name);

[RawSignal,RawSignalInfo] = ResampleNBTSignal(RawSignal,RawSignalInfo,250);

save([Info_save_dir,'/',file_name,'.mat'],'RawSignalInfo')
%save([NBT_save_dir,'/',file_name,'.mat'],'RawInfo','RawSignal')


%% cut out first and last five minutes of recording for students and save
% them

% assume 250 hz sample frequency, 5 minutes= 250*60*5 samples

five_minutes=250*60*5; %

temp=RawSignal;

RawSignal.Signal=RawSignal(1:five_minutes,:);
RawSignalInfo.Interface.EEG.pnts = size(RawSignal,1);
RawSignalInfo.file_name=[file_name,'_first_5_min'];
save([NBT_save_dir_students,'/',file_name,'_first_5_min.mat'],'RawSignalInfo','RawSignal')

RawSignal=temp;
nr =size(RawSignal,1);
RawSignal.Signal=RawSignal((nr-five_minutes):nr,:);
RawSignalInfo.Interface.EEG.pnts = size(RawSignal,1);
RawSignalInfo.file_name=[file_name,'_last_5_min'];
save([NBT_save_dir_students,'/',file_name,'_last_5_min.mat'],'RawSignalInfo','RawSignal')


end








