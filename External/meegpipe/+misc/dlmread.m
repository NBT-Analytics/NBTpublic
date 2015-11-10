function [data, header, rownames, comments] = dlmread(filename, delim, r, c, varargin)
% dlmread - Read ASCII delimited file
%
%   DATA = dlmread(FILENAME, DELIM) reads numeric data from the ASCII
%   delimited file FILENAME. DELIM is the delimiter used in the file. If
%   not provided, blank spaces will be used as delimiter characters.
%
%   [DATA, HEADER] = dlmread(FILENAME, DELIM) reads numeric data from the
%   ASCII delimited file FILENAME but allows for a header row containing
%   text fields. These header fields are returned in cell array HEADER.
%
%   DATA = dlmread(FILENAME, DELIM, R, C) specifies the row R and column C
%   where the upper-left corner of the data lies in the file.
%
%   [DATA, HEADER] = dlmread(FILENAME, DELIM, R) returns R header lines in
%   cell array HEADER.
%
%
% See also: DLMREAD

import misc.process_varargin;
import misc.split;

if nargin < 4 || isempty(c), c = 0; end
if nargin < 3, r = []; end
if nargin < 2 || isempty(delim), delim = ' '; end

if nargin < 1 || isempty(filename),
    error('misc:dlmread:invalidInput', ...
        'First input argument must be a valid file name.');
end

% Default options
commentstyle    = '#';
headerstyle     = '';

% Process input options
THIS_OPTIONS = {'commentstyle', 'headerstyle'};
eval(process_varargin(THIS_OPTIONS, varargin));


if isempty(r),
    if isempty(headerstyle),
        r = 0;
    end
end

data_file_flag = false;
% Read the file header
if ~isempty(r) || ~isempty(headerstyle),
    % File has no header   
    data_file_flag = true;
end

% Read the comments
data_file = filename;
if ~isempty(commentstyle),
    if data_file_flag,
        data_file2 = tempname;
        comments = perl('+misc/pattern_split.pl', filename,  ...
            ['^^' commentstyle], data_file2);
        data_file = data_file2;
    else
        data_file = tempname;
        comments = perl('+misc/pattern_split.pl', filename,  ...
            ['^^' commentstyle], data_file);
    end    
elseif nargout>2,
    comments = [];
end

% Read the file header
if isempty(r) && isempty(headerstyle),
    % File has no header
    header = [];
elseif isempty(r),
    % Header is specified using a header style
    data_file = tempname;
    header = perl('+misc/pattern_split.pl', data_file, ...
        ['^^' headerstyle], data_file);
else
    % Header has a fixed number of lines
    data_file2 = tempname;
    header = perl('+misc/line_split.pl', data_file, ...
        num2str(r), data_file2); 
    data_file = data_file2;
end

% Read the data
data_file2 = tempname;
perl('+misc/dlmread_preprocess.pl', data_file, data_file2, delim);
delete(data_file);
data_file = data_file2;
%end
if isempty(delim) || strcmpi(delim, ' '),
    data = dlmread(data_file);
else
    data = dlmread(data_file, delim, r, c);
end

% Read the row names
if c > 0
    rownames = perl('+misc/dlmread_rownames.pl', data_file, delim);
    rownames = split(delim, rownames);
    rownames = rownames(r+1:end);
else
    rownames = {};
end

delete(data_file);
% Try to divide the header into column names
if ~isempty(delim),
    if ~strcmpi(delim, ' ')
        header = strrep(header, ' ', '_');
    end
    header = strrep(header, delim, ' ');
end
header = textscan(header, '%[^\n]');
header = header{1};
if length(header) == 1,
    % Fix problem when having Windows-like line endings
    if double(header{1}(end)) == 13,
        header{1} = header{1}(1:end-1);
    end
    header = textscan(header{1}, '%s');
    if length(header) == 1,
        header = header{1};
    end
end


end

