function [cmd, arg] = process_arguments(keySet, argArray, needsValue, dowarn)
% PROCESS_ARGUMENTS - Parses varargin by extracting options names and values
%
%   cmd = process_arguments(keySet, argArray, needsValue)
%   [cmd, str] = process_arguments(keySet, argArray, needsValue)
%
%
% Where
%
% KEYSET is a cell array with N option names, e.g. {'-threads', '-nn'}.
% Leading hyphens will be not considered to be part of the option name.
% Alternatively, KEYSET can be a struct whose field names are option names
% and whose field values are default option values. In the latter case, the
% second output argument (STR) will be a struct with the updated values for
% each option.
%
% ARGARRAY is the varargin cell array of the calling function
%
% NEEDSVALUE is a boolean array with N entries that determine whether
% certain option should be accompanied by a value or not.
%
% CMD is the string that should be evaluated by the calling function
%

import misc.strtrim;
import misc.struct2cell;


if nargin < 4 || isempty(dowarn) || ~islogical(dowarn) || numel(dowarn)>1,
    dowarn = false;  % Change this to true at some point!!
end

if nargin < 3 || isempty(needsValue),
    if iscell(keySet), 
        needsValue = true(numel(keySet),1); 
    elseif isstruct(keySet),
        needsValue = true(numel(fieldnames(keySet)),1);
    end
end

if numel(argArray) == 1 && iscell(argArray),
    argArray = argArray{1};
end

if numel(argArray) == 1 && isstruct(argArray),
    argArray = struct2cell(argArray);
end

cmd = '';

if isstruct(keySet),
    arg = keySet;    
    keySet = fieldnames(keySet);
else
    arg = struct;
    for i = 1:numel(keySet)
        keySet{i} = regexprep(keySet{i}, '^-+', '');
        arg.(keySet{i}) = false;
    end
end

if ~iscell(argArray) || mod(numel(argArray), 2), return; end

nArgs = length(argArray);
argItr = 1;

while argItr <= nArgs
    if ~ischar(argArray{argItr}),                
        if dowarn
            warning('process_arguments:KeyExpected', ...
                'A key was expected (a string) but a ''%s'' was found', ...
                class(argArray{argItr}));
        end
        argItr = argItr + 1;
        continue;
    end
    
    if ismember(argArray{argItr}, {'-', '--'}),
        % End of arguments indicator
        return;
    end
    
    argArray{argItr} = regexprep(argArray{argItr}, '^-+', '');
    
    [~, loc] = ismember(lower(argArray{argItr}), lower(keySet));
    
    if loc > 0,
        % Option is recognized as valid
        if needsValue(loc),
            % Option takes a value
            if nArgs < argItr + 1,
                ME = MException('process_arguments:ValueExpected', ...
                    'A value is expected for option %s', argArray{argItr});
                throw(ME);
            end  
            if ~isempty(argArray{argItr+1}),
                cmd = [cmd keySet{loc} ...
                    '=varargin{' num2str(argItr+1) '};']; %#ok<*AGROW>
                arg.(keySet{loc}) = argArray{argItr+1};
            end
            argItr = argItr + 2;
        else
            % Inverts the default setting            
            cmd = [cmd keySet{loc} '=true;'];            
            arg.(keySet{loc}) = true;
            argItr = argItr + 1;
        end
    elseif dowarn
        warning('process_arguments:UnknownOption', ...
            'Unrecognized option ''%s'' will be ignored', argArray{argItr});
        if numel(argArray) > argItr && ~ischar(argItr+1),
            argItr = argItr + 2; % Assume user tried to pass a value
        else
            argItr = argItr + 1;
        end
    else
        argItr = argItr + 1;
    end
    
    
end


end