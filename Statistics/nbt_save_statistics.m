% nbt_save_statistics
%
% Usage:
%   nbt_save_statistics(index,files,statdata,biomarker,savedirectory)
%
% Inputs:
%   index if 1=subject; if 2=group, if 3= conditions; if 4= groups
%   files list of fielnames included in the statistics
%   statdata struct with statistical info
%   savedirectory directory where you save your data (optional)
%   stringname (opetional)
%
% Outputs:
%
% Example:
%
%   
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by giuseppina Schiavone (2012), see NBT website
% (http://www.nbtwiki.net) for current email address
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

function nbt_save_statistics(varargin);
%--- inputs
P=varargin;
nargs=length(P);
index = P{1};
filesdir = P{2};
statdata = P{3};
biomarker = P{4};
fileslist = filesdir(1).name;
%--- select Folder
if (nargs<5 || isempty(P{5}))
    [path]=uigetdir([],'select folder for saving statistics'); 
else
    path = P{5}; 
end;
%--- create savefile name
dotsinfilename = strfind(fileslist,'.');
projid = fileslist(1:dotsinfilename(1)-1);
savefilename = [path '/' projid '_statistics.mat'];
%--- check if name for the group/condition/groups already exist
if (nargs<6 || isempty(P{6}))
    stringname = '';
else
    stringname = P{6}; 
end;
%--- 
statdata.biomarker = biomarker;
switch index
    case 1 %within subject
%         if(exist(savefilename,'file') == 2)
%             disp('NBT: Statistics File already exists.');
%             
%             if ~isfield(load(savefilename),'subject')
%                 sub = 1;
%             else
%                 eval('load(savefilename,''subject'')')
%                 subject = evalin('base','subject');
%                 sub = length(subject)+1;
%                 nonsave = 0;
%                 for i = 1:length(subject)
%                     if strcmp(subject(i).IDproject{:},cellstr(strcat(projid, '_', statdata.test, '_', biomarker))) && strcmp(subject(sub-1).IDsubject,fileslist(dotsinfilename(1)+1:dotsinfilename(2)-1))
%                         dis(cellstr(strcat( projid, '_', statdata.test, '_', biomarker, ' already exists for subject ID: ', subject(sub-1).IDsubject)))      
%                         dis('The statistics will not be saved.')
%                         nonsave = 1;
%                         break
%                     end
%                 end
%                 
%             end
%             if nonsave == 1
%                 eval(['evalin(''caller'',''clear subject'');']);
%                 return
%             end
%             subject(sub).IDprojecttest = [projid '_' statdata.test '_' biomarker];
%             subject(sub).fileslist = filesdir; 
%             subject(sub).statdata = statdata;
%             subject(sub).IDsubject = fileslist(dotsinfilename(1)+1:dotsinfilename(2)-1);
%             try
%                 save(savefilename,'subject','-append')
%                 dis('Statistics have been successfully saved!')
%                 eval(['evalin(''caller'',''clear subject'');']);
%             catch
%                 save(savefilename,'subject')
%                 disp('Statistics have been successfully saved!')
%                 eval(['evalin(''caller'',''clear subject'');']);
%             end
%         else
%             sub = 1;
%             subject(sub).IDproject = [projid '_' statdata.test '_' biomarker];
%             subject(sub).fileslist = filesdir; 
%             subject(sub).statdata = statdata;
%             subject(sub).IDsubject = fileslist(dotsinfilename(1)+1:dotsinfilename(2)-1);
%             try
%                 save(savefilename,'subject','-append')
%                 disp('Statistics have been successfully saved!')
%                 eval(['evalin(''caller'',''clear subject'');']);
%             catch
%                 save(savefilename,'subject')
%                 disp('Statistics have been successfully saved!')
%                 eval(['evalin(''caller'',''clear subject'');']);
%             end
%         end
        
    case 2 %within group
        %--- check if file exists
        if(exist(savefilename,'file') == 2)
            disp('NBT: Statistics File already exists.');
             %--- check if field exists
            if ~isfield(load(savefilename),'group')
                gr = 1;
                if isempty(stringname)
                    groupname = input('Give a name to the group [es. control or press enter for not saving the statistics]: ','s');
                else
                    groupname = stringname;
                end
            
            else
                eval('load(savefilename,''group'')')
                gr = length(group)+1;
                for i = 1:length(group)
                    if strcmp(group(i).IDproject,[projid, '.', statdata.test{:}, '.', biomarker]) 
                        disp([ projid, ' ', statdata.test{:}, ' for ', biomarker,' already exists with groupname: ', group(i).groupname])     
                    end
                end
                if isempty(stringname)
                    groupname = input('Give a name to the group [es. control or press enter for not saving the statistics]: ','s');
                else
                    groupname = stringname;
                end
                
            end
            if isempty(groupname)
               eval(['evalin(''caller'',''clear group'');']);
               return
            end    
            group(gr).IDproject =[projid, '.', statdata.test{:}, '.', biomarker];
            group(gr).fileslist = filesdir; 
            group(gr).statdata = statdata;
            group(gr).groupname = groupname;
            try
                save(savefilename,'group','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear group'');']);
            catch
                save(savefilename,'group')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear group'');']);
            end
        else
            if isempty(stringname)
                    groupname = input('Give a name to the group [es. control or press enter for not saving the statistics]: ','s');
                else
                    groupname = stringname;
            end
            if isempty(groupname)
               eval(['evalin(''caller'',''clear group'');']);
               return
            end
            gr = 1;
            group(gr).IDproject = [projid, '.', statdata.test{:}, '.', biomarker];
            group(gr).fileslist = filesdir; 
            group(gr).statdata = statdata;
            group(gr).groupname = groupname;
            try
                save(savefilename,'group','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear group'');']);
            catch
                save(savefilename,'group')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear group'');']);
            end
        end
    case 3 %between conditions
        if(exist(savefilename,'file') == 2)
            disp('NBT: Statistics File already exists.');
            if ~isfield(load(savefilename),'conditions')
                gr = 1;
                if isempty(stringname)
                    conditionsname = input('Give a name to the conditions [es. EOR_vs_ECR] or press enter for not saving the statistics]: ','s');
                else
                    conditionsname = stringname;
                end
            else
                eval('load(savefilename,''conditions'')')
