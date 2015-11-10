function status = push(obj, section, parameter, varargin)
% PUSH - Pushes new values at the end of existing value(s) 

import mperl.perl;

if nargin < 4,
    status = false;
    return;
end

check_file(obj);

varargin = cellfun(@(x) mperl.char(x), varargin, 'UniformOutput', false);

if ~iscell(varargin),
    varargin = {varargin};
end

status = perl('+mperl/+config/+inifiles/push.pl', obj.File, ...
    section, parameter, obj.NewString{:}, varargin{:});

pause(obj.Pause);

if strcmpi(status, '1'),
    
    status = true;
    
    % Update the hash, if it exists
    if ~isempty(obj.HashObject),
        
        currVal = obj.HashObject(section, parameter);
        
        if iscell(currVal),
            newVal = [currVal(:), varargin(:)];
        else
            newVal = [{currVal}; varargin(:)];
        end        
        
        obj.HashObject(section, parameter) =  newVal;  
        
    end
    
else
    
    status = false;
    
end


end