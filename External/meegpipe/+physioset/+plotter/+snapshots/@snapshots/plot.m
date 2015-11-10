function [figNames, captions, groupNames, extra, extraCap] = ...
    plot(obj, data, varargin)
% PLOT - Plot summary snapshots from a physioset object
%
% import pset.plotter.snapshots;
% [figNames, captions, groupNames] = plot(obj, data)
%
%
% Where
%
% DATA is a physioset object
%
% FIGNAMES is a Kx1 cell array of cell arrays. Each of the K elements of
% the cell array group image files that belong to the same group.
%
% CAPTIONS is a Kx1 cell array of cell arrays of strings. Each string
% is the corresponding caption for a given figure.
%
% GROUPNAMES is a Kx1 cell array of strings. Each element is the title
% of the corresponding image group in H.
%
% EXTRA is a Kx1 cell array of "extra" images file names. An extra figure
% can be understood as secondary, less informative image. Extra images and
% the images in FIGNAMES are treated differenty by report generators in
% package. Similarly to FIGNAMES, each element of EXTRA is a cell array
% that contains image file names for a given group.
%
% EXTRACAP is the equivalent of CAPTIONS for the figures in EXTRA.
%
%
% See also: pset.plotter.time.snapshots, pset.plotter.time.config.snapshots

import mperl.file.spec.catfile;
import physioset.plotter.default_channel_groups;
import plotter.driver2format;
import plot2svg.plot2svg;
import mperl.join;
import misc.unique_filename;
import goo.pkgisa;
import physioset.plotter.snapshots.snapshots;
import pset.session;
import inkscape.svg2png;
import datahash.DataHash;
import plotter.cell2ticks;
import misc.num2strcell;

%% Error checking
if ~pkgisa(data, 'physioset'),
    error('DATA must be a physioset object');
end

% We need to get a COPY of the configuration!
config = get_config(obj);
if isempty(config.Folder),
    config.Folder = session.instance.Folder;
end

%% Call recursively for multiple window lengths/epoch definitions
if numel(config.WinLength) > 1 && isempty(config.Epochs),
    
    figNames    = [];
    groupNames  = [];
    captions    = [];
    extra       = [];
    extraCap    = [];
    
    % Discard repeated or beyond range window lengths
    wLengths    = config.WinLength;
    dataLength  = max(1, floor(size(data,2)/data.SamplingRate));
    wLengths(wLengths > dataLength) = dataLength;
    wLengths    = unique(wLengths);
    
    for i = 1:numel(wLengths),
        thisObj = clone(obj);
        thisObj = set_config(thisObj, 'WinLength', wLengths(i));
        [thisH, thisCaptions, thisGroupName, thisExtra, thisExtraCap] = ...
            plot(thisObj, data, varargin{:});
        figNames    = [figNames;thisH(:)]; %#ok<*AGROW>
        groupNames  = [groupNames; thisGroupName(:)];
        captions    = [captions; thisCaptions(:)];
        extra       = [extra; thisExtra(:)];
        extraCap    = [extraCap; thisExtraCap(:)];
    end
    
    return;
    
else
    
    % Ensure the window length does not go beyond the data range
    dataLength  = max(1, floor(size(data,2)/data.SamplingRate));
    if config.WinLength > dataLength,
        config.WinLength = dataLength;
    end
    
end

%% Default channel grouping for plotting
if isempty(config.Channels),
    
    [config.Channels, config.ChannelClass, config.ChannelType] = ...
        default_channel_groups(data, ...
        config.MaxChannels, ...
        config.ChannelClass, ...
        config.ChannelType);
    
end

%% Call recursively for each channel group
if iscell(config.Channels),
    figNames    = [];
    groupNames  = [];
    captions    = [];
    extra       = [];
    extraCap    = [];
    for grpItr = 1:numel(config.Channels),
        
        thisSensors = subset(sensors(data), config.Channels{grpItr});
        if isempty(config.ChannelClass),
            tmpGrp = sensor_groups(thisSensors);
            thisChannelClass = ...
                cellfun(@(x) upper(regexprep(class(x), '^.+?([^\.]+)$', '$1')), ...
                tmpGrp, 'UniformOutput', false);
            thisChannelClass = join(', ', thisChannelClass);
        else
            thisChannelClass = config.ChannelClass{grpItr};
        end
        
        if isempty(config.ChannelType),
            thisChannelType = join(', ', unique(types(thisSensors)));
        else
            thisChannelType = config.ChannelType{grpItr};
        end
        
        thisObj = set_config(clone(obj), ...
            'Channels',        config.Channels{grpItr}, ...
            'ChannelClass',    thisChannelClass, ...
            'ChannelType',     thisChannelType);
        
        [thisH, thisCaptions, thisGroupName, thisExtra, thisExtraCap] = ...
            plot(thisObj, data, varargin{:});
        
        figNames    = [figNames;    thisH(:)]; %#ok<*AGROW>
        groupNames  = [groupNames;  thisGroupName(:)];
        captions    = [captions;    thisCaptions(:)];
        extra       = [extra;       thisExtra(:)];
        extraCap    = [extraCap;    thisExtraCap(:)];
        
    end
    
    return;
    
