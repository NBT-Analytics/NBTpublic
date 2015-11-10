function mline = code2multiline(code, lineLength, prefix, postfix)
% CODE2MULTILINE - Convert string containing MATLAB code to multiline string
%
% mline = code2multiline(code)
% mline = code2multiline(code, lineLength, prefix, postfix)
%
% Where
%
% CODE is a single-line string containing MATLAB code, i.e. a string such
% that eval(code) should not produce any error.
%
% MLINE is a multiline string such that is otherwise identical to CODE.
% That is, eval(mline) and eval(code) should produce exactly the same
% outcome.
%
% LINELENGTH is the desired line length in the output string. By default,
% LINELENGTH is 65 characters.
%
% PREFIX/POSTFIX are a prefix and postfix strings to be added to each
% generated line. Note that using prefix and/or posfix may prevent
% eval(mline) to be valid MATLAB syntax. These two optional input arguments
% may be useful e.g. to produced commented code (by setting PREFIX to '%')
%
% ## Disclaimer:
%
% * This function is extremely fragile and has been tested only with few
%   very simple toy examples. 
%
% See also: str2multiline, misc

import misc.quote;

if nargin < 2 || isempty(lineLength),
    lineLength = 65;
end

if nargin < 3 || isempty(prefix),
    prefix = '';
end

if nargin < 4 || isempty(postfix),
    postfix = '';
end

%% Pre-processing

code = [strrep(code, char(10), ' ') ' '];

initSpaces = regexprep(code, '(\s*).+', '$1');

lineLength = lineLength - numel(postfix) - numel(prefix);

%% Break the input string into several lines
regex = sprintf('(.{1,%d}[\\s/\\\\]+)|(.{1,%d}\\s+)', ...
    lineLength, lineLength);

% Tabs (char(9)) will be used to mark multiline statements
mline = regexprep(code, regex, ['$1 ...' char(10) initSpaces char(9)]);

if numel(code)/numel(find(mline==char(10))) > lineLength,
    % Break lines at any location
    regex = sprintf('(.{1,%d}[\\s/\\\\])|(.{1,%d}\\s+)', ...
        lineLength, lineLength);
    
    % Tabs (char(9)) will be used to mark multiline statements
    mline = regexprep(code, regex, ['$1 ...' char(10) initSpaces char(9)]);    
end


if any(mline == char(10)),
    mline(end-5-numel(initSpaces):end) = [];
end

%% Fix broken literal strings

% first line
mline = regexprep(mline, ...
    ['([^\]\w]\s*)(''[^'']+?)(\s...' char(10) ')'], ...
    '$1[$2''$3');

% body
mline = regexprep(mline, ...
    ['(''\s*...' char(10) ')(\s*)([^'']+?)([,\s]+\.\.\.' char(10) ')'], ...
    '$1$2''$3''$4');


% apply until no change (i.e. no more broken string literals)

for i = 1:30  % for limit is just a precaution against an infinite loop
    
    prev = mline;
    mline = regexprep(mline, ...
        ['(''\s*...' char(10) ')(\s*)([^'']+?)([,\s]+\.\.\.' char(10) ')'], ...
        '$1$2''$3''$4');
    if strcmp(prev, mline),
        break;
    end
    
end

% last line
mline = regexprep(mline, ...
    ['(''\s*\.\.\.' char(10) ')(\s+)([^''\s]+?)''(.*)$'], ...
    '$1$2''$3'']$4');  

% a quick fix for the case that we have something like:
% blah clabh', ...
% arg)
mline = regexprep(mline, ...
    ['(''\s*\.\.\.' char(10) ')(\s*)([^'']+?)''([,\s]+\.\.\.' char(10) ')'], ...
    '$1$2''$3'']$4'); 

%% Post-processing: add prefix/postfix

mline = strrep(mline, char(10), [postfix char(10) prefix]);
mline = [prefix mline postfix];

end