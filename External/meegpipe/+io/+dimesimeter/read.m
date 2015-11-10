function [data, time, hdr] = read(varargin)
% READ - Reads dimesimeter raw data files
%
% ````matlab
% [data, time, hdr] = read(filename)
% ````
%
% Where
%
% __filename__ is a string with the full path name of a dimesimeter _header
% file.
%
% __data__ is a Kx7 data matrix containing the values for seven variables.
%
% __time__ is a Kx1 vector of datenums
%
% __hdr__ is a struct with header information. At this point, it only
% contains a field 'label' which contains a cell array with labels for each
% data column.
%
%
% ## Notes:
%
% This function expects the existence of a raw dimesimeter data file in the
% same path location as the provided header file (__filename__). The name
% of the raw data file must be identical to the name of the header file but
% with the string `_header` removed.
% 
% See also: io.dimesimeter

import safefid.safefid;

if nargin > 1,
    data = cell(1, nargin);
    time = cell(1, nargin);
    for i = 1:nargin
       
        [data{i}, time{i}] = daisymeter.read(varargin{i});
        
    end

    return;
    
end

filename = varargin{1};

fid = safefid.fopen(filename, 'r');

%% Read the header information
rgb = fid.textscan('#%s %s %s', 1);
rgb = cellfun(@(x) str2double(x), rgb);
knt1 = fid.textscan('#%s %s %s %s %s %s %s %s %s', 1);
knt1 = cellfun(@(x) str2double(x), knt1);
kp = knt1(1);
cp = knt1(4);
bc = knt1(7);
ap = knt1(2);
cc = knt1(8);
bp = knt1(3);
ac = knt1(6);
by = knt1(9);

clear fid;

%% Read raw data values
filename = strrep(filename, '_header', '');
fid = safefid.fopen(filename, 'r');

fid.fscanf('%d', 2);
recDate = fid.fscanf('%d', 5);
recDate = datenum(sprintf('%d/%d/%d %d:%d:00', recDate), 'yy/mm/dd HH:MM:SS');

int = fid.fscanf('%d', 1)/86400;

raw = fid.fscanf('%d');

clear fid;

raw(1:8) = [];
raw(1:2:end) = 256*raw(1:2:end);
raw   = reshape(raw, 2, round(numel(raw)/2));
raw   = sum(raw);
time  = recDate + int*(0:numel(raw)/4-1);
red   = raw(1:4:end);
green = raw(2:4:end);
blue  = raw(3:4:end);

% No idea why this has to be done, just replicating what the dimesimeter
% guys wrote in their completely undocumented code
act        = raw(4:4:end);
sel        = mod(act, 2) > 0;
red(sel)   = red(sel)/5;
green(sel) = green(sel)/5;
blue(sel)  = blue(sel)/5;

% Again, no idea why. Just reproducing the dimesimeter's guys code
act   = act/2;

% Light intensity (lux)
lux = kp*(rgb(1)*ap*red + rgb(2)*bp*green + rgb(3)*cp*blue);

% Circadian effective Light
if (rgb(3)*blue>=by*lux);    
    cla = (ac*rgb(3)*blue)-(bc*lux);
else
    cla = cc*rgb(3)*blue;
end

% Circadian Stimulus
cs = 0.75 - (0.75./(1+(cla./215.75).^0.864));

data = [red' green' blue' lux' cla' cs' act'];

% ??, just reproducing manufacturer's code
xEnd = find(red == 13107, 1, 'first');
if isempty(xEnd), xEnd = numel(red); end
data = data(5:xEnd-5, :);
time = time(5:xEnd-5)';

hdr.label = {'red', 'green', 'blue', 'lux', 'cla', 'cs', 'act'};

end