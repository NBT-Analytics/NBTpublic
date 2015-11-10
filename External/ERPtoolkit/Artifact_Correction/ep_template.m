function ep_template
% ep_template
% Manual creation of blink template.
%
%Input:
%  EPdataset (via global variable)
%
%Output: (via save file)
%   Template file:
%   blinks: structured file with information about blink template
%      .template   : the averaged voltage values for the template
%      .eloc       : the electrode coordinates
%      .num        : the number of blinks averaged into the template

%History
%  by Joseph Dien (7/13/09)
%  jdien07@mac.com
%
%  bugfix 8/27/09 JD
%  Location of windows appearing partly off screen on some systems.
%
%  modified 8/30/09 JD
%  Added support for continuous data.
%
%  bugfix 9/5/09 JD
%  Crash when loading or saving blink template with spaces in the path name.
%  Maximum number of trials/segments not updating when switching between datasets.
%
%  bugfix 12/3/09 JD
%  Fixed crash when loading in blink template for a file or pathname with a space in it.
%
%  bugfix 12/8/09 JD
%  Bad channels incorrectly interpolated when adding a new blink to the template.

%     Copyright (C) 1999-2010  Joseph Dien
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

global EPmain EPdataset EPtemplate

scrsz = get(0,'ScreenSize');
EPtemplate.windowHeight=500;

templateFigure=findobj('Name', 'Blink Template Creation');

set(EPmain.handles.preprocess.template,'enable','off');
set(EPmain.handles.preprocess.preprocess,'enable','off');
set(EPmain.handles.preprocess.done,'enable','off');

if ~isempty(templateFigure)
    close(templateFigure)
end;
EPtemplate.handles.window = figure('Name', 'Blink Template Creation', 'NumberTitle', 'off', 'Position',[201 scrsz(4)-EPtemplate.windowHeight 700 EPtemplate.windowHeight]);

EPtemplate.handles.load = uicontrol('Style', 'pushbutton', 'String', 'Load',...
    'Position', [20 EPtemplate.windowHeight-100 60 30], 'Callback', @loadTemplate);

EPtemplate.handles.save = uicontrol('Style', 'pushbutton', 'String', 'Save',...
    'Position', [20 EPtemplate.windowHeight-130 60 30], 'Callback', @saveTemplate);

EPtemplate.handles.done = uicontrol('Style', 'pushbutton', 'String', 'Done',...
    'Position', [20 EPtemplate.windowHeight-160 60 30], 'Callback', @done);

EPtemplate.sessionFiles=[];
for theData=1:length(EPdataset.dataset)
    EPdata=ep_loadEPdataset(EPdataset,theData);
    if any(strcmp(EPdata.dataType,{'single_trial','continuous'})) && ~isempty(EPdata.eloc)
        EPtemplate.sessionFiles=[EPtemplate.sessionFiles theData];
    end;
end;

if ~isempty(EPtemplate.sessionFiles)
    EPtemplate.dataset=EPtemplate.sessionFiles(1); %the dataset currently being examined
else
    EPtemplate.sessionFiles=[];
end;

EPtemplate.trial=1; %the trial of the dataset currently being examined
EPtemplate.dataset=1; %the dataset currently being examined

EPtemplate.EPdata=ep_loadEPdataset(EPdataset,EPtemplate.sessionFiles(EPtemplate.dataset));
if strcmp(EPtemplate.EPdata.dataType,'continuous')
    EPtemplate.segLength=min(250,length(EPtemplate.EPdata.timeNames));
    EPtemplate.maxSegs=floor(length(EPtemplate.EPdata.timeNames)/EPtemplate.segLength);
else
    EPtemplate.maxSegs=length(EPtemplate.EPdata.cellNames);
end;

%remove bad channels
EPtemplate.criteria.neighbors=EPmain.preferences.preprocess.neighbors;
EPtemplate.criteria.badchan=EPmain.preferences.preprocess.badchan;
EPtemplate.badChans=ep_detectBadChans(EPtemplate.EPdata, EPtemplate.criteria,1);

eog=ep_findEOGchans(EPtemplate.EPdata.eloc);
EPtemplate.eog=[eog.LUVEOG eog.RUVEOG eog.LLVEOG eog.RLVEOG eog.LHEOG eog.RHEOG];

EPtemplate.minVolt=-700;
EPtemplate.maxVolt=700;

