function [featNames, featM] = generate_spectra_topos(obj, rep, plotterObj, data)

import report.gallery.gallery;

verbose      = goo.globals.get.Verbose;
verboseLabel = goo.globals.get.VerboseLabel;

% We need to get the spectral features for each channel, or at least for as
% many channels as possible. 
singleChanSets = labels(sensors(data));

% Search for maching sensor sets
spectraSens = cellfun(@(x) labels(x), obj.SpectraSensors, ...
    'UniformOutput', false);

isSingleSensor = cellfun(@(x) iscell(x) && numel(x) == 1, spectraSens);
idxSingleSensor = find(isSingleSensor);

if isempty(idxSingleSensor) 
    if verbose,
    fprintf([verboseLabel 'none generated']);
    end
    return;
end

singleSensorLabels = cellfun(@(x) x{1}, spectraSens(isSingleSensor), ...
    'UniformOutput', false);

[~, chanSetIdx] = ismember(singleChanSets, singleSensorLabels);

% The set of channels for which we actually have computed the features
sens = subset(sensors(data), chanSetIdx > 0);

% And the corresponding features
chanSetIdx(chanSetIdx < 1) = [];


% And the channel set indices that correspond to those channels
chanSetIdx = idxSingleSensor(chanSetIdx);

if isempty(chanSetIdx) 
    if verbose,
    fprintf([verboseLabel 'none generated']);
    end
    return;
end

feat = obj.SpectraFeatures(chanSetIdx);

% Make feat become a KxM matrix with M features for K sensors
featNames = keys(feat{1});
featM = nan(sens.NbSensors, numel(featNames));
for i = 1:sens.NbSensors
    for j = 1:numel(featNames)
       featM(i, j) = feat{i}(featNames{j}); 
    end
end

% Generate a topomap for each feature
repTitle = 'Topograhies for each spectral feature';

plotter = spt.plotter.topography.new('Plotter', clone(plotterObj));

topoRep  = report.plotter.new(...
    'Plotter',  plotter, ...
    'Gallery',  gallery('NoLinks', true), ...
    'Title',    repTitle);

topoRep = embed(topoRep, rep);

generate(topoRep, sens, featM, featNames);

% Create a log file for each topography
sensLabels = labels(sens);

print_title(rep, 'Raw topography values', get_level(rep) + 1);


for i = 1:numel(featNames)
    logFile = [genvarname(featNames{i}) '.txt'];
    if verbose,
        fprintf([verboseLabel, ...
            'Saving spectral topograhies to %s ...'], logFile);
    end
    fid = get_log(obj, logFile);
    % Print a header and the data values
    formatStr = repmat('%s,', 1, size(featM,1));
    formatStr = [formatStr(1:end-1) '\n'];
    fprintf(fid, formatStr, sensLabels{:});
    formatStr = repmat('%5.3f,', 1, numel(sensLabels));
    formatStr =[formatStr(1:end-1) '\n'];    
    fprintf(fid,formatStr, featM(:, i));   
    
    print_paragraph(rep, '[%s][%s]', logFile, logFile);
    print_link(rep, ['../' logFile], logFile);
    
    if verbose,
        fprintf('[done]\n\n');
    end   
end



end