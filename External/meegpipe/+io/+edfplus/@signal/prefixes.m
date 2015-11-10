function [prefix, power, name] = prefixes
% DIMENSION_PREFIXES 
% List of dimension prefixes and corresp. decimal powers
%
% [prefix, power, name] = physdim.prefixes
%
% Where
%
% PREFIX is a cell array with with valid dimension prefixes, POWER is a 
% double array with the corresponding decimal powers and NAME is a cell
% array with the common name of each decimal power.
%
% All valid prefixes are stored in file prefixes.txt
%
% See also: edfplus.label, edfplus.label.signal_types, EDFPLUS


path = fileparts(mfilename('fullpath'));
filename = [path filesep 'prefixes.txt'];
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