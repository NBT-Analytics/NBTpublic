% nbt_defineconditions - Open Interface for defining two conditions for statistics,
%                   it generates a new directory struct called SelectedFiles
%                   which contains only the files selected for the statistics
%
% Usage:
%   nbt_defineconditions(d)
%   or
%   nbt_defineconditions(d,cond1,cond2)
%
% Inputs:
%   d is a directory struct obtained as follow d = dir(path); with path
%   indicating the location of NBT files
%   cond1,cond2 strings
%
% Outputs:
%
% Example:
%   nbt_defineconditions(d,'ECR1', 'EOR1')
%
% References:
%
% See also:
%

%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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



function nbt_defineconditions(varargin)
P=varargin;
nargs=length(P);

if (nargs<1 || isempty(P{1}))
    error('Missing input');
else
    d = P{1};
end

if(nargs<4)
    P{4} = 2;
end

%--- scan files in the folder
%--- for files copied from a mac
startindex = 0;
for i = 1:length(d)
    if   strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
        startindex = i+1;
    end
end
%---
readconditions = '';
con = 1;
for i = startindex:length(d)
    if isempty(findstr(d(i).name,'analysis')) && isempty(findstr(d(i).name,'info')) && ~isempty(findstr(d(i).name(end-3:end),'.mat')) && isempty(findstr(d(i).name,'statistics'))
        index = findstr(d(i).name,'.');
        if i == startindex
            readconditions{con} =  d(i).name(index(3)+1:index(4)-1);
            con = con+1;
        else
            if ~strcmp(readconditions,d(i).name(index(3)+1:index(4)-1))
                readconditions{con} = d(i).name(index(3)+1:index(4)-1);
                con = con+1;
            end
        end
    end
end

if nargin<2 || isempty(P{2})
    %--- interface
    scrsz = get(0,'ScreenSize');
    ConditionsSelection = figure('Units','points', 'name','Select Conditions' ,'numbertitle','off','Position',[390.0000  456.7500  200  88.5000], ...
        'MenuBar','none','NextPlot','new','Resize','off');
    g = gcf;
    Col = get(g,'Color');
    listBox1 = uicontrol(ConditionsSelection,'Style','listbox','Units','characters',...
        'Position',[4 1 15 4],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', readconditions,'Value',[]);
    plotButton = uicontrol(ConditionsSelection,'Style','pushbutton','Units','characters',...
        'Position',[20 1 6 2],...
        'String','OK','callback', @conditionsdefinition);
else
    selection.con{1} = P{2};
    selection.con{2} = P{3};
    %--- generate Selected file dir struct
    startindex = 0;
    for i = 1:length(d)
        if  d(i).isdir || strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
            startindex = i+1;
        end
    end
    k = 1;
    for i = startindex:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            analysis_files(k) = d(i);
            k = k +1;
        end
    end
    g =1;
    if length(selection.con)>P{4}
        eval(['error(''Select' int2str(P{4}) 'conditions'')']);
    end
    % --- condition 1
    k = 1;
    for i = 1:length(analysis_files)
        if ~isempty(findstr(cell2mat(selection.con(1)),analysis_files(i).name))
            ind1(k) = i;
            k = k+1;
        end
    end
    % --- condition 2
    k = 1;
    for i = 1:length(analysis_files)
        if ~isempty(findstr(cell2mat(selection.con(2)),analysis_files(i).name))
            ind2(k) = i;
            k = k+1;
        end
    end
    d1 = analysis_files(ind1);
    d2 = analysis_files(ind2);
    SelectedFiles.d1 = d1;
    SelectedFiles.d2 = d2;
    assignin('base','SelectedFiles',SelectedFiles) 
end


% --- nested callback function
    function conditionsdefinition(src,evt)
        
        vars1 = get(listBox1,'String');
        var_index1 = get(listBox1,'Value');
        if length(vars1) == P{4};
            selection.con = vars1;
        else
            if isempty(var_index1)
                selection.con = vars1;
            elseif length(var_index1)~=P{4}
            else
                if length(vars1) == length(var_index1)
                    selection.con = vars1;
                else
                    clear selection.con
                    selection.con = vars1(var_index1);
                end
            end
        end
        
        %--- generate Selected file dir struct
        startindex = 0;
        for i = 1:length(d)
            if   strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
                startindex = i+1;
            end
        end
        k = 1;
        for i = startindex:length(d)
            if ~isempty(findstr('analysis',d(i).name))
                analysis_files(k) = d(i);
                k = k +1;
            end
        end
        g =1;
        if length(selection.con)>P{4}
            eval(['error(''Select' int2str(P{4}) 'conditions'')']);
        end
        % --- conditions loop over files
        for ii=1:P{4}
            k = 1;
            for i = 1:length(analysis_files)
                if ~isempty(findstr(cell2mat(selection.con(ii)),analysis_files(i).name))
                    ind(k,ii) = i;
                    k = k+1;
                end
            end
        end
        for ii=1:P{4}
          eval(['SelectedFiles.d' int2str(ii) ' = analysis_files(ind(:,' int2str(ii) '));']); 
         
        end
       
        assignin('base','SelectedFiles',SelectedFiles)
        close all
    end
end
