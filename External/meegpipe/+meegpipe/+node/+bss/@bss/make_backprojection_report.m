function make_backprojection_report(obj, myBSS, ics, rep, verbose, verboseLabel)

selectedSPCs = component_selection(myBSS);

if isempty(selectedSPCs), return; end

if verbose
    fprintf( [verboseLabel, '\tBackprojecting selected SPCs...']);
end

selICs = bproj(myBSS, ics);

%% Snapshots of top-variance channels
print_title(rep, 'Backprojected SPCs', get_level(rep) + 1);

dataVar = var(selICs, 0, 2);

[~, chanIdx] = sort(dataVar, 'descend');

snapshotPlotter = physioset.plotter.snapshots.new(...
    'MaxChannels',  Inf, ...
    'WinLength',    [10 25], ...
    'NbBadEpochs',  0, ...
    'NbGoodEpochs', 3);

snapshotsRep = report.plotter.new(...
    'Plotter',  snapshotPlotter, ...
    'Title',    'Time-course at top-variance channels');

print_title(rep, 'Time-course at top-variance channels', get_level(rep) + 2);

chanIdx = sort(chanIdx(1:min(size(selICs,1), 5)), 'ascend');
select(selICs, chanIdx);
generate(embed(snapshotsRep, rep), selICs);
restore_selection(selICs);

%% PSDs of top-variance channels

% This will ensure that one plot will be generated for each top-var chan
myPlotter = get_config(obj, 'PSDPlotter');
set_config(myPlotter, 'Channels', {1:numel(chanIdx)});

psdRep = report.plotter.new(...
    'Plotter',  myPlotter, ...
    'Title',    'PSD across top-variance channels');

print_title(rep, 'PSD across top-variance channels', get_level(rep) + 2);

select(selICs, chanIdx);
generate(embed(psdRep, rep), selICs);
restore_selection(selICs);


%% Power topograhy for the selected components

print_title(rep, 'Power topography and average SPC topography', get_level(rep) + 2);
[sensorArray, sensorIdx] = sensor_groups(sensors(selICs));

% The full back-projection matrix
A = bprojmat(myBSS, true);

for i = 1:numel(sensorArray),
    
    if numel(sensorIdx{i}) < 2,
        continue;
    end
    
    sensorClass = regexprep(class(sensorArray{i}), '^sensors\.', '');
    sensorClass = upper(sensorClass);
    
    if ~ismember(sensorClass, {'EEG', 'MEG'}),
        continue;
    end
    
    thisSensors = subset(sensors(selICs), sensorIdx{i});
    
    if any(any(isnan(cartesian_coords(thisSensors)))),
        warning('bss_regr:MissingCoordinates', ...
            'Missing sensor coordinates: skipping topographies');
        continue;
    end
    
    repTitle = sprintf('%s power topographies (channels %d-%d)', ...
        sensorClass, sensorIdx{i}(1), sensorIdx{i}(end));
    topoRep = report.plotter.new(...
        'Plotter',  get_config(obj, 'TopoPlotter'), ...
        'Gallery',  report.gallery.new('NoLinks', true),  ...
        'Title',    repTitle);
    
    topoRep = embed(topoRep, rep);
    
    topoName = {...
        'Joint power topography of selected SPCs', ...
        'Joint power-weighted average SPC topography', ...
        };
    
    
    topoVals = [dataVar(sensorIdx{i}), sum(A(sensorIdx{i}, selectedSPCs), 2)];
    
    generate(topoRep, thisSensors, topoVals, topoName);
    
    if verbose, fprintf('.'); end
    
end

if verbose, fprintf('\n\n'); end


end