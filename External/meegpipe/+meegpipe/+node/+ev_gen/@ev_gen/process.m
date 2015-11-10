function [data, dataNew] = process(obj, data, varargin)

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

if verbose,
    
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Generating events ...\n\n'], fname);
    
end

evGen        = get_config(obj, 'EventGenerator');
plotterArray = get_config(obj, 'Plotter');

evLogName = [get_name(data) '_events.txt'];
rep = get_report(obj);
print_title(rep, 'Events generation report', get_level(rep) + 1);
print_paragraph(rep, 'List of generated events: [%s][evlog]', ...
    evLogName);
print_link(rep, ['../' evLogName], 'evlog');


if do_reporting(obj),
    rep = get_report(obj);
else
    rep = [];
end
evArray = generate(evGen, data, rep, varargin{:});

if verbose,
    fprintf([verboseLabel 'Generated %d events ...\n\n'], numel(evArray));
end

if isempty(evArray), return; end

add_event(data, evArray);

if verbose,
    fprintf([verboseLabel ...
        'Writing events properties to log file %s ...'], ...
        evLogName);
end

fid = get_log(obj, evLogName);
fprintf(fid, evArray);

if verbose, fprintf('[done]\n\n'); end

if do_reporting(obj),
    
    print_title(rep, 'Event generation report', get_level(rep)+1);
    
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