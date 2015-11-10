function [s1,s2,s3] = nbt_splitSubjectsBio(bioms1Name,bioms2Name,B_values1,B_values2)


StatSelection = figure('Units','points', 'name','Split subjects based on Biomarker' ,'numbertitle','off','Position',[50  0  250  620],...
    'MenuBar','none','NextPlot','new','Resize','off');

% regions or channels
reglist{1} = 'Channels';
reglist{2} = 'Regions';
%biomarker
hp = uipanel(StatSelection,'Title','Select Biomarker to split on','FontSize',8,'Units','pixels','Position',[5 320 300 50]);
ListBio = uicontrol(hp,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 30],'fontsize',8,'String',[bioms1Name,bioms2Name]);
% Type of split
hp2 = uipanel(StatSelection,'Title','%split or split on value','FontSize',8,'Units','pixels','Position',[5 450 300 150]);
ListSplit = uicontrol(hp2,'Units', 'pixels','style','listbox','Max',1,'Units', 'pixels','Position',[5 5 290 130],'fontsize',8,'String',{'% split','value split'});
% tests
hp3 = uipanel(StatSelection,'Title','value','FontSize',8,'Units','pixels','Position',[5 620 300 150]);
ListSplitValue = uicontrol(hp3,'Units', 'pixels','style','edit','Max',1,'Units', 'pixels','Position',[5 5 290 130],'fontsize',8,'String','50');


RunButton = uicontrol(StatSelection,'Style','pushbutton','String','View Groups','Position',[5 5 100 50],'fontsize',8,'callback',{@nbt_splitPlotGroups,ListBio,ListSplit,ListSplitValue,B_values1,B_values2});
AcceptButton = uicontrol(StatSelection,'Style','pushbutton','String','Accept Splitting','Position',[5 5 100 50],'fontsize',8,'callback',{@nbt_splitPlotGroups,ListBio,ListSplit,ListSplitValue,B_values1,B_values2});
s1 = ListBio;
s2 = ListSplit;
s3 = ListSplitValue;

