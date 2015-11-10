function [figNames, captions, groups, extra, extraCap] = plot(obj, data, varargin)
% PLOT - Plots Power Spectral Densities
%
% import pset.plotter.psd;
% session.instance('D:/tmp');
% myData = import(physioset.import.mff,'bcgs_0001.mff');
% myPlotter = pset.plotter.psd;
% figNames = plot(myPlotter, myData);
%
% Where
%
% DATA is a physioset object
%
% FIGNAMES is a cell array of strings that contains the names of the
% generated figures
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
% See also: pset.plotter.psd, pset.plotter.config.psd


import physioset.plotter.default_channel_groups;
import mperl.file.spec.catfile;
import mperl.join;
import plotter.driver2format;
import plot2svg.plot2svg;
import goo.pkgisa;
import goo.globals;
import pset.session;
import misc.legend2location;
import inkscape.svg2png;
import misc.unique_filename;
import misc.exception2str;

%% Error checking
if ~pkgisa(data, 'physioset'),
    error('DATA must be a physioset object');
end

verbose             = is_verbose(obj);
verboseLabel        = get_verbose_label(obj);
origVerboseLabel    = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

% For convenience
config = get_config(obj);
if isempty(config.Folder),
    config.Folder = session.instance.Folder;
end

origEstimator = config.Estimator;
if isa(origEstimator, 'function_handle'),
    estimator = origEstimator(data.SamplingRate, nb_pnt(data));
else
    estimator = origEstimator;
end

%% Call recursively for multiple estimators
if numel(estimator) > 1,
    figNames    = [];
    groups      = [];
    captions    = [];
    extra       = [];
    extraCap    = [];
    for i = 1:numel(estimator)
        set_config(obj, 'Estimator',  estimator{i});
        [thisH, thisGroups, thisCaptions, thisExtra, thisExtraCap] = ...
            plot(thisObj, data, varargin{:});
        figNames    = [figNames;thisH(:)]; %#ok<*AGROW>
        groups      = [groups;thisGroups(:)];
        captions    = [captions;thisCaptions(:)];
        extra       = [extra; thisExtra];
        extraCap    = [extra; thisExtraCap(:)];
    end
    % Set the configuration back to its original state
    set_config(obj, 'Estimator', origEstimator);
    return;
end

%% Define meaningful channel groups
% This will omit bad channels as well as channels of the wrong class/type
if isempty(config.Channels),
    [config.Channels, config.ChannelClass, config.ChannelType] = ...
        default_channel_groups(data, ...
        config.MaxChannels, ...
        config.ChannelClass, ...
        config.ChannelType);
end

%% Define meaningfull data epochs
% This will omit bad samples
if isempty(config.Windows)
    config.Windows = default_window_selection(data, ...
        config.MaxWindows, ...
        config.WinLength);
end


%% Initialize the output arguments
figNames    = cell(numel(config.Channels), 1);
captions    = cell(numel(config.Channels), 1);
extra       = cell(numel(config.Channels)*2, 1);
extraCap    = cell(numel(config.Channels)*2, 1);
if size(config.Windows,1) > 1 && any(cellfun(@(x) numel(x) > 1, config.Channels)),
    groups{1}   = sprintf('%s across time/space', class(estimator));
elseif size(config.Windows,1) == 1,
    groups{1}   = sprintf('%s across space', class(estimator));
else
    groups{1}   = sprintf('%s across time', class(estimator));
end

