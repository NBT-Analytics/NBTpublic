function [figNames, captions, groups, extra, extraCap] = ...
    plot(obj, sensors, data, dataName)
% PLOT - Plots Topographies
%


import physioset.plotter.default_channel_groups;
import mperl.file.spec.catfile;
import mperl.join;
import plotter.driver2format;
import misc.unique_filename;

%% Error checking
if ~ismember(class(sensors), {'sensors.eeg', 'sensors.meg'})
    error('SENSORS must be of class sensors.eeg or sensors.meg');
end

if ~isnumeric(data) && ~isa(data, 'spt.spt'),
   error('DATA must be a numeric matrix or a spt.spt object'); 
end

% For convenience
config = get_config(obj);
if isempty(config.Folder),
    config.Folder = pset.session.instance.Folder;
end

if (nargin < 4 || isempty(dataName))
    if isnumeric(data),
        dataName = repmat({'unknown'}, 1, size(data, 2));
    else
        selIdx = selection(data);
        dataName = num2cell(1:numel(selIdx));
        dataName = cellfun(@(x) [sptType ' ' num2str(x)], dataName, ...
            'UniformOutput', false);
        data = bprojmat(data);
    end
end

if ischar(dataName), dataName = {dataName}; end

if numel(dataName) == 1 && size(data, 2) > 1,
    dataName = repmat(dataName, 1, size(data, 2));
end

%% Initialize the output arguments
figNames    = cell(size(data, 2), 1);
captions    = cell(size(data, 2), 1);
extra       = cell(size(data, 2)*2, 1);
extraCap    = cell(size(data, 2)*2, 1);

sensorType  = upper(regexprep(class(sensors), 'sensors.', ''));
groups{1}   = sprintf('%s topography', sensorType);


extraPicCount = 0;

for topoItr = 1:size(data, 2)
    
    thisTopo = data(:, topoItr);
    
    % Plot the topography
    hF = plot(clone(config.Plotter), sensors, thisTopo);
    
    % Set up figure captions
    captions{topoItr} = dataName{topoItr};
    
    % Set up a relevant file name for the printed figure
    thisDataName = regexprep(dataName{topoItr}, '[^\w]+$', '');
    thisDataName = regexprep(thisDataName, '[^\w]+', '-');
    fullFilename = catfile(config.Folder, thisDataName);
    [~, filename] = fileparts(unique_filename([fullFilename, '.png']));
    fullFilename = catfile(config.Folder, filename);
    
    %% Print figure in .png format   
    res = num2str(get_config(obj, 'Resolution'));
    print('-dpng', fullFilename, ['-r' res]);
    figNames{topoItr} = [filename '.png'];    
    
    %% Print also other with other drivers
    printDrivers = get_config(obj, 'PrintDrivers');
    blackBgPlots = get_config(obj, 'BlackBgPlots');
    for i = 1:numel(printDrivers)
        thisDriver      = printDrivers{i};
        thisDriverFmt   = driver2format(thisDriver);
        print(['-d' thisDriver], fullFilename, ['-r' res]);
        extraPicCount   = extraPicCount + 1;
        thisImgFileName = [filename thisDriverFmt];
        figCap =  sprintf('%s (%s)', captions{topoItr}, ...
            thisDriverFmt);
        extra{topoItr}{extraPicCount}    = thisImgFileName;
        extraCap{topoItr}{extraPicCount} = figCap;
        
        %% Print also black pdf version
        if blackBgPlots,
            blackbg(hF);
            print(['-d' thisDriver], [fullFilename '-black'], ['-r' res]);
            extraPicCount = extraPicCount + 1;
            thisImgFileName = [filename '-black' thisDriverFmt];
            figCap  =  sprintf('%s (black, %s)', ...
                captions{topoItr}, thisDriverFmt);
            extra{topoItr}{extraPicCount}    = thisImgFileName;
            extraCap{topoItr}{extraPicCount} = figCap;
        end
    end
    clear hF;
    
end % end of sensor groups iterator

% There is only one group
figNames = {figNames};
captions = {captions};
extra    = {extra};
extraCap = {extraCap};

end