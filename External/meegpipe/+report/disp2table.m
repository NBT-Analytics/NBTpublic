function  myTable = disp2table(dispOutput) 
% DISP2TABLE - Attempts to create remark table from disp() output
%
% ## Usage synopsis:
%
% myTable = report.disp2table(dispOutput)
%
% Where `dispOutput` is the output produced by a call to disp(), as
% captured by e.g. evalc().
%
%
% See also: report.table

import mperl.split;
import report.table.table;

if ~ischar(dispOutput),
    dispOutput = evalc('disp(dispOutput)');
end

myTable = add_column(table, 'Property', 'Value');

dispOutput = split(char(10), dispOutput);

% Remove the empty lines
isEmpty = cellfun(@(x) isempty(x), dispOutput);
dispOutput = dispOutput(~isEmpty);

if numel(dispOutput) < 1, return; end

% Take care of the varname = ... if present
if ~isempty(regexp(dispOutput{1}, '^\s*\w+\s*=\s*$', 'once')),
    dispOutput(1) = [];
end

% Parse the object class, if present
className = '';
match = regexp(dispOutput{1}, ...
    '<a href="matlab:help\s+(?<className>[^"]+)".+a>.*$', 'names');
if ~isempty(match),
    className = match.className;
end
if isempty(className),
    % try the simpler case that a hyperlink is not displayed
    match = regexp(dispOutput{1}, '^\s*(?<className>[^\s]+)\s*$', 'once');
    if ~isempty(match) && isstruct(match) && isfield(match, 'className'),
        className = match.className;
    end
end
if ~isempty(className),
    add_row(myTable, 'Object class name', className);
    dispOutput(1) = [];
end

% Parse the package info if present
pkgName = '';
match = regexp(dispOutput{1}, ...
    '\s*Package\s*:\s*<a href="matlab:\s*help\s+(?<pkgName>[^"]+)".+a>$', ...
    'names');
if ~isempty(match),
    pkgName = match.pkgName;
end
if isempty(pkgName),
    % try the simpler case that a hyperlink is not displayed
    match = regexp(dispOutput{1}, '^\s*Package:\s*(?<pkgName>[^\s]+)\s*$', ...
        'names');
    if ~isempty(match) && isstruct(match) && isfield(match, 'pkgName'),
        pkgName = match.pkgName;
    end
end
if ~isempty(pkgName),
    add_row(myTable, 'MATLAB package', pkgName);
    dispOutput(1) = [];
end

% Discard as many rows as necessary until we find a prop : value 
count = 0;
found = false;
while ~found && count < numel(dispOutput),
    count = count + 1;    
    found = ~isempty(regexp(dispOutput{count}, '^[^:]+:[^:]+$', 'once'));
end

dispOutput = dispOutput(count:end,:);

count = 0;


for i = 1:size(dispOutput,1)
    
    if ~isempty(strfind(dispOutput{i}, 'matlab:methods')) || ...
            ~isempty(strfind(dispOutput{i}, 'matlab:superclasses')),
        % We have reached the last disp line
       return; 
    end
    
    tmp = strfind(dispOutput{i}, ':');
    if isempty(tmp), continue; end
    
    tmp = tmp(1);
    if tmp < 2 || tmp > numel(dispOutput{i}), continue; end
    
    count   = count + 1;
    pName   = regexprep(strtrim(dispOutput{i}(1:tmp-1)),   '^\[\]$', '');
    pValue  = regexprep(strtrim(dispOutput{i}(tmp+1:end)), '^\[\]$', '');
    
    add_row(myTable, pName, pValue);
    
end


end