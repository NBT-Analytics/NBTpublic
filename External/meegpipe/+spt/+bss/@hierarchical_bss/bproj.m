function [y, I] = bproj(obj, ics, fullMatrix)

if nargin < 3 || isempty(fullMatrix), fullMatrix = false; end

A        = bprojmat_win(obj, fullMatrix);
I        = dim_selection(obj);
Ic       = component_selection(obj);
winBndry = window_boundary(obj);

y = pset.pset.nan(nb_dim(obj), size(ics,2));

if isa(ics, 'physioset.physioset')
    y = physioset.physioset.from_pset(y, ...
        'SamplingRate',     ics.SamplingRate, ...
        'Sensors',          ics.Sensors, ...
        'Event',            ics.Event, ...
        'StartDate',        ics.StartDate, ...
        'StartTime',        ics.StartTime);
    
    copy_sensors_history(y, ics);
end

if ~fullMatrix,
    select(ics, Ic);
end
for i = 1:size(A,3)
    timeRange = winBndry(i,1):winBndry(i,2);
    select(ics, [], timeRange);
    y(:, timeRange) = squeeze(A(:,:,i))*ics(:,:);
    restore_selection(ics);
end
if ~fullMatrix,
    restore_selection(ics);
end

if isa(ics, 'physioset.physioset'),
    restore_sensors(y, obj);
end


end