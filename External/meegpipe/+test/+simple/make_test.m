function status = make_test(varargin)
% MAKE_TEST - Tests a package
%
% See also: test.simple

import misc.dir;
import mperl.file.spec.*;
import test.simple.globals;
import misc.link2mfile;
import safefid.safefid;

LOG_FILE = 'meegpipe_test.log';

if nargin < 1,
    status = test.simple.globals.get.Failure;
    warning('make_test:NoTests', 'Did not run any test');
    return;
end


verboseLabel = '(make_test) ';
status = false(1, nargin);

log_file = safefid.fopen(LOG_FILE, 'w');

for j = 1:nargin
    module = varargin{j};
    
    path = feval([module '.root_path']);
    
    files = dir(catdir(path, '+tests'), '\.m$');
    
    thisStatus  = repmat(globals.get.Failure, 1, numel(files));
    
    for i = 1:numel(files) 
        
        [~, name] = fileparts(files{i});
        
        funcName = [module '.tests.' name];
        fprintf([verboseLabel link2mfile(funcName) '\n']);
        log_file.fprintf('(%s) %s ...', datestr(now), funcName);
        
        cmd = sprintf('%s.tests.%s', module, name);
        
        thisStatus(i) = feval(cmd);
        
        fprintf('\n\n');
        
        if thisStatus(i) > 0,
            log_file.fprintf('[%d not OK] %s\n', thisStatus(i), datestr(now));
        else
            log_file.fprintf('[OK] %s\n', datestr(now));
        end
    end
    
    status(j) = any(thisStatus ~= globals.get.Success);
    
end

end