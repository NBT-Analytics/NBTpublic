function obj = set_diagnostics(obj, varargin)

for i = 1:numel(varargin)   
    
    obj.Diagnostics_.(inputname(i+1)) = varargin{i};
    
end


end