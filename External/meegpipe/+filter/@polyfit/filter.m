function [data, obj] = filter(obj, data, varargin)

import misc.eta;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

tinit = tic;

if verbose,
    if isa(data, 'goo.named_object') || isa(data, 'goo.named_object_handle'),
        name = get_name(data);
    else
        name = '';
    end
    fprintf([verboseLabel, 'Polynomial filtering %s...'], name);
end

warning('off', 'MATLAB:oldPfileVersion');

for i = 1:size(data, 1)
    if ~all(abs(data(i,:)-mean(data(i,:))) < eps),
        
        
        x = 1:size(data,2);
        if obj.Decimation > 1,
            dx = x(1:obj.Decimation:end); %#ok<*NASGU>
            dataDi = resample(data(i,:), 1, obj.Decimation);
        else
            dx = x;
            dataDi = data(i,:);
        end
        
        %Fit the polynomial to the decimated data
        
        %Need to pre-declare mu or the code below breaks in some MATLAB
        %versions (e.g. R2011a)
        thisOrder = obj.Order;
        mu = [];
        
        T = evalc('[p, ~, mu] = polyfit(dx(:), dataDi(:), thisOrder);');
        [p, ~, mu] = polyfit(dx(:), dataDi(:), thisOrder);
        
        %If ill conditioning warning, redo for lower orders
        while ~isempty(T) && ~isempty(strfind(T, 'badly conditioned')) && ...
                thisOrder > 5,
            
            thisOrder = thisOrder - 1;
            T = evalc('[p, ~, mu] = polyfit(dx(:), dataDi(:), thisOrder);');
            
        end
        
        
        if ~isempty(T), disp(T); end
        
        if obj.GetNoise,
            data(i, :) = data(i, :) - polyval(p, (x-mu(1))/mu(2));
        else
            data(i, :) = polyval(p, (x-mu(1))/mu(2));
        end
        
    end
    
    if verbose,
        eta(tinit, size(data, 1), i, 'remaintime', true);
    end
    
end
warning('on', 'MATLAB:oldPfileVersion');

if verbose,
    fprintf('\n\n');
    clear misc.eta;
end


end