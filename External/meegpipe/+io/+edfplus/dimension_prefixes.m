function [prefix, power, name] = dimension_prefixes
% DIMENSION_PREFIXES List of dimension prefixes and corresp. decimal powers
%
%   [PREFIX, POWER, NAME] = dimension_prefixes; returns a cell array PREFIX
%   with valid dimension prefixes, a double array POWER with the
%   corresponding decimal powers and a cell array NAME with the common name
%   of each decimal power.
%
%   All valid prefixes are stored in file dimension_prefixes.txt
%
% See also: EDFPLUS/signal_types


path = fileparts(mfilename('fullpath'));
filename = [path filesep 'dimension_prefixes.txt'];
fid = fopen(filename);
C = textscan(fid, '%s%s%s', 'CommentStyle', '#');
fclose(fid);

power = nan(size(C{2}));
prefix = cell(size(C{3}));
name = cell(size(C{1}));
for i = 1:numel(C{1}),
    power(i) = str2double(C{2}{i});
    prefix{i} = strtrim(C{3}{i});
    name{i} = strtrim(C{1}{i});
end