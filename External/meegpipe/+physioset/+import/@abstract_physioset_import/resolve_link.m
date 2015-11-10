function [fileName, obj] = resolve_link(obj, fileName)
% RESOLVE_LINK - Returns the target of a meegpipe link
%
% See also: physioset.import

% IMPORTANT: We keep obj as output for backwards compatibility

import safefid.safefid;

if nargin < 2 || ~ischar(fileName),
    ME = MException(...
        'abstract_physioset_import:StringExpected', ...
        'A string (a file name) was expected as second argument');
    throw(ME);
end

if ~exist(fileName, 'file'),
    ME = MException(...
        'abstract_physioset_import:FileDoesNotExist', ...
        'File %s does not exist', fileName);
    throw(ME);
end

fid = safefid.fopen(fileName, 'r');
if ~fid.Valid, return; end
tline = fid.fgetl;

if ~isempty(tline) && fid.feof && exist(tline, 'file'),
    fileName = tline;
end

end