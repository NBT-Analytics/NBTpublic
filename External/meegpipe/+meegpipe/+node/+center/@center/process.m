function [data, dataNew] = process(obj, data, varargin)

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

dataNew = [];

if verbose,
    
    [~, fname] = fileparts(data.DataFile);
    fprintf([verboseLabel 'Centering ''%s''...'], fname);

end

verb = is_verbose(data);
set_verbose(data, false);
center(data);   
set_verbose(data, verb);

if verbose, fprintf('[done]\n\n'); end



end