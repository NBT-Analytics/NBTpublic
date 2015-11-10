function [header, time, xyz, light, button, prop_val] = binread(fname, varargin)
% binread - Reads geneactiv .bin files
%
% ````matlab
% [hdr, time, xyz, light, but] = read(fname)
% [hdr, time, xyz, light, but, prop_val] = read(fname, 'key1', 'key2',...)
% ````
%
% Where
%
% __fname__ is the file name
%
% __hdr__ is a Mx1 cell array containing M header pages (each of them a
% struct)
%
% __time__ is an Nx1 vector of measurement times. The times are expressed
% as serial date numbers (see help datenum)
%
% __xyz__ is a Nx3 matrix of calibrated accelerometer measurements. The
% columns correspond to the x, y and z axes
%
% __light__ is a Nx1 vector of calibrated light measurements
%
% __but__ is a Nx1 vector of button status values (1 on / 0 off)
%
% 'key1', 'key2' are names of page properties that should be extracted (and
% interpolated) from each data page.
%
%
% See also io.geneactiv.read

import misc.eta;
import datestr2num.DateStr2Num;
import misc.decompress;
import safefid.safefid;
import misc.process_arguments;

opt.DataProps = {'Battery voltage', 'Temperature'};
opt.Verbose   = true;
[~, opt] = process_arguments(opt, varargin);

if ~iscell(opt.DataProps),
    opt.DataProps = {opt.DataProps};
end

% Some constants
DATA_PAGE_NAME = 'Recorded Data';
NB_HEADER_PAGES = 7;
NB_DATA_PAGES = 100;
CALIBRATION_PAGE_NAME = 'Calibration Data';
% These are not anymore needed but the code is less robust now, read below
%TIME_NAME = 'Page Time';
%TIME_FORMAT = 'yyyy-mm-dd HH:MM:SS:FFF';
INTERPOLATE_PROPS = true;
MEASUREMENT_FREQ_NAME = 'Measurement Frequency';

% The input file might be zipped
[status, fname] = decompress(fname, 'Verbose', false);
isZipped = ~status;

fid = safefid.fopen(fname, 'r');

% Skip any blank line at the beginning of file
C = fid.textscan('%[^\n]',1);
while isempty(C{1}),
    C = fid.textscan('%[^\n]', 1);
end

% Read header pages
header = cell(NB_HEADER_PAGES, 1);
header_page_count = 1;
page_name = C{1}{1};

while ~strcmpi(page_name, DATA_PAGE_NAME),
    C = fid.textscan('%[^\r\n:*]: %[^\r\n]');
    header{header_page_count} = cell2struct(C{2}, ...
        strrep(C{1}(1:numel(C{2})), ' ', '_'), 1);
    header{header_page_count}.Page_Name = page_name;
    if strcmpi(page_name, CALIBRATION_PAGE_NAME),
        x_gain = str2double(header{header_page_count}.x_gain);
        y_gain = str2double(header{header_page_count}.y_gain);
        z_gain = str2double(header{header_page_count}.z_gain);
        x_offset = str2double(header{header_page_count}.x_offset);
        y_offset = str2double(header{header_page_count}.y_offset);
        z_offset = str2double(header{header_page_count}.z_offset);
        volts = str2double(header{header_page_count}.Volts);
        lux =  str2double(header{header_page_count}.Lux);
    end
    if numel(C{2})<numel(C{1}),
        page_name = C{1}{end};
        header_page_count = header_page_count + 1;
    else
        % We have reached the end of the file
        xyz      = [];
        light    = [];
        button   = [];
        prop_val = [];
        time     = [];
        return;
    end
end
header(header_page_count+1:end) = [];

if isfield(header{end},'Number_of_Pages'),
    nb_pages_in_header = true;
    nb_pages = str2double(header{end}.Number_of_Pages);
else
    nb_pages_in_header = false;
    nb_pages = NB_DATA_PAGES;
end

% Read the data pages
data_page_count = 1;
page_name = DATA_PAGE_NAME;
xyz = nan(300*nb_pages, 3);
light = nan(300*nb_pages, 1);
button = nan(300*nb_pages, 1);
if ~isempty(opt.DataProps),
    prop_val = nan(nb_pages, numel(opt.DataProps));
else
    prop_val = [];
end
time = nan(nb_pages, 1);
freq = nan(nb_pages, 1);

