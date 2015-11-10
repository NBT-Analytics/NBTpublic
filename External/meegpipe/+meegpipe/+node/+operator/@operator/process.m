function [data, dataNew] = process(obj, data, varargin)

import physioset.plotter.snapshots.snapshots;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

operator = get_config(obj, 'Operator');


if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating before-operator report...']);
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
    fprintf([verboseLabel 'Applying operator %s on ''%s''...'], ...
        char(operator), fname);
    
end

operator(data);

if verbose, fprintf('[done]\n\n'); end

if do_reporting(obj),
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Generating after-operator report...']);
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