extraPicCount = 0; 
groupCount    = 0;
for chanGrpIdx = 1:numel(config.Channels)
    %% Pick relevant data and format appropriately for data plotter
    chanIdx = config.Channels{chanGrpIdx};
    chanClass = config.ChannelClass;
    if isempty(chanClass),
        chanClass = 'unknown';
    elseif iscell(chanClass),
        chanClass = chanClass{chanGrpIdx};
    else
        error('Something is wrong');
    end
    
    % Do not do anything about the bad samples here. It will be taken care
    % of within function make_psd_plot() below
    dataCell = cell(nargin -1, 1);
 
    dataCell{1} = data(chanIdx, :);
    
    for i = 1:numel(varargin)
        
        dataCell{i+1} = varargin{i}(chanIdx, :);
        
    end
    
    
    if verbose,
        fprintf([verboseLabel 'PSDs for %s signal group ...'], chanClass);
    end

    %% Ugly but easy way to cope with the limitations of spectrum.* classes
    hF = clone(config.Plotter);
    hF = plot_dataset(hF, dataCell, data.SamplingRate, estimator, ...
        config.Windows, config.Args{:});    
    if isempty(hF)
        if verbose,
            fprintf('[failed]\n\n');
        end
        continue;        
    end
    
    if verbose,
        fprintf('\n\n');
    end
    
    groupCount = groupCount + 1;
    
    %% Set up figure captions
    if numel(chanIdx) > 1,
        captions{groupCount} = sprintf(...
            '%s : %d %s channel(s)', ...
            groups{1}, numel(chanIdx), chanClass);
    else
        if numel(chanIdx) < 10,
            chanList = regexprep(num2str(chanIdx), '\s+', ', ');
        else
            chanIdx1 = chanIdx(1:5);
            chanIdx2 = chanIdx(end-4:end);
            chanList = [regexprep(num2str(chanIdx1), '\s+', ', ') ' ... ' ...
                regexprep(num2str(chanIdx2), '\s+', ', ')];
        end
        captions{groupCount} = sprintf('%s : signal %s', ...
            groups{1}, chanList);
    end
    % Add also info about the type of sensors.
    if ~isempty(config.ChannelType) && ...
            numel(config.ChannelType{chanGrpIdx}) < 50,
        captions{groupCount} = sprintf('%s of type(s) %s', ...
            captions{groupCount}, config.ChannelType{chanGrpIdx});
    end
    
    %% Set up a relevant file name for the printed figure
    if ~isempty(config.ChannelClass),
        sensorGrpName = [...
            strrep(config.ChannelClass{chanGrpIdx}, '.', '-') ...
            num2str(chanGrpIdx)];
    else
        sensorGrpName = num2str(chanGrpIdx);
    end
    estimatorName = strrep(class(estimator), '.', '-');
    dataName = regexprep(get_name(data), '[^\w]+', '-');    
    filename = sprintf('%s_%s_psd_%s', dataName, estimatorName,...
        sensorGrpName);
    fullFilename = unique_filename(catfile(config.Folder, [filename '.png']));
    [path, filename] = fileparts(fullFilename);
    fullFilename = catfile(path, filename);
    
    %% Print figure in .svg format    
    if get_config(obj, 'SVG'),
        %legend2location('NorthEastOutside');
        evalc('plot2svg([fullFilename ''.svg''], gcf)');
        figNames{groupCount} = [filename '.svg'];
    else        
        figNames{groupCount} = [filename '.png'];
    end
    
    %% .png format is needed always for thumbnail generation
    %     if usejava('Desktop'),
    %         print('-dpng', fullFilename, '-r600');
    %     else
    % MATLAB renderers that are available during terminal emulation suck a
    % lot. We use an indirect route to be able to generate a high quality
    % .png in this case: (1) generate a pdf, (2) convert to .png using
    % inkscape
    [path, name] = fileparts(fullFilename);
    tmpPdfFile = [catfile(path, name) '.pdf'];
    try
        print('-dpdf', tmpPdfFile);
        svg2png(tmpPdfFile, [], 300); % maybe I should rename this function...
        delete(tmpPdfFile);
    catch ME
        exception2str(ME);
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
        figCap =  sprintf('%s (%s)', captions{groupCount}, ...
            thisDriverFmt);
        extra{groupCount}{extraPicCount}    = thisImgFileName;
        extraCap{groupCount}{extraPicCount} = figCap;
        
        %% Print also black pdf version
        if blackBgPlots,
            blackbg(hF);
            print(['-d' thisDriver], [fullFilename '-black']);
            extraPicCount = extraPicCount + 1;
            thisImgFileName = [filename '-black' thisDriverFmt];
            figCap  =  sprintf('%s (black, %s)', ...
                captions{groupCount}, thisDriverFmt);
            extra{groupCount}{extraPicCount}    = thisImgFileName;
            extraCap{groupCount}{extraPicCount} = figCap;
        end
    end
    
end % end of sensor groups iterator

figNames(groupCount+1:end) = [];
captions(groupCount+1:end) = [];

% There is only one group
figNames = {figNames};
captions = {captions};
extra    = {extra};
extraCap = {extraCap};

globals.set('VerboseLabel', origVerboseLabel);

end