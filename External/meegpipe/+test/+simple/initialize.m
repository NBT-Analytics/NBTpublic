function status = initialize(nbTests, verboseGlobal)
% INITIALIZE - Initializes test count
%
% status = test.simple.initialize(nbTests);
% status = test.simple.initialize(nbTests, verboseGlobal);
%
% Where
%
% NBTESTS is the number of tests that you are going to run.
%
% VERBOSEGLOBAL is the singleton object that is used system-wide to
% activate/deactivate verbosity. VERBOSEGLOBAL must have a property
% Verbose, which can be accessed through a standard set/get interface.
%
% STATUS is an exit code that follows the same convention as function ok().
%
%
% See also: ok

% Description: Initializes package
% Documentation: pkg_test_simple.txt

import test.simple.globals;
import misc.isinteger;

try
    
    %% Take care of verbosity issues
    if nargin < 2 || isempty(verboseLabel),
        
        if exist('goo.globals', 'class'),
            verboseGlobal = goo.globals.get;
        else
            verboseGlobal = [];
        end
        
    end
    
    if ~isempty(verboseGlobal),
        
        globals.set('Verbose', verboseGlobal.get.Verbose);
        globals.set('VerboseGlobal', class(verboseGlobal));
        verboseGlobal.set('Verbose', false);
        
    end
   
    %% Basic consistency check
    if nargin < 1 || isempty(nbTests) || ~isinteger(nbTests) || nbTests < 0,
        status = globals.get.Failure;
        return;
    end
    
    %% Intialize tests counters
    globals.set('TestCount', nbTests);
    globals.set('OK', 0);
    globals.set('Failed', 0);
    globals.set('Died', 0);   
    
    fprintf('1..%d\n', nbTests);
    
catch ME
    %% Print error message and exit
    [st, idx] = dbstack;
    fprintf('failed initialization: %s\n', ME.message);
    if numel(st) > idx,
        fprintf('#\tin file %s at line %d\n', st(end).file, st(end).line);
    end
    status = globals.get.Failure;
    return;
    
end

status = globals.get.Success;

end