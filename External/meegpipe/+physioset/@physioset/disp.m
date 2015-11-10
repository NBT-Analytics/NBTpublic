function disp(obj)

import misc.join;

if usejava('Desktop'),
    disp(['<a href="matlab:help physioset.>physioset./a> ' ...
        '<a href="matlab:help handle">handle</a>']);
    disp('Package: <a href="matlab: help physioset">physioset</a>');
else
    disp('handle');
    disp('Package: physioset');
end

fprintf('\n\n');

fprintf('%20s : %s\n', 'Name', get_name(obj));

% Note: We do not use get_event(obj) because that can get terribly slow in
% the presence of data selections (which require the recomputation of event
% sample times). This works because get_msg_event does not display any info
% on the sample positions of the events.
fprintf('%20s : %s\n', 'Event',          get_msg_event(obj.Event));
fprintf('%20s : %s\n', 'Sensors',        get_msg_sensors(sensors(obj)));
fprintf('%20s : %d Hz\n', 'SamplingRate', obj.SamplingRate);
fprintf('%20s : %s\n', 'Samples',        get_msg_nbpoints(obj));

if ~isempty(obj.PntSelection)
    fprintf('%20s : %s\n', 'SamplesSelection',  get_msg_nbpoints(obj, true));
end

fprintf('%20s : %s\n', 'Channels', 	     get_msg_nbdims(obj));

if ~isempty(obj.DimSelection)
    fprintf('%20s : %s\n', 'ChannelsSelection',  get_msg_nbdims(obj, true));
end

if ~isempty(obj.DimMap),
    str = sprintf('[%dx%d double]', size(obj.DimMap,1), size(obj.DimMap,2));
    fprintf('%20s : %s\n', 'SpatialProjection',  str);
end

fprintf('%20s : %s\n', 'StartTime',      get_msg_starttime(obj));

fprintf('%20s : %s\n', 'Equalization',   get_msg_eq(obj));
fprintf('%20s : %s\n', 'Reference',      get_msg_ref(obj));


if ~isempty(get_meta(obj)),
    fprintf('\nMeta properties:\n\n');
    disp_meta(obj);
end

fprintf('\n');

end


function msg = get_msg_ref(obj)
import meegpipe.node.*;

if isempty(obj.RerefMatrix),
    msg = 'raw';
else
    msg = 'user provided';
end


end



function msgEvent = get_msg_event(events)
import misc.join;

if isempty(events),
    msgEvent = '[]';
    return;
end

if numel(events) < 10000,
    types = unique(events);
    
    if ischar(types), types = {types}; end
    nbTypes = numel(types);
    if nbTypes > 1,
        if iscell(types),
            typesDescr = join(', ', types);
        elseif isnumeric(types),
            typesDescr = regexprep(num2str(types(:)'), '\s+', ', ');
        else
            error('Something is wrong!');
        end
    elseif nbTypes == 1,
        typesDescr = ['' types{1} ''];
    end
    if numel(typesDescr) > 15,
        idx = strfind(typesDescr, ',');
        if ~isempty(idx),
            idx = idx(find(idx>15, 1));
        end
        if isempty(idx),
            idx = min(27, numel(typesDescr));
        end
        typesDescr = [typesDescr(1:idx) '...'];
    end
    
    if nbTypes == 1,
        msgEvent = sprintf('%d event(s) of type ''%s''', ...
            numel(events), typesDescr);
    elseif nbTypes > 1,
        msgEvent = sprintf('%d events of %d types (%s)', ...
            numel(events), nbTypes, typesDescr);
    end
    
else
    
    msgEvent = sprintf('%d events', numel(events));
    
end

end



function msgSensors = get_msg_sensors(sensObj)

if isempty(sensObj),
    msgSensors = '[]';
    return;
end

[grps, idx] = sensor_groups(sensObj);

msgSensors = '';
for grpIdx = 1:numel(grps)
    if usejava('Desktop'),
        sensorClass = sprintf('<a href="matlab:help %s">%s</a>; ', ...
            class(grps{grpIdx}), class(grps{grpIdx}));
    else
        sensorClass = class(grps{grpIdx});
    end
    msgSensors = [msgSensors sprintf('%d %s', numel(idx{grpIdx}), sensorClass)];  %#ok<AGROW>
end

end



function msgNbPoints = get_msg_nbpoints(obj, flag)

if obj.NbPoints < 1,
    msgNbPoints = '0';
    return;
end

if nargin < 2 || isempty(flag),
    flag = false; % Original or Selection?
end


if flag
    nbBad = numel(find(is_bad_sample(obj)));
    msgNbPoints = sprintf('%d (%5.1f seconds), %d bad samples (%2.1f%%)', ...
        nb_pnt(obj), ...
        nb_pnt(obj)/obj.SamplingRate, ...
        nbBad, ...
        100*nbBad/nb_pnt(obj));
else
    nbBad = numel(find(obj.BadSample));
    msgNbPoints = sprintf('%d (%5.1f seconds), %d bad samples (%2.1f%%)', ...
        obj.PointSet.NbPoints, ...
        obj.PointSet.NbPoints/obj.SamplingRate, ...
        nbBad, ...
        100*nbBad/obj.PointSet.NbPoints);
    
end

end

function msgNbDims = get_msg_nbdims(obj, flag)

if obj.NbDims < 1,
    msgNbDims = '0';
    return;
end
if nargin < 2 || isempty(flag),
    flag = false; % Original or Selection?
end


if flag,
    nbBad = numel(find(is_bad_channel(obj)));
    msgNbDims = sprintf('%d, %d bad channels (%2.1f%%)', ...
        nb_dim(obj), ...
        nbBad, ...
        100*nbBad/nb_dim(obj));
else
    nbBad = numel(find(obj.BadChan));
    msgNbDims = sprintf('%d, %d bad channels (%2.1f%%)', ...
        obj.PointSet.NbDims, ...
        nbBad, ...
        100*nbBad/obj.PointSet.NbDims);
end

end

function msgStartTime = get_msg_starttime(obj)

msgStartTime = datestr(obj.TimeOrig, 'dd-mm-yyyy HH:MM:SS:FFF');

end

function msgEq = get_msg_eq(obj)

if obj.NbDims < 1,
    msgEq = 'n/a';
    return;
end

if isempty(obj.EqWeights),
    msgEq = 'no';
else
    msgEq = 'yes';
end


end
