function[A,Subj,Proj,Unit]= nbt_load_analysis(startpath, string, biomarker, func,A,Subj,Proj,Unit)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% nbt_load_analysis is designed to load files at the folder "startpath" and
% subfolders. Only .mat files with filenames containing the string "analysis"
% and "string (defined in input)" are loaded, to apply the function "func" on.
% A is the input and output of that function. Subj and Proj are arrays
% with project and subject ID's from the analysis files.

% Example:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [c,s,p]=nbt_load_analysis(path,condition1,biomarker,@nbt_get_biomarker,c,s,p);
%
%     function [A]=get_biomarker(file_name,biomarker,A)
%        disp(file_name)
%         ind=findstr(biomarker,'.');
%         S=load(file_name,biomarker(1:ind(1)-1));
%         A=[A;eval(['S.',biomarker])];
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This code will load all the analysis files in the folder at "path",
% and subsequently store the biomarker values from the field "biomarker" (defined in input)" from the analysis files in c1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==3
    A=[];
end

d= dir (startpath);
%--- for files copied from a mac
    startindex = 1;
    for i = 1:length(d)
        if   strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
            startindex = i+1;
        end
    end

for j=startindex:length(d)
        if isempty(string)
            aa=1;
        else
            aa=  strfind(d(j).name,string);
        end
        
        b =  strfind(d(j).name,'mat');
        cc=  strfind(d(j).name,'analysis');
        
        if (~isempty(aa) &&~isempty(b) &&~isempty(cc))
            [A,Unit]=func([startpath , '/',d(j).name],biomarker,A);
            [Pj,remainder] = strtok(d(j).name, '.');
            Proj = [Proj; Pj];
            Subj{length(Subj)+1} = strtok(remainder,'.');
            
        end
end


