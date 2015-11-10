function [data, dataNew] = process(obj, data, varargin)

import misc.isinteger;

dataNew = [];

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);


% Configuration options
targetSelector  = get_config(obj, 'TargetSelector');
firstLevel      = get_config(obj, 'FirstLevel');
secondLevel     = get_config(obj, 'SecondLevel');
featNames       = get_config(obj, 'FeatureNames');
auxVars         = get_config(obj, 'AuxVars');
plotterArray    = get_config(obj, 'Plotter');


if isempty(firstLevel),
    warning('generic_features:NoFeatures', ...
        'No description available for first level features: doing nothing');
    rep = get_report(obj);
    print_paragraph(rep, ...
        'This node did nothing because property FirstLevel is empty');
    return;
end

firstLevelFeats = cell(numel(firstLevel), numel(targetSelector));

selectionEvents = cell(1, numel(targetSelector));

for targetItr = 1:numel(targetSelector)
    
    thisSel = targetSelector{targetItr};
    
    % selectionEvents is only relevant for event_selector selectors
    [~, emptySel, selectionEvents{targetItr}] = select(thisSel, data);
    
    if emptySel, continue; end
    
    % Compute auxiliary variables, if needed
    if ~isempty(auxVars),
       auxVarsValues = cell(1, numel(auxVars));
       for i = 1:numel(auxVars)
           auxVarsValues{i} = auxVars{i}(data, ...
               selectionEvents{targetItr}, thisSel);
       end
    else
        auxVarsValues = {};
    end
    
    for featItr = 1:numel(firstLevel)
        
        firstLevelFeats{featItr, targetItr} = firstLevel{featItr}(data, ...
            selectionEvents{targetItr}, thisSel, auxVarsValues{:});
        
    end
    
    restore_selection(data);
    
end


% Write features to log file
if verbose,
    fprintf([verboseLabel 'Writing event features to features.txt ...']);
end
fid = get_log(obj, 'features.txt');
if isempty(secondLevel),
    
    % Write:
    % feat1, feat2, feat3, ...
    % X, Y, Z  -> first selector
    % V, W, M  -> second selector
    % ....
    % In this case, featNames is assumed to refer to first-level features, 
    % which are assumed to be numeric, for simplicity
    hdr = ['selector,' repmat('%s,',1, numel(featNames))];
    hdr(end:end+1) = '\n';
    fprintf(fid, hdr, featNames{:});
    fmt = '%s,'; 
    
    for i = 1:numel(featNames),
       if ischar(firstLevelFeats{i, 1}),
           fmt = [fmt '%s,'];  %#ok<*AGROW>
       elseif isinteger(firstLevelFeats{i, 1})
           fmt = [fmt '%d,'];
       elseif isnumeric(firstLevelFeats{i, 1}),
           fmt = [fmt '%.4f,'];
       else
          error('Feature values must be numeric scalars or strings'); 
       end
        
    end
 
    fmt(end:end+1) = '\n';
    for i = 1:numel(targetSelector)
        
        if all(cellfun(@(x) isempty(x), firstLevelFeats(:,i))),
            continue;
        end
        fprintf(fid, fmt, get_name(targetSelector{i}), ...
            firstLevelFeats{:, i});
    end    
    
else
    % Aggregate features across selectors
    % Write:
    % feat1, feat2
    % X, Y
    
    featVals = cell(1, numel(secondLevel));
    
    for i = 1:numel(featVals),
        featVals{i} = secondLevel{i}(firstLevelFeats, ...
            selectionEvents, targetSelector);
    end
    hdr = repmat('%s,',1, numel(featNames));
    hdr(end) = [];    
    fprintf(fid, [hdr '\n'], featNames{:});
    
    fmt = '';
    for i = 1:numel(featVals),
        if isinteger(featVals{i}),
            fmt = [fmt '%d,'];
        elseif isnumeric(featVals{i}),
            fmt = [fmt '%.4f,'];
        elseif ischar(featVals{i}),
            fmt = [fmt '%s,'];
        else
            error('Features must be numeric scalars or strings');
        end
    end
    fmt(end:end+1) = '\n';
    fprintf(fid, fmt, featVals{:});
    
end

rep = get_report(obj);
print_title(rep, 'Feature extraction report', get_level(rep) + 1);
print_paragraph(rep, 'Extracted features: [features.txt][feat]');
print_link(rep, '../features.txt', 'feat');

if verbose, fprintf('[done]\n\n'); end

if do_reporting(obj),
 
    % Run all the plotters
    for i = 1:numel(plotterArray),

        thisPlotter = plotterArray{i};
        
        if is_verbose(obj),
            fprintf([verboseLabel 'Running plotter %d (%s) ...'], ...
                i, class(thisPlotter));
        end        
        
        plotterRep = report.plotter.plotter('Plotter', thisPlotter);
        
        plotterRep = embed(plotterRep, rep);
        
        generate(plotterRep, data);
        
        if is_verbose(obj),
            fprintf('[done]\n\n');
        end
        
    end
    
end


end