function val = get(obj, varargin)

if nargin == 1,
    
    % We get a copy of the report configuration!
    val = eval([class(obj.Config) '(obj.Config)']);
    
else
    
    val = get(obj.Config, varargin{:});
    
end


end