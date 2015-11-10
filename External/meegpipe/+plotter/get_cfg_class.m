function cfgClass = get_cfg_class(obj)


cfgClass = regexprep(class(obj), '(.+)\.[^.]+$', '$1.config');


end