EPtemplate.blinks.template=zeros(length(EPtemplate.EPdata.chanNames),1);
EPtemplate.blinks.eloc=EPtemplate.EPdata.eloc;
EPtemplate.blinks.num=0;

EPtemplate.handles.leftTrial = uicontrol('Style', 'pushbutton', 'String', '<--',...
    'Position', [150 EPtemplate.windowHeight-250 50 30], 'Callback', @leftTrial);
if EPtemplate.trial ==1
    set(EPtemplate.handles.leftTrial,'enable','off');
end;

EPtemplate.handles.rightTrial = uicontrol('Style', 'pushbutton', 'String', '-->',...
    'Position', [300 EPtemplate.windowHeight-250 50 30], 'Callback', @rightTrial);
if EPtemplate.trial == EPtemplate.maxSegs
    set(EPtemplate.handles.rightTrial,'enable','off');
end;

EPtemplate.handles.trialNum=uicontrol('Style','text',...
    'String',sprintf('%d of %d',EPtemplate.trial,EPtemplate.maxSegs),'HorizontalAlignment','left',...
    'Position',[220 EPtemplate.windowHeight-250 60 30]);

EPtemplate.handles.leftDataset = uicontrol('Style', 'pushbutton', 'String', '<--',...
    'Position', [150 EPtemplate.windowHeight-300 50 30], 'Callback', @leftDataset);
if EPtemplate.dataset ==1
    set(EPtemplate.handles.leftDataset,'enable','off');
end;

EPtemplate.handles.rightDataset = uicontrol('Style', 'pushbutton', 'String', '-->',...
    'Position', [300 EPtemplate.windowHeight-300 50 30], 'Callback', @rightDataset);
if EPtemplate.dataset == length(EPtemplate.sessionFiles)
    set(EPtemplate.handles.rightDataset,'enable','off');
end;

EPtemplate.handles.dataset=uicontrol('Style','text',...
    'String',EPdataset.dataset(EPtemplate.sessionFiles(EPtemplate.dataset)).dataName,'HorizontalAlignment','left',...
    'Position',[220 EPtemplate.windowHeight-300 60 30]);

if strcmp(EPtemplate.EPdata.dataType,'continuous')
    EPtemplate.theTrial=squeeze(EPtemplate.EPdata.data(:,(EPtemplate.trial-1)*EPtemplate.segLength+1:EPtemplate.trial*EPtemplate.segLength,:,1,1));
else
    EPtemplate.theTrial=squeeze(EPtemplate.EPdata.data(:,:,EPtemplate.trial,1,1));
end
%baseline correct
baseline=max(EPtemplate.EPdata.baseline,1);
EPtemplate.theTrial=EPtemplate.theTrial-diag(mean(EPtemplate.theTrial(:,1:baseline),2))*ones(size(EPtemplate.theTrial));
[C EPtemplate.marker]=max(max(abs(EPtemplate.theTrial(EPtemplate.eog,:))));

EPtemplate.handles.butterflyPlot = axes('units','pixels','position',[150 EPtemplate.windowHeight-200 200 100]);
EPtemplate.handles.butterflyLines = plot([1:size(EPtemplate.theTrial,2)],EPtemplate.theTrial(EPtemplate.eog,:));
axis([1 size(EPtemplate.theTrial,2) EPtemplate.minVolt EPtemplate.maxVolt]);
EPtemplate.handles.marker=line(repmat(EPtemplate.marker,length([EPtemplate.minVolt:EPtemplate.maxVolt]),1),[EPtemplate.minVolt:EPtemplate.maxVolt],'Color','red','LineWidth',1); %marker
for i=1:length(EPtemplate.handles.butterflyLines)
    set(EPtemplate.handles.butterflyLines(i),'YDataSource',['EPtemplate.theTrial(' num2str(i) ',:)'])
end;

%2D plot of data
maxRad=0.5;
EPtemplate.gridSize=67;
[y,x] = pol2cart(([EPtemplate.EPdata.eloc.theta]/360)*2*pi,[EPtemplate.EPdata.eloc.radius]);  % transform electrode locations from polar to cartesian coordinates
y=-y; %flip y-coordinate so that nose is upwards.
plotrad = min(1.0,max([EPtemplate.EPdata.eloc.radius])*1.02);            % default: just outside the outermost electrode location
plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
x = x*(maxRad/plotrad);
y = y*(maxRad/plotrad);

