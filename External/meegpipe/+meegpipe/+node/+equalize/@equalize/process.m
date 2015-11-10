function [data, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

refSelector = get_config(obj, 'RefSelector');


if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating before-equalization report...']);
    end
    
    rep = get_report(obj);
    print_title(rep, 'Operator report', get_level(rep)+1);
    
    print_title(rep, 'Before operator', get_level(rep)+2);
    
    % Plot some snapshots
    snapshotPlotter = snapshots('WinLength', 10);
    
    plotterRep = report.plotter.plotter('Plotter', snapshotPlotter);
    
    plotterRep = embed(plotterRep, rep);
    
    generate(plotterRep, data);
    
    if is_verbose(obj),
        fprintf('[done]\n\n');
    end
    
end


if verbose, 
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Equalizing %s ...'], fname);
end

if isempty(refSelector),
   refVar = 1;
else
    select(refSelector, data);
    refVar = median(var(data, [], 2));
    restore_selection(data);
end

[~, sensIdx] = sensor_groups(sensors(data));
for i = 1:numel(sensIdx)
    select(data, sensIdx{i});
    thisVar = median(var(data, [], 2));
    if thisVar > 1e-50,
        gain = sqrt(refVar/thisVar);
        data = gain*data;
    end
    restore_selection(data);
end


if verbose, fprintf('[done]\n\n'); end

if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating after-equalization report...']);
    end
    
    rep = get_report(obj);
    print_title(rep, 'After operator', get_level(rep)+2);
    
    % Plot some snapshots
    snapshotPlotter = snapshots('WinLength', 10);
    
    plotterRep = report.plotter.plotter('Plotter', snapshotPlotter);
    
    plotterRep = embed(plotterRep, rep);
    
    generate(plotterRep, data);
    
    if is_verbose(obj),
        fprintf('[done]\n\n');
    end
    
end



end