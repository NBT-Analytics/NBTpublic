function [type, dim, descr] = signal_types(queryType)
% SIGNAL_TYPES 
% List of signals and corresponding label and dimension
%
%   
% [type, dim] = label.signal_types;
% [type, dim, descr] = label.signal_types;
% [dim, descr] = label.signal_types(type);
%
% Where
%
% TYPE and DIM are Nx1 cell arrays containing signal type identifiers and
% corresponding physical dimensions. Entries in DIM might also be cell
% arrays, meaning that multiple standard physical dimensions are allowed.
%
% DESCR is a cell array with signal type descriptions.
%
%
% Note:
% 
% New signal types might be added by simply editing the text file
% signal_types.txt
%
%
% More information:
%
% [1] http://www.edfplus.info/specs/edftexts.html
%
%
% See also: edfplus.physdim, EDFPLUS

import misc.get_tokens;

if nargin < 1,
    queryType = [];
end

path = fileparts(mfilename('fullpath'));
filename = [path filesep 'signal_types.txt'];
fid = fopen(filename);
C = textscan(fid, '%s%s%s', 'CommentStyle', '#', 'Delimiter', ':');
fclose(fid);

type = cell(size(C{2}));
dim = cell(size(C{3}));
descr = cell(size(C{1}));
for i = 1:numel(C{1}),
    type{i} = strtrim(C{2}{i});
    dim{i} = get_tokens(C{3}{i},',');
    descr{i} = strtrim(C{1}{i});
end

if ~isempty(queryType),
    isQuery = ismember(type, queryType);
    type = type(isQuery);
    dim = dim(isQuery);
    descr = descr(isQuery);
end

if numel(type) == 1,
    type = type{1};
    dim = dim{1};
    descr= descr{1};
end