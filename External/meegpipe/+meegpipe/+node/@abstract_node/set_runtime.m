function obj = set_runtime(obj, section, param, varargin)

import mperl.file.spec.catfile;

cfg = get_runtime_config(obj);

if ~section_exists(cfg, section),
    add_section(cfg, section);
end

if isempty(varargin)
    varargin = {''};
end

if exists(cfg, section, param),
    setval(cfg, section, param, varargin{:});
else   
    newval(cfg, section, param, varargin{:});
end


end