pagesBy100 = floor(nb_pages/100);
tinit = tic;
while strcmpi(page_name, DATA_PAGE_NAME),
    C = fid.textscan('%[^\r\n:*]: %[^\r\n]');
    if numel(C{1}) ~= numel(C{2})+1,
        error('Invalid format in %dth data page', data_page_count);
    end
    % Get the numeric properties of that the user wants to get
    
    if ~isempty(opt.DataProps)
        [prop_idx, prop_loc] = ismember(C{1}(1:end-1), opt.DataProps);
        [prop_loc, idx] = sort(prop_loc(prop_idx));
        prop_idx = find(prop_idx);
        prop_idx = prop_idx(idx);
        prop_val(data_page_count, prop_loc) = str2double(C{2}(prop_idx));
    end
    
    % Get the measurement time
    %     time(data_page_count) = datenum(C{2}(ismember(C{1}(1:end-1), TIME_NAME)), ...
    %         TIME_FORMAT);
    
    % Faster, but less robust
    thisTime = [...
        C{2}{3}([1 2 3 4 6 7 9 10]) ...
        'T'  C{2}{3}([12 13 15 16 18 19]) '.' ...
        C{2}{3}([21 22 23])];
    time(data_page_count) = DateStr2Num(thisTime, 300);
    
    % Get the measurement frequency
    freq(data_page_count) = str2double(C{2}(ismember(C{1}(1:end-1), ...
        MEASUREMENT_FREQ_NAME)));
    
    % Get the measurements
    meas_idx = (data_page_count-1)*300+1:(data_page_count*300);
    [xyz(meas_idx,:), light(meas_idx), button(meas_idx)] = hex2xyz(C{1}{end});
    page_name =  fid.textscan('%[^\r\n]',1);
    if ~isempty(page_name{1}),
        page_name = page_name{1};
        data_page_count = data_page_count + 1;
    else
        page_name = '';
    end
    if opt.Verbose && ~mod(data_page_count, pagesBy100),
        eta(tinit, nb_pages, data_page_count);
    end
end

clear fid;

if ~isempty(page_name),
    warning('binread:unknownPageName', 'Unknown page name %s', page_name{1});
end
if nb_pages_in_header && data_page_count ~= nb_pages,
    warning('binread:unknownPageName', ...
        ['Only %d data pages were found although %d pages are annotated ' ...
        'in the header'], data_page_count, nb_pages);
end

% We may have read less pages that it says in the header
data_page_count = data_page_count - 1;
if ~isempty(prop_val),
    prop_val = prop_val(1:data_page_count,:);
end
freq = freq(1:data_page_count);
time = time(1:data_page_count);
xyz = xyz(1:300*data_page_count,:);
light = light(1:300*data_page_count, :);
button = button(1:300*data_page_count,:);

% Interpolate the time
if any(diff(freq)),
    error('Not implemented yet');
else
    secs = 300/freq(1);
    msecs = round((secs-floor(secs))*1e3);
    secs = floor(secs);
    time_end = addtodate(addtodate(time(1), secs, 'second'), ...
        msecs, 'millisecond');
    offset = linspace(0, time_end-time(1), 300);
    time_interp = repmat(time(:), 1, 300) + repmat(offset, numel(time), 1);
    time_interp = time_interp';
    time_interp = time_interp(:);
end

% Intepolate the selected page properties
if INTERPOLATE_PROPS && ~isempty(prop_val)
    prop_val_interp = nan(numel(time_interp), size(prop_val, 2));
    for i = 1:size(prop_val, 2)
        prop_val_interp(:, i) = interp1(time, prop_val(:,i), time_interp, 'spline');
    end
    prop_val = prop_val_interp;
end
time = time_interp;

% Calibrate the data
xyz = (xyz*100 - repmat([x_offset, y_offset, z_offset], ...
    data_page_count*300, 1))./repmat([x_gain, y_gain, z_gain], ...
    data_page_count*300, 1);
light = floor(light*lux/volts);

% Delete unzipped data file
if isZipped,
    delete(fname);
end

end


function [xyz, light, button] = hex2xyz(hstr)
% Hexadecimal to decimal conversion of data values
n_bytes = floor(numel(hstr)/2);
n_meas = n_bytes/6;
hstr = reshape(hstr(1:n_bytes*2), 2, n_bytes)';

% Convert hexadecimal strings to binary strings
%bin_values = dec2bin(hex2dec(hstr))';
bin_values = io.geneactiv.hex2bin(hstr)';

bin_values = reshape(bin_values, 1, n_bytes*8);
idx = repmat((1:48:48*n_meas)', 1, 12) + repmat(0:11, n_meas, 1);
x = tc2dec(bin_values(idx),12);
y = tc2dec(bin_values(idx+12),12);
z = tc2dec(bin_values(idx+24),12);
idx = repmat((37:48:48*n_meas)', 1, 10) + repmat(0:9, n_meas, 1);

% Convert to decimal values
s = bin_values(idx);
[m,n] = size(s);
v = s - '0';
twos = pow2(n-1:-1:0);
light = sum(v .* twos(ones(m,1),:),2);

button = bin_values((47:48:48*n_meas)')=='1';
f = bin_values((48:48:48*n_meas)')=='1';
if any(f),
    error('The (f) field is not zero!');
end

xyz = [x(:),y(:),z(:)];
button = button(:);
light = light(:);

end


function value = tc2dec(bin,N)
% Two-complement to decimal conversion

% Convert to decimal values
[m,n] = size(bin);
v = bin - '0';
twos = pow2(n-1:-1:0);
val = sum(v .* twos(ones(m,1),:),2);

y = sign(2^(N-1)-val).*(2^(N-1)-abs(2^(N-1)-val));

value = y;
condition = (y==0 & val~=0);
value(condition) = -val(condition);

end

