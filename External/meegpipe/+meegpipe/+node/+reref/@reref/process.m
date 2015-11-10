function [data, dataNew] = process(obj, data, varargin)

dataNew =[];

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

W = get_config(obj, 'RerefMatrix');

if verbose,
    
    [~, fname] = fileparts(get_datafile(data));
    fprintf([verboseLabel 'Re-referencing ''%s''...'], fname);

end

if size(data,1) < 2,
    warning('reref:OneDimensionalData', ...
        'Not possible to re-reference a dataset with just one channel');
    return;
end

if isa(W, 'function_handle'),
    W = W(data);
end

if any(abs(sum(W,2))>1e6) || all(W(:) < eps),
    error('Not a valid rereferencing matrix');
end

data = reref(data, W);    

if verbose, fprintf('[done]\n\n'); end



end