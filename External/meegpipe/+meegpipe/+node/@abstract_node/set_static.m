function obj = set_static(obj, section, param, value)
% SET_STATIC - Set static node parameter

cfg = get_static_config(obj);

if ~section_exists(cfg, section),
    add_section(cfg, section);
end

if exists(cfg, section, param),
    setval(cfg, section, param, value); 
else
    newval(cfg, section, param, value);
end
    

end