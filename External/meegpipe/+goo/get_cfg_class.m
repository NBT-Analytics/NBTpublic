function cfgClass = get_cfg_class(obj)


cfgClass = regexprep(class(obj), '(.+)\.[^.]+$', '$1.config');

% This occasionally breaks MATLAB, for whatever unknown reason...
%if strcmp(cfgClass, class(obj)) || ~exist(cfgClass, 'class'),

if strcmp(cfgClass, class(obj)),
    cfgClass = '';
end

  
end