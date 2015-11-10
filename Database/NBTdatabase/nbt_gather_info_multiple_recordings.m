function[Info]= gather_info

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

RAW_dir='B:\NBT Data\test\raw files\';
Info_save_dir='B:\NBT Data\test\info files\';
NBT_save_dir='B:\NBT Data\test\NBT files\';

% RAW_dir='/media/Data/NBTdatabase/Data/oando/raw files/';
% Info_save_dir='/media/Data/NBTdatabase/Data/oando/info files/';
% NBT_save_dir='/media/Data/NBTdatabase/Data/oando/NBT files/';

go=1;
d=dir(RAW_dir);
index=3:length(d);
while ~isempty(index)
%% per subject, load and convert all recordings

    temp=d(index(1)).name(1:end-4); %take first file
     file_name=d(index(1)).name(1:end-4);
     
    index=setdiff(index,index(1));
    ind=findstr(temp,'.');
    subject_name=temp(ind(1)+1:ind(2)-1);
    condition=temp(ind(3)+1:end);

       disp(' ')
    disp(['converting files for ',subject_name])
    disp(['condition ', condition])
    disp(' ')

    %% make Info file for subject
   
    file_name_format='<ProjectID>.S<SubjectID>.<DateOfRecording [yymmdd]>.<Condition>';
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
       disp(' ')

    Info = Info_Object(file_name,file_name_format,description_project,time_of_recording, ...
        original_sample_frequency,converted_sample_frequency,researcher_ID, subject_gender,subject_age, ...
        subject_headsize, subject_handedness,subject_medication,notes);

    %     Info.Info.fell_asleep=input('Did the subject fall asleep? (1,2,3,4 or 5) ');
    %     Info.Info.thought_control=input('Did the subject have trouble remembering his/her thoughts? (1,2,3,4 or 5) ');

    %% convert corresponding .raw file and make NBT signal object

    [S,I]= Convert_one_EGIraw_file_ToNBT(RAW_dir,Info,file_name);
    eval(['[',condition,'_Signal]=S;'])
    eval(['[',condition,'_Info]=I;'])


    %% look for other recording from same subject

    for j=index
        if ~isempty(findstr(d(j).name,subject_name))

            index=setdiff(index,j);%remove file nr from index

            temp=d(j).name(1:end-4);
            ind=findstr(temp,'.');
            subject_name=temp(ind(1)+1:ind(2)-1);
            condition=temp(ind(3)+1:end);
            file_name=d(j).name(1:end-4);

               disp(' ')
            disp(['converting files for ',subject_name])
            disp(['condition ', condition])
             disp(' ')
             
             %% add condition specific info

            Info.time_of_recording=input('Enter time of recording (in the format: hhmm, for example 1233)');
            Info.notes=input('Enter notes ','s');
               disp(' ')

            [S,I]= Convert_one_EGIraw_file_ToNBT(RAW_dir,Info,file_name);
            eval(['[',condition,'_Signal]=S;'])
            eval(['[',condition,'_Info]=I;'])
        end
    end

    clear Info
    save([NBT_save_dir,'/',file_name(1:ind(3)-1),'.mat'],'*Info','*Signal')
    clear *Info
    clear *Signal

end