%                 group = evalin('caller','group');
                
                gr = length(conditions)+1;
                n = 0;
                for i = 1:length(conditions)
                    if strcmp(conditions(i).IDproject,[projid, '.', statdata.test{:}, '.', biomarker]) 
                        disp([ projid, ' ', statdata.test{:}, ' for ', biomarker,' already exists with groupname: ', conditions(i).conditionsname])      
                        n = n+1;
                    end
                end
                if isempty(stringname)
                    conditionsname = input('Give a name to the conditions [es. EOR_vs_ECR] or press enter for not saving the statistics]: ','s');
                elseif ~isempty(stringname) && n>0
                    conditionsname = [];
                elseif ~isempty(stringname) && n==0
                     conditionsname = stringname;
                end
                
            end
            
            if isempty(conditionsname)
               eval(['evalin(''caller'',''clear conditions'');']);
               return
            end    
            conditions(gr).IDproject = [projid, '.', statdata.test{:}, '.', biomarker];
            conditions(gr).fileslist = filesdir; 
            conditions(gr).statdata = statdata;
            conditions(gr).conditionsname = conditionsname;
            try
                save(savefilename,'conditions','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear conditions'');']);
            catch
                save(savefilename,'conditions')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear conditions'');']);
            end
        else
            if isempty(stringname)
                    conditionsname = input('Give a name to the conditions [es. EOR_vs_ECR] or press enter for not saving the statistics]: ','s');
                else
                    conditionsname = stringname;
            end
            if isempty(conditionsname)
               eval(['evalin(''caller'',''clear conditions'');']);
               return
            end
            gr = 1;
            conditions(gr).IDproject = [projid, '.', statdata.test{:}, '.', biomarker];
            conditions(gr).fileslist = filesdir; 
            conditions(gr).statdata = statdata;
            conditions(gr).conditionsname = conditionsname;
            try
                save(savefilename,'conditions','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear conditions'');']);
            catch
                save(savefilename,'conditions')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear conditions'');']);
            end
        end
        
        
    case 4 %between groups
        if(exist(savefilename,'file') == 2)
            disp('NBT: Statistics File already exists.');
            if ~isfield(load(savefilename),'groups')
                grs = 1;
                if isempty(stringname)
                    groupsname = input('Give a name to the groups [es. control_vs_experimental] or press enter for not saving the statistics]: ','s');
                else
                    groupsname = stringname;
                end
                
            else
                eval('load(savefilename,''groups'')')
%                 group = evalin('caller','group');
                
                grs = length(groups)+1;
                for i = 1:length(groups)
                    if strcmp(groups(i).IDproject,[projid, '.', statdata.test{:}, '.', biomarker]) 
                        disp([ projid, ' ', statdata.test{:}, ' for ', biomarker,' already exists with groupname: ', groups(i).groupsname])     
                    end   
                end
                if isempty(stringname)
                    groupsname = input('Give a name to the groups [es. control_vs_experimental] or press enter for not saving the statistics]: ','s');
                else
                    groupsname = stringname;
                end
                
            end
            
            
            if isempty(groupsname)
               eval(['evalin(''caller'',''clear groups'');']);
               return
            end    
            groups(grs).IDproject = [projid, '.', statdata.test{:}, '.', biomarker];
            groups(grs).fileslist = filesdir; 
            groups(grs).statdata = statdata;
            groups(grs).groupsname = groupsname;
            try
                save(savefilename,'groups','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear groups'');']);
            catch
                save(savefilename,'groups')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear groups'');']);
            end
        else
            if isempty(stringname)
                    groupsname = input('Give a name to the groups [es. control_vs_experimental] or press enter for not saving the statistics]: ','s');
                else
                    groupsname = stringname;
            end
            if isempty(groupsname)
               eval(['evalin(''caller'',''clear groups'');']);
               return
            end 
            
            grs = 1;
            groups(grs).IDproject = [projid, '.', statdata.test{:}, '.', biomarker];
            groups(grs).fileslist = filesdir; 
            groups(grs).statdata = statdata;
            groups(grs).groupsname = groupsname;
            try
                save(savefilename,'groups','-append')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear groups'');']);
            catch
                save(savefilename,'groups')
                disp('Statistics have been successfully saved!')
                eval(['evalin(''caller'',''clear groups'');']);
            end
        end
end

