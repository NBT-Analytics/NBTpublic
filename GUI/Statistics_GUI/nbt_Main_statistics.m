% nbt_Main_statistics - this function allows to run the NBT statistics
% interface
%
% Usage:
%   nbt_Main_statistics
%
% Inputs:
%    
% Outputs:
%
% Example:
%   
%
% References:
% 
% See also: 
%  nbt_definegroup, nbt_definegroups, nbt_selectbiomarkers,
%  nbt_selectchansregs, nbt_selectrunstatistics
  
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
% --------------


function nbt_Main_statistics
StatisticsSelection = figure('Units','pixels', 'name','NBT: Statistics' ,'numbertitle','off','Position',[60  400  180  400], ...
        'MenuBar','none','NextPlot','new','Resize','off');


g = gcf;
Col = get(g,'Color');

p1 = 10;
p2 = 325;
p3 = 160;
p4 = 40;
d = 70;
fontsize = 10;



GroupsButton = uicontrol(StatisticsSelection,'Style','pushbutton','String','Select Group(s)','Position',[p1 p2 p3 p4],'fontsize',fontsize);%,'callback',@GroupsButton_Callback);
set(GroupsButton,'callback','nbt_definegroups;');
BiomarkersButton = uicontrol(StatisticsSelection,'Style','pushbutton','String','Select Biomarker(s)','Position',[p1 p2-d p3 p4],'fontsize',fontsize);%,'callback',@BiomarkersButton_Callback);
set(BiomarkersButton,'callback','nbt_selectbiomarkers;');
ChannelsButton = uicontrol(StatisticsSelection,'Style','pushbutton','String','Select Channels and Regions','Position',[p1 p2-2*d p3 p4],'fontsize',fontsize);%,'callback',@ChannelsButton_Callback);
set(ChannelsButton,'callback','nbt_selectchansregs(G);');
StatisticsButton = uicontrol(StatisticsSelection,'Style','pushbutton','String','Select Statistics','Position',[p1 p2-3*d p3 p4],'fontsize',fontsize);
set(StatisticsButton,'callback','nbt_selectrunstatistics;');
ComparButton = uicontrol(StatisticsSelection,'Style','pushbutton','String','Compare Biomarkers','Position',[p1 p2-4*d p3 p4],'fontsize',fontsize);
set(ComparButton,'callback','G = nbt_comparebiomarkers(G);');
%     
% function BiomarkersButton_Callback(hObject, eventdata, handles)
% set(BiomarkersButton,'BackgroundColor','r')
% end
% function GroupsButton_Callback(hObject, eventdata, handles)
% set(GroupsButton,'BackgroundColor','r')
% end
% function ChannelsButton_Callback(hObject, eventdata, handles)
% set(ChannelsButton,'BackgroundColor','r')
% end
function message_under_constr(hObject, eventdata, handles)
disp('This function is under development.')
end

end
