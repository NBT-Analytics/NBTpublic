function [status, ME] = make_test
% MAKE_TEST - Tests package pset
%
% [status, ME] = make_test
%
% where
%
% STATUS will be true upon successful completion of all tests. Otherwise,
% it will be false.
%
% ME will be empty upon successful compleation of all tests, or otherwise
% may contain the exception that was thrown during the testing phase.
%
% See also: pset

% Documentation: pkg_pset.txt
% Description: Test package functionality

import pset.tests.*;

path = fileparts(mfilename('fullpath'));

files = dir([path '/+tests']);

status  = true;
ME      = [];

verboseLabel = eegpipe.globals.get.VerboseLabel;

for i = 1:numel(files)
    
    if ~isempty(regexpi(files(i).name, '^\.')), continue; end
    
    [~, thisTest] = fileparts(files(i).name);  
    
    fprintf([verboseLabel '%s ...'], thisTest);    
    
    cmd = sprintf('[thisStatus, thisME] = %s();', thisTest);
    
    eval(cmd); 
    
    if ~isempty(thisME),
        ME = [ME; {thisME}]; %#ok<AGROW>
    end
    
    status = status && thisStatus;
    
    if thisStatus,
        fprintf('[ok]\n');
    else
        fprintf('[not ok]\n');
    end
    
end

fprintf('\n\n');

end