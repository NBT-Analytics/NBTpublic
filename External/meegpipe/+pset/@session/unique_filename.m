function filename = unique_filename(obj, name, ext)
% UNIQUE_FILENAME - Returns a unique file name within a session directory
%
% filename = unique_filename(obj, name, ext)
%
% Where
%
% NAME is a string identifying the data that will be stored in the file.
% This function will a simple approach to derive a valid (and unique) 
% filename based on name. If not provided, a random filename will be
% generated (by calling method tempname).
%
% EXT is the desired file extension. If not provided, no file extension
% will be used.
%
% See also: tempname


OK_CHARS = 'a-zA-Z0-9 .,-_';

if nargin < 3 || isempty(ext),
    ext = '';
elseif ~ischar(ext) || ~isvector(ext),
    error('Argument EXT must be a string (a char array)');
else
    if ~strcmpi(ext(1), '.'),
        ext = ['.' ext];
    end
end


if nargin < 2 || isempty(name),
    filename = [tempname(obj) ext];
elseif ~ischar(name) || ~isvector(name),
    error('Argument NAME must be a string (a char array)');
else
    name = regexprep(name, ['[^' OK_CHARS ']'], '');
    % I don't like spaces in filenames
    name            = regexprep(name, '\s+', '_');
    filenameStem    = [obj.Folder '/' name];
    filename        = filenameStem;
    while exist([filename ext], 'file'),       
       filename = [filenameStem '_' datestr(now, 'yyyymmddTHHMMSS')];       
    end    
    filename = [filename ext];
end


end





