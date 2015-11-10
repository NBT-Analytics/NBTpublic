function [typeOut, dimOut, descrOut] = signal_types(typeIn)
% SIGNAL_TYPES - EDF+ signals and corresponding label and dimension
%
% [type, dim] = signal_types;
%
% [type, dim, descr] = signal_types(type);
%
%
% Where
%
% TYPE is a Nx1 cell array of signal names
%
% DIM is a Nx1 cell array of physical dimensions
%
% DESCR is a Nx1 cell array of signal descriptions
%
%
% ## Notes:
%
%  *  New signal types can be added to the standard by simply editing the
%     text file signal_types.txt.
%
%
% See also: io.edfplus.dimension_prefixes, io.edfplus

% Description: Valid EDF+ signals
% Documentation: io_edfplus_signal_types.txt

import misc.get_tokens;

if nargin < 1,
    typeIn = [];
end

if ischar(typeIn), typeIn = {typeIn}; end

path = fileparts(mfilename('fullpath'));
filename = [path filesep 'signal_types.txt'];
fid = fopen(filename);
C = textscan(fid, '%s%s%s', 'CommentStyle', '#', 'Delimiter', ':');
fclose(fid);

type = cell(size(C{2}));
dim  = cell(size(C{3}));
descr = cell(size(C{1}));
for i = 1:numel(C{1}),
    type{i} = strtrim(C{2}{i});
    dim{i} = get_tokens(C{3}{i},',');
    descr{i} = strtrim(C{1}{i});
end

if isempty(typeIn),
    typeOut = type;
    descrOut = descr;
    dimOut = dim;
    return;
end

typeOut  = cell(numel(typeIn),1);
descrOut = cell(numel(typeIn),1);
dimOut   = cell(numel(typeIn),1);
if ~isempty(typeIn),
    [tf, loc]      = ismember(typeIn, type);
    dimOut(tf)     = dim(loc(tf));
    descrOut(tf)   = descr(loc(tf));
    typeOut(tf)    = type(loc(tf));   
end
    