xmin = min(-maxRad,min(x));
xmax = max(maxRad,max(x));
ymin = min(-maxRad,min(y));
ymax = max(maxRad,max(y));

EPtemplate.x=round(((x/(xmax-xmin))*EPtemplate.gridSize)+ceil(EPtemplate.gridSize/2));
EPtemplate.y=round(((y/(ymax-ymin))*EPtemplate.gridSize)+ceil(EPtemplate.gridSize/2));

trialGoodChans=setdiff([1:length(EPtemplate.EPdata.chanNames)],EPtemplate.badChans);
[Xi,Yi,Zi] = griddata(EPtemplate.x(trialGoodChans),EPtemplate.y(trialGoodChans),EPtemplate.theTrial(trialGoodChans,EPtemplate.marker),[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'linear');

EPtemplate.handles.topoplot = axes('units','pixels','position',[400 EPtemplate.windowHeight-200 100 100]);
EPtemplate.handles.topoplotImage = imagesc(Zi);

%2D plot of blink template
[Xi,Yi,Zi] = griddata(EPtemplate.x,EPtemplate.y,EPtemplate.blinks.template,[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'linear');

EPtemplate.handles.blink = axes('units','pixels','position',[550 EPtemplate.windowHeight-200 100 100]);
EPtemplate.handles.blinkImage = imagesc(Zi);

uicontrol('Style','text',...
    'String','Template','HorizontalAlignment','left',...
    'Position',[570 EPtemplate.windowHeight-100 60 20]);

EPtemplate.handles.add = uicontrol('Style', 'pushbutton', 'String', 'Add',...
    'Position', [550 EPtemplate.windowHeight-250 50 30], 'Callback', @add);

EPtemplate.handles.blinkNum=uicontrol('Style','text',...
    'String',sprintf('%d',EPtemplate.blinks.num),'HorizontalAlignment','left',...
    'Position',[610 EPtemplate.windowHeight-245 30 20]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function done(src,eventdata)
%quit from template window

global EPtemplate EPmain

close(EPtemplate.handles.window);

set(EPmain.handles.preprocess.template,'enable','on');
set(EPmain.handles.preprocess.preprocess,'enable','on');
set(EPmain.handles.preprocess.done,'enable','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function leftTrial(src,eventdata)
%move to previous trial

global EPtemplate

if EPtemplate.trial > 1
    EPtemplate.trial=EPtemplate.trial-1;
end;

if EPtemplate.trial ==1
    set(EPtemplate.handles.leftTrial,'enable','off');
end;

set(EPtemplate.handles.rightTrial,'enable','on');

displayTrial

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rightTrial(src,eventdata)
%move to next trial

global EPtemplate

if EPtemplate.trial < EPtemplate.maxSegs
    EPtemplate.trial=EPtemplate.trial+1;
end;

if EPtemplate.trial == EPtemplate.maxSegs
    set(EPtemplate.handles.rightTrial,'enable','off');
end;

set(EPtemplate.handles.leftTrial,'enable','on');

displayTrial

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function leftDataset(src,eventdata)
%move to previous dataset

global EPtemplate EPdataset EPmain

if EPtemplate.dataset > 1
    EPtemplate.dataset=EPtemplate.dataset-1;
end;

if EPtemplate.dataset ==1
    set(EPtemplate.handles.leftDataset,'enable','off');
end;

if strcmp(EPtemplate.EPdata.dataType,'continuous')
    EPtemplate.segLength=min(250,length(EPtemplate.EPdata.timeNames));
    EPtemplate.maxSegs=floor(length(EPtemplate.EPdata.timeNames)/EPtemplate.segLength);
else
    EPtemplate.maxSegs=length(EPtemplate.EPdata.cellNames);
end;

EPtemplate.trial=1;

set(EPtemplate.handles.rightDataset,'enable','on');

delete(EPtemplate.handles.dataset)
EPtemplate.handles.dataset=uicontrol('Style','text',...
    'String',EPdataset.dataset(EPtemplate.sessionFiles(EPtemplate.dataset)).dataName,'HorizontalAlignment','left',...
    'Position',[220 EPtemplate.windowHeight-300 60 30]);

EPtemplate.EPdata=ep_loadEPdataset(EPdataset,EPtemplate.sessionFiles(EPtemplate.dataset));
%remove bad channels
EPtemplate.criteria.neighbors=EPmain.preferences.preprocess.neighbors;
EPtemplate.criteria.badchan=EPmain.preferences.preprocess.badchan;
EPtemplate.badChans=ep_detectBadChans(EPtemplate.EPdata, EPtemplate.criteria,1);

set(EPtemplate.handles.leftTrial,'enable','off');
set(EPtemplate.handles.rightTrial,'enable','on');

displayTrial

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rightDataset(src,eventdata)
%move to next dataset

global EPtemplate EPdataset EPmain

if EPtemplate.dataset < length(EPtemplate.sessionFiles)
    EPtemplate.dataset=EPtemplate.dataset+1;
end;

if EPtemplate.dataset == length(EPtemplate.sessionFiles)
    set(EPtemplate.handles.rightDataset,'enable','off');
end;

if strcmp(EPtemplate.EPdata.dataType,'continuous')
    EPtemplate.segLength=min(250,length(EPtemplate.EPdata.timeNames));
    EPtemplate.maxSegs=floor(length(EPtemplate.EPdata.timeNames)/EPtemplate.segLength);
else
    EPtemplate.maxSegs=length(EPtemplate.EPdata.cellNames);
end;

EPtemplate.trial=1;

set(EPtemplate.handles.leftDataset,'enable','on');

delete(EPtemplate.handles.dataset)
EPtemplate.handles.dataset=uicontrol('Style','text',...
    'String',EPdataset.dataset(EPtemplate.sessionFiles(EPtemplate.dataset)).dataName,'HorizontalAlignment','left',...
    'Position',[220 EPtemplate.windowHeight-300 60 30]);

EPtemplate.EPdata=ep_loadEPdataset(EPdataset,EPtemplate.sessionFiles(EPtemplate.dataset));
%remove bad channels
EPtemplate.criteria.neighbors=EPmain.preferences.preprocess.neighbors;
EPtemplate.criteria.badchan=EPmain.preferences.preprocess.badchan;
EPtemplate.badChans=ep_detectBadChans(EPtemplate.EPdata, EPtemplate.criteria,1);

set(EPtemplate.handles.leftTrial,'enable','off');
set(EPtemplate.handles.rightTrial,'enable','on');

displayTrial

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayTrial
%display the updated trial data

global EPtemplate

if strcmp(EPtemplate.EPdata.dataType,'continuous')
    EPtemplate.theTrial=squeeze(EPtemplate.EPdata.data(:,(EPtemplate.trial-1)*EPtemplate.segLength+1:EPtemplate.trial*EPtemplate.segLength,:,1,1));
else
    EPtemplate.theTrial=squeeze(EPtemplate.EPdata.data(:,:,EPtemplate.trial,1,1));
end
%baseline correct
baseline=max(EPtemplate.EPdata.baseline,1);
EPtemplate.theTrial=EPtemplate.theTrial-diag(mean(EPtemplate.theTrial(:,1:baseline),2))*ones(size(EPtemplate.theTrial));
[C EPtemplate.marker]=max(max(abs(EPtemplate.theTrial)));
delete(EPtemplate.handles.marker);
set(EPtemplate.handles.window,'CurrentAxes',EPtemplate.handles.butterflyPlot)
EPtemplate.handles.marker=line(repmat(EPtemplate.marker,length([EPtemplate.minVolt:EPtemplate.maxVolt]),1),[EPtemplate.minVolt:EPtemplate.maxVolt],'Color','red','LineWidth',1); %marker

refreshdata(EPtemplate.handles.butterflyLines)

%2D plot
trialGoodChans=setdiff([1:length(EPtemplate.EPdata.chanNames)],EPtemplate.badChans);
[Xi,Yi,Zi] = griddata(EPtemplate.x(trialGoodChans),EPtemplate.y(trialGoodChans),EPtemplate.theTrial(trialGoodChans,EPtemplate.marker),[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'linear');

delete(EPtemplate.handles.topoplotImage);
set(EPtemplate.handles.window,'CurrentAxes',EPtemplate.handles.topoplot)
EPtemplate.handles.topoplotImage = imagesc(Zi);

delete(EPtemplate.handles.trialNum);
EPtemplate.handles.trialNum=uicontrol('Style','text',...
    'String',sprintf('%d of %d',EPtemplate.trial,EPtemplate.maxSegs),'HorizontalAlignment','left',...
    'Position',[220 EPtemplate.windowHeight-250 60 30]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function add(src,eventdata)
%add data at marker to the blink template

global EPtemplate

if strcmp(EPtemplate.EPdata.dataType,'continuous')
    theTrial=squeeze(EPtemplate.EPdata.data(:,(EPtemplate.trial-1)*EPtemplate.segLength+1:EPtemplate.trial*EPtemplate.segLength,:,1,1));
else
    theTrial=squeeze(EPtemplate.EPdata.data(:,:,EPtemplate.trial,1,1));
end

%baseline correct
baseline=max(EPtemplate.EPdata.baseline,1);
theTrial=theTrial-diag(mean(theTrial(:,1:baseline),2))*ones(size(theTrial));

theBlink=theTrial(:,EPtemplate.marker);

%if there are bad channels, then first interpolate them
if ~isempty(EPtemplate.badChans)
    trialGoodChans=setdiff([1:length(EPtemplate.EPdata.chanNames)],EPtemplate.badChans);
    [Xi,Yi,Zi] = griddata(EPtemplate.x(trialGoodChans),EPtemplate.y(trialGoodChans),theBlink(trialGoodChans),[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'v4');
    for theBadchan=1:length(EPtemplate.badChans)
        badchan=EPtemplate.badChans(theBadchan);
        theBlink(badchan)=Zi(EPtemplate.y(badchan),EPtemplate.x(badchan));
    end;
end;

EPtemplate.blinks.template=EPtemplate.blinks.template*(EPtemplate.blinks.num/(EPtemplate.blinks.num+1))+theBlink/(EPtemplate.blinks.num+1);
EPtemplate.blinks.num=EPtemplate.blinks.num+1;

[Xi,Yi,Zi] = griddata(EPtemplate.x,EPtemplate.y,EPtemplate.blinks.template,[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'linear');

delete(EPtemplate.handles.blinkImage);
set(EPtemplate.handles.window,'CurrentAxes',EPtemplate.handles.blink)
EPtemplate.handles.blinkImage = imagesc(Zi);

delete(EPtemplate.handles.blinkNum);
EPtemplate.handles.blinkNum=uicontrol('Style','text',...
    'String',sprintf('%d',EPtemplate.blinks.num),'HorizontalAlignment','left',...
    'Position',[600 EPtemplate.windowHeight-250 60 20]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loadTemplate(src,eventdata)
%load blink template

global EPtemplate EPdataset

EPdata=ep_loadEPdataset(EPdataset,EPtemplate.dataset);

[FileName,PathName,FilterIndex] = uigetfile('','Load Blink Template','blinks');
if FileName ~= 0
    eval(['load ''' PathName FileName '''']);
    if ~exist('EPblink','var')
        warndlg('Not a blink template.');
        return
    end;
    
    if length(EPblink.eloc) ~= length(EPtemplate.blinks.eloc)
        warndlg('Number of electrodes different from current dataset.');
        return
    end;
    
    if any([EPtemplate.blinks.eloc.theta]-[EPdata.eloc.theta])
        warndlg('Electrode locations not consistent with current data.');
        return
    end;
        
    EPtemplate.blinks=EPblink;
        
end;

[Xi,Yi,Zi] = griddata(EPtemplate.x,EPtemplate.y,EPtemplate.blinks.template,[1:EPtemplate.gridSize]',[1:EPtemplate.gridSize],'linear');

delete(EPtemplate.handles.blinkImage);
set(EPtemplate.handles.window,'CurrentAxes',EPtemplate.handles.blink)
EPtemplate.handles.blinkImage = imagesc(Zi);

delete(EPtemplate.handles.blinkNum);
EPtemplate.handles.blinkNum=uicontrol('Style','text',...
    'String',sprintf('%d',EPtemplate.blinks.num),'HorizontalAlignment','left',...
    'Position',[600 EPtemplate.windowHeight-250 60 20]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveTemplate(src,eventdata)
%save blink template

global EPtemplate

[FileName,PathName,FilterIndex] = uiputfile('','Save Blink Template','blinks');
EPblink=EPtemplate.blinks;
eval(['save ''' PathName FileName ''' EPblink']);

