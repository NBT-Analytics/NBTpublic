function obj = read(obj)
% READ - Reads the contents of the inifile
%
% obj = read(obj)
%
% Where
%
% OBJ is a mperl.config.inifiles.inifile object
%
%
% See also: inifile

import mperl.split;
import misc.strtrim;
import mperl.config.inifiles.inifile;

if ~exist(obj.File, 'file'),
    fid = fopen(obj.File, 'w');
    if fid < 1,
        % wait a bit and try again...
        pause(2);
        fid = fopen(obj.File, 'w');
        if fid < 1
            msg = sprintf('Unable to open/create file %s', obj.File);
            throw(inifile.InvalidPropValue('File', msg));
        end
    end
    [~, name] = fileparts(obj.File);
    warning('inifile:CreatedIniFile', ...
        'File %s did not exist so I created it', [name, '.ini']);
    fclose(fid);
end

check_file(obj);

args = obj.NewString;

value = perl('+mperl/+config/+inifiles/read.pl', obj.File, args{:});

% Different sections separated by three empty lines
sections = split(repmat(char(10), 1, 5), value);

myHash = mjava.hash;

for secItr = 1:numel(sections)
    
    params = split(repmat(char(10),1,2), sections{secItr});
    
    if isempty(params),
        secName = sections{secItr};
    else
        secName = strtrim(params{1});
        params(1) = [];
    end
    
    secHash = mjava.hash;
    
    for paramItr = 1:numel(params)
        
        thisParam = split(char(10), params{paramItr});
        paramName = strtrim(thisParam{1});
        
        if numel(thisParam) > 2,
            paramVal = thisParam(2:end);
        else
            paramVal  = thisParam{2};
        end
        
        secHash(paramName) = paramVal;
        
    end
    
    myHash(secName) = secHash;
    
end

obj.HashObject = myHash;

end