else
    chanIdx = config.Channels;
end

%% Determine the data epochs that will be plotted
if isempty(config.Epochs),
    epochLength = config.WinLength*data.SamplingRate;
    [epochs, groupNames] = snapshots.summary_epochs(epochLength, ...
        size(data,2), [], config);
else
    epochs = {config.Epochs};
    groupNames = {repmat('', numel(config.Epochs), 1)};
end

%% Decide the downsampling factor
% It is often necessary to downsample the data in order to be able to
% produce a .svg file of reasonable size. Moreover, certain versions of
% inkscape cannot handle too large .svg files
maxEpochLength = 0;
for i = 1:numel(epochs)
    maxEpochLength = max(maxEpochLength, max(diff(epochs{i}')));
end
nbPointsSnapshot   = numel(chanIdx)*maxEpochLength;
maxNbVertices      = get_config(obj, 'MaxNbVertices');
downsamplingFactor = ceil(nbPointsSnapshot/maxNbVertices);
if downsamplingFactor > 8
    downsamplingFactor = 8;
end


%% Convert sensObj to EEGLAB's format
if ~isempty(sensors(data)) && ...
        ismember(class(sensors(data)), {'sensors.eeg', 'sensors.meg'}),
    sensObj = eeglab(sensors(data));
    sensObj = sensObj(chanIdx);
else
    sensObj = [];
end
arguments = {...
    'srate',        round(data.SamplingRate/downsamplingFactor), ...
    'winlength',    config.WinLength, ...
    'eloc_file',    sensObj};

%% Initialize output arguments
figNames    = cell(numel(epochs), 1);
captions    = cell(numel(epochs), 1);
extra       = cell(numel(epochs), 1);
extraCap    = cell(numel(epochs), 1);

% The user may have provided more than one dataset
count = 0;
while count < numel(varargin) && pkgisa(varargin{count+1}, 'physioset')
    count = count + 1;
end
extraData = varargin(1:count);
varargin  = varargin(count+1:end);

%% Plot each epoch using EEGLAB
for groupItr = 1:numel(epochs)
    
    captions{groupItr}  = cell(size(epochs{groupItr},1),1);
    figNames{groupItr}  = cell(size(epochs{groupItr},1),1);
    extra{groupItr}     = cell(size(epochs{groupItr},1)*2,1);
    extraCap{groupItr}  = cell(size(epochs{groupItr},1)*2,1);
    extraPicCount = 0;
    
    for epochItr = 1:size(epochs{groupItr},1)
        
        firstSample = epochs{groupItr}(epochItr, 1);
        lastSample = epochs{groupItr}(epochItr, 2);
        
        thisEpoch = cell(1, 1+numel(extraData));
        thisEpoch{1} = data(chanIdx, firstSample:lastSample);
        for i = 1:numel(extraData)
            if ~all(size(data) == size(extraData{i})),
                error('snapshots:plot:WrongDimensions', ...
                    'Cannot overlay plots for datasets with different dimensionality');
            end
            thisEpoch{i+1} = extraData{i}(chanIdx, firstSample:lastSample);
        end
        
        %% Plot only window selections within this epoch
        thisArguments = arguments;
        
        %% Plot only events within this epoch
        epochEv = get_event(data);
        if ~isempty(epochEv)
            
            evSel = physioset.event.sample_selector(firstSample:lastSample);
            
            thisEvents = select(evSel, epochEv);
            
            if ~isempty(thisEvents),
                thisEvents = shift(thisEvents, -firstSample+1);
                if downsamplingFactor > 1,
                    thisEvents = resample(thisEvents, 1, downsamplingFactor);
                end
                % The second argument to eeglab indicates that trial_begin
                % events should dealt with as if they were normal events
                % (i.e. no epoching should be performed).
                thisEvents = eeglab(thisEvents, false);
                thisArguments = [thisArguments, {'events', thisEvents}];
            end
        end
        
        %% Do the plotting
        tmp = get_config(obj, 'Plotter');
        
        if downsamplingFactor > 1,
            for i = 1:numel(thisEpoch)
                thisEpoch{i} = downsample(thisEpoch{i}', downsamplingFactor)';
            end
        end
        
        eegplotObj = plot(clone(tmp), thisEpoch{:}, thisArguments{:}, varargin{:});
        sensLabels = labels(sensors(data));
        set_sensor_labels(eegplotObj, [], sensLabels(chanIdx));
        scaleFactor = get_config(obj, 'ScaleFactor');
        set_scale(eegplotObj, [], get_scale(eegplotObj).*scaleFactor);
        
        badChan = is_bad_channel(data);
        badIdx  = find(badChan(chanIdx));
        
        % Bad channels will be plotted in red
        if ~isempty(badIdx),
            set_line_color(eegplotObj, badIdx, 'red');
        end
        
        %% Set up figure captions
        if isempty(groupNames{groupItr}),
            captions{groupItr}{epochItr} = ...
                sprintf('%s: %4.0f sec to %4.0f sec', ...
                groupNames{groupItr}, get_sampling_time(data, firstSample), ...
                get_sampling_time(data, lastSample));
        else
            captions{groupItr}{epochItr} = ...
                sprintf('%s: %4.0f sec to %4.0f sec', ...
                groupNames{groupItr}, get_sampling_time(data, firstSample), ...
                get_sampling_time(data, lastSample));
        end
        set(gcf, 'Name', captions{groupItr}{epochItr});
        set(gcf, 'Color', 'white');
        
        % Set the time properly
        epochTimes = get_sampling_time(data, firstSample:downsamplingFactor:lastSample);
        diffTimes  = epochTimes - round(epochTimes);
        tickPos    = find( diffTimes >= 0 & ...
            diffTimes < (downsamplingFactor/data.SamplingRate)*0.9);
        tickTimes  = epochTimes(tickPos);
        tickLabel = cell2ticks(num2strcell(round(tickTimes)));
        set_axes(eegplotObj, ...
            'XTick', tickPos, 'XTickLabel', tickLabel);
        
        %% Figure filename
        sensorGrpName = strrep(config.ChannelClass, '.', '-');
        if isempty(sensorGrpName), sensorGrpName = num2str(groupItr); end
        dataName = get_name(data);
        dataName = regexprep(dataName, '[^\w]+', '-');
        chanHash = DataHash(chanIdx);
        
        filename = sprintf('%s_%d%s_%d_%d_%s', dataName, ...
            size(thisEpoch{1},1), sensorGrpName, firstSample, ...
            lastSample, chanHash(1:8));
        
        fullFilename = catfile(config.Folder, [filename '.png']);
        fullFilename = unique_filename(fullFilename);
        [path, name] = fileparts(fullFilename);
        fullFilename = catfile(path, name);
        filename = name;
        
        %% Print figure in .svg format
        if get_config(obj, 'SVG'),
            
            evalc('plot2svg([fullFilename ''.svg''], gcf)');
            if ~strcmpi(computer, 'pcwin64'),
                svg2png([fullFilename '.svg'], []);
            else
                % Inkscape crashes when converting large .svg files to a
                % raster format under Windows 8.
                print('-dpng', [fullFilename '.png']);
            end
            figNames{groupItr}{epochItr} = [filename '.svg'];
            
        else
            
            figNames{groupItr}{epochItr} = [filename '.png'];
        end
        
        
        %% Print also other with other drivers
        printDrivers = get_config(obj, 'PrintDrivers');
        blackBgPlots = get_config(obj, 'BlackBgPlots');
        
        for i = 1:numel(printDrivers)
            
            thisDriver      = printDrivers{i};
            thisDriverFmt   = driver2format(thisDriver);
            print(['-d' thisDriver], fullFilename);
            extraPicCount   = extraPicCount + 1;
            thisImgFileName = [filename thisDriverFmt];
            figCap =  sprintf('%s (%s)', captions{groupItr}{epochItr}, ...
                thisDriverFmt);
            extra{groupItr}{extraPicCount}    = thisImgFileName;
            extraCap{groupItr}{extraPicCount} = figCap;
            
            %% Print also black pdf version
            if blackBgPlots,
                
                blackbg(eegplotObj);
                print(['-d' thisDriver], [fullFilename '-black']);
                extraPicCount = extraPicCount + 1;
                thisImgFileName = [filename '-black' thisDriverFmt];
                figCap  =  sprintf('%s (black, %s)', ...
                    captions{groupItr}{epochItr}, thisDriverFmt);
                extra{groupItr}{extraPicCount}    = thisImgFileName;
                extraCap{groupItr}{extraPicCount} = figCap;
                
            end
            
        end
        
    end
    
end

end

