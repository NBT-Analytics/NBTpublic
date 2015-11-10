function [secs,sampl] = etime(ev1, ev2)
% etime - Elapsed time between events
%
% See also: event

nTimes = max(numel(ev1), numel(ev2));

secs = nan(nTimes, 1);
sampl = nan(nTimes, 1);

for i = 1:nTimes
   
    if numel(ev1) == 1,
        t1 = get(ev1, 'Time');
        sampl1 = get_sample(ev1);
    else
        t1 = get(ev1(i), 'Time');
        sampl1 = get_sample(ev1(i));
    end
    
    if numel(ev2) == 1,
        t2 = get(ev2, 'Time');
        sampl2 = get_sample(ev2);
    else
        t2 = get(ev2(i), 'Time');
        sampl2 = get_sample(ev2(i));
    end
    
    secs(i) = etime(datevec(t2), datevec(t1));
    
    sampl(i) = sampl2 - sampl1;
    
end

end