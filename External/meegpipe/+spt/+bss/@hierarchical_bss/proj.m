function [y, I] = proj(obj, data, fullMatrix)

if nargin < 3 || isempty(fullMatrix), fullMatrix = false; end

W        = projmat_win(obj, fullMatrix);
winBndry = window_boundary(obj);

y = pset.pset.nan(nb_component(obj), size(data,2));

if isa(data, 'physioset.physioset')
    y = physioset.physioset.from_pset(y, ...
        'SamplingRate',     data.SamplingRate, ...
        'Event',            data.Event, ...
        'StartDate',        data.StartDate, ...
        'StartTime',        data.StartTime);
    
    copy_sensors_history(y, sensors(data));
end

for i = 1:size(W,3)
    timeRange = winBndry(i,1):winBndry(i,2);
    y(:, timeRange) = squeeze(W(:,:,i))*data(:,timeRange);
end

I = component_selection(obj);


end