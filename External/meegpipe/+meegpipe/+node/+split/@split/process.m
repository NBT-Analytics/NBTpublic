function [dataIn, dataOut] = process(obj, dataIn, varargin)
% PROCESS - Split into smaller physiosets
%
% See also: split


import mperl.file.spec.catfile;
import goo.globals;


MAX_SPLITS = 50;

eventSelector  = get_config(obj, 'EventSelector');
offset         = get_config(obj, 'Offset');
duration       = get_config(obj, 'Duration');
namingPolicy   = get_config(obj, 'SplitNamingPolicy');

verbose          = is_verbose(obj);
verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

ev = get_event(dataIn);

if ~isempty(eventSelector),
    ev = select(eventSelector, ev);
end

if isempty(ev),
    fprintf([verboseLabel ...
        'There are no split events: using whole-dataset split ...\n\n']);
end

if numel(ev) > MAX_SPLITS
    
    error('Too many (%d > %d) splits', numel(ev), MAX_SPLITS);
    
end

if verbose,
    fprintf([verboseLabel 'Splitting %s into %d subsets ...\n\n'], ...
        get_name(dataIn), numel(ev));
end

dataOut = cell(1, numel(ev));

splitCount = 0;

% A minimal report is generated always, regardless of the value of
% GenerateReport
rep = get_report(obj);
print_title(rep, 'Produced data splits', get_level(rep) + 1);

for i = 1:numel(ev)
    
    sample = get_sample(ev(i));
    if isempty(offset),
        off    = get_offset(ev(i));
    else
        off    = ceil(offset*dataIn.SamplingRate);
    end
    if isempty(duration),
        dur    = get_duration(ev(i));
    else
        dur    = ceil(duration*dataIn.SamplingRate);
    end
    
    splitName = namingPolicy(dataIn, ev(i), i);
    
    if isnan(splitName),
        % Splits with no known name are to be ignored. This is the way
        % users can provide specific information regarding what events
        % should be ignored for splitting purposes
        continue;
    end
    
    splitCount = splitCount + 1;
    
    fileName = catfile(get_full_dir(obj), ...
        [get_name(dataIn) '_' splitName]);
    
    % Just a precaution. The recording may be incomplete and not contain
    % all the data that we are expecting.
    if sample+off < 1,
        warning('split:MissingData', ...
            'Missing %d samples. Using new offset: %d samples.', ...
            abs(sample+off)+1, -sample+1);
        off = -sample+1;
    end
    if sample+off > size(dataIn, 2),
        warning('split:MissingData', ...
            ['Split onset (%d samples) is beyond data duration ' ...
            '(%d samples). Ignoring this data split.'], ...
            sample+off, size(dataIn, 2));
        continue;
    end
    
    % Some useful info about the split. At some point, this info should be
    % printed also to the report...
    [beginTime, beginTimeAbs] = get_sampling_time(dataIn,  sample+off);
    [endTime, endTimeAbs]     = get_sampling_time(dataIn,  sample+off+dur-1);
    
    beginTimeAbs = datestr(beginTimeAbs);
    endTimeAbs   = datestr(endTimeAbs);
    
    splitCharacteristics = [...
        sprintf('%30s : %.2f seconds\n', 'Start time (relative)', beginTime), ...
        sprintf('%30s : %.2f seconds\n', 'End time (relative)', endTime), ...
        sprintf('%30s : %s\n', 'Start time (absolute)', beginTimeAbs), ...
        sprintf('%30s : %s\n', 'End time (absolute)', endTimeAbs) ...
        ];
    
    eventCharacteristics = evalc('disp(ev(i))');
    
    if verbose,
        fprintf([verboseLabel 'Characteristics of split #%d (%s):\n\n'], ...
            i, [get_name(dataIn) '_' splitName]);
        fprintf(splitCharacteristics);
        fprintf('\n\n');
        fprintf([verboseLabel ...
            'Characteristics of splitting event %d/%d:\n\n'], i, numel(ev));
        fprintf(eventCharacteristics);
        fprintf('\n\n');
    end
 
    dataOut{splitCount}  = subset(dataIn, 1:nb_dim(dataIn), ...
        sample+off:sample+off+dur-1, ...
        'FileName', fileName, ...
        'Temporary', true);
    
    set_name(dataOut{splitCount}, [get_name(dataIn) '_' splitName]);
    save(dataOut{splitCount});

    % Print split information also to the HTML reports
    repTitle = sprintf('Split %s', get_name(dataOut{splitCount}));
    splitRep = report.generic.new('Title', repTitle);
    splitRep = childof(splitRep, rep);
    initialize(splitRep);
    
    print_link2report(rep, splitRep);
    
    print_title(splitRep, 'Split characteristics', get_level(rep) + 1);
    
    print_paragraph(splitRep, report.disp2table(splitCharacteristics));
    
    print_title(splitRep, 'Splitting event characteristics', ...
        get_level(rep) + 1);
    
    print_paragraph(splitRep, report.disp2table(eventCharacteristics)); 
    
    % Print a link to the binary data file
    set_method_config(dataOut{splitCount}, 'fprintf', 'ParseDisp', true);
    set_method_config(dataOut{splitCount}, 'fprintf', 'SaveBinary', true);
    print_title(splitRep, 'Splitted physioset', get_level(rep) + 1);
    fprintf(splitRep, dataOut{splitCount});

    if verbose,
        fprintf([verboseLabel 'Created %s ...\n\n'], ...
            get_datafile(dataOut{splitCount}));
    end
    
end
dataOut(splitCount+1:end) = [];

if numel(dataOut) == 1,
    dataOut = dataOut{1};
end

%% Undo stuff
globals.set('VerboseLabel', origVerboseLabel);


end