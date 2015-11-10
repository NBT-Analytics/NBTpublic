function value = get_diagnostics(obj, varargin)


if nargin < 2,
    
    value = obj.Diagnostics_;
    
elseif nargin == 2,
    
    value = obj.Diagnostics_.(varargin{1});
    
else
    
    value = cell(1, numel(varargin));
    
    for i = 1:numel(varargin)
        
       value{i} = obj.Diagnostics_.(varargin{i});
        
    end
    
end


end