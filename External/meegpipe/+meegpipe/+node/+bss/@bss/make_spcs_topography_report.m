function make_spcs_topography_report(obj, myBSS, ics, data, rep, maxVar, ...
        maxAbsVar, verbose, verboseLabel)

if verbose
    fprintf( [verboseLabel, '\tGenerating SPCs topographies...']);
end

if get_config(obj, 'Reject'),
    rejStr = ' (REJECTED)';
else
    rejStr = ' (ACCEPTED)';
end

selectedSPCs = component_selection(myBSS);

[sensorArray, sensorIdx] = sensor_groups(sensors(data));

% The full back-projection matrix (including non-selected components)
A = bprojmat(myBSS, true);

icLabels = labels(sensors(ics));

for i = 1:numel(sensorArray),
    
    sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
    sensorClass = upper(sensorClass);
    
    if ~ismember(sensorClass, {'EEG', 'MEG'}) || numel(sensorIdx{i}) < 2,
        continue;
    end
    
    topoNames = num2cell((1:size(A,2))');
    
    for k = 1:numel(topoNames)
        topoNames{k} = sprintf('SPC %s backproject on sensor set %d', ...
            icLabels{k}, i);
        topoNames{k} = sprintf(...
            '%s (max rel. var=%d%%; max abs. log-var=%d dB) ', ...
            topoNames{k}, ...
            round(maxVar(k)), ...
            round(maxAbsVar(k)));
        if ismember(k, selectedSPCs),
            topoNames{k} = [topoNames{k} rejStr];
        end       
    end
    
    thisSensors = subset(sensors(data), sensorIdx{i});
    
    if any(any(isnan(cartesian_coords(thisSensors)))),
        warning('bss:MissingCoordinates', ...
            'Missing sensor coordinates: skipping topographies');
        continue;
    end
    
    repTitle = sprintf('%s topographies (channels %d-%d)', ...
        sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
    
    topoRep = report.plotter.new(...
        'Plotter',  get_config(obj, 'TopoPlotter'), ...
        'Gallery',  report.gallery.new('NoLinks', true),  ...
        'Title',    repTitle);
    
    topoRep = embed(topoRep, rep);
    
    print_title(rep, 'SPCs topographies', get_level(rep) + 1);
    
    generate(topoRep, thisSensors, A(sensorIdx{i}, :), topoNames);
    
    if verbose, fprintf('.'); end
    
end
if verbose, fprintf('[done]\n\n'); end
