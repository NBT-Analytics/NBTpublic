function obj = set_meta(obj, varargin)

if numel(varargin) == 1 && isstruct(varargin{1}),
    obj.Info = varargin{1};
    return;
end

for i = 1:2:numel(varargin)
    
    for j = 1:numel(obj)       
        obj(j).Info.(varargin{i}) = varargin{i+1};               
    end
    
end


end