function status = make_test(userSelection)
% MAKE_TEST - Tests package physioset
%
% physioset.make_test
%
%
% See also: physioset


import mperl.join;
import test.simple.make_test;

close all;
clc;

% plotter.initialize;

if nargin < 1, userSelection = {}; end

verboseLabel = '(eegpipe) ';

%% List of modules that will be tested
moduleList = {...
    'physioset' ...
    'physioset.plotter.snapshots', ...
    'physioset.plotter.psd' ...
    };
%moduleList = repmat({'mperl.config.inifiles'}, 13, 1);

if ischar(userSelection), userSelection = {userSelection}; end

if ~isempty(userSelection),
    
    moduleList = intersect(moduleList, userSelection);
    
end

if isempty(moduleList),
    error('Module ''%s'' does not feature automated testing', ...
        userSelection{1});
end

% just in case
moduleList = unique(moduleList);

nbTests = numel(moduleList);

status = make_test(moduleList{:});

%% Summary

nbFailed = numel(find(status));

if nbFailed > 0,
    
    fprintf([verboseLabel '%d of %d module(s) had errors\n\n'], ...
        nbFailed, nbTests);
    
    fprintf([verboseLabel 'Below the list of the modules that failed:\n\n']);
    
    fprintf(join(char(10), moduleList(status)));
    
    fprintf('\n\n');
    
else
    
    fprintf([verboseLabel ...
        'Great! All tests (%d modules) were successful\n\n'], nbTests);
    
end


end