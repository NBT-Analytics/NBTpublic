function status = setval(obj, section, parameter, varargin)
% SETVAL - Sets parameter values of the config file

import mperl.perl;
import mperl.split;
import mperl.config.inifiles.inifile;

varargin = cellfun(@(x) mperl.char(x), varargin, 'UniformOutput', false);

if ~iscell(varargin),
    varargin = {varargin};
end

%% Take care of multi-line parameter values
isMultiline = any(cellfun(@(x) any(x==char(10)), varargin));

if isMultiline && numel(varargin) == 1,
    
    varargin = split(char(10), varargin{1});
    status = setval(obj, section, parameter, varargin{:});
    return;
    
elseif isMultiline,
    
    ME = inifile.InvalidArgument(['Multiple multi-line parameter values ' ...
        'are not allowed']);
    throw(ME);
    
end

%% Call Perl
check_file(obj);

status = '0';
count  = 0;
while ~strcmp(status, '1') && count < obj.MaxTries
    count = count + 1;
    status = perl('+mperl/+config/+inifiles/setval.pl', obj.File, ...
    section, parameter, obj.NewString{:}, varargin{:});
    pause(obj.Pause);
end

%% Update hash
if strcmpi(status, '1'),
    
    status = true;    
    
    % Update the hash, if it exists
    if ~isempty(obj.HashObject),
        
       if numel(varargin) == 1,
           obj.HashObject(section, parameter) =  varargin{1};
       else
           obj.HashObject(section, parameter) =  varargin;
       end
       
    end
    
else
    
    status = false;
    
end

end