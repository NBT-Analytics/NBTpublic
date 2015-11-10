function ev = import_info(ev, file, fields, varargin)
% import_info
%
%   Documentation to be done.
%
% See also: pset.event

import pset.globals;
import pset.event;
import misc.process_varargin;
import misc.dlmread;
import misc.ismember;

if isempty(ev),
    warning('pset:event:import_info:emptyInput', ...
        'No events were provided. ');
    return;
end

if nargin < 3 || isempty(fields),
    error('pset:event:import_info:invalidInput','');
end

if nargin < 2, file = []; end

% Process input options
THIS_OPTIONS = {'key', 'keyorder', 'verbose', 'delimiter', 'header', 'data'};
key = [];
keyorder = 'ascend';
header = [];
data = [];
verbose = globals.evaluate.Verbose;
delimiter = globals.evaluate.Delimiter;
[cmd_str, remove_flag] = process_varargin(THIS_OPTIONS, varargin);
eval(cmd_str);
varargin(remove_flag) = [];

% Load the data file
if ~isempty(file) && ischar(file),
    [~,~,ext] = fileparts(file);
    switch lower(ext),
        case '.xls'
            [data, header] = xlsread(file);
        otherwise,
            [data, header] = dlmread(file, delimiter, 1, 0, 'Verbose', verbose);
    end
elseif ~isempty(file) && iscell(file),
    header = file(1,:);
    data = file(2:end,:);
    clear file;
elseif isempty(header) || isempty(data),
    error('pset:event:import_info:invalidEventInfo', ...
        'No event info.');
end

header = lower(header);

% Remove fields that do not exist in the XLS file
fields = lower(fields);
[isvalid, col_loc] = ismember(fields, header);
if any(~isvalid),
    idx = find(~isvalid);
    for i = 1:length(idx)
        warning('pset:event:import_info', ...
            'A column named ''%s'' could not be found.', fields{idx(i)});
    end
    fields(~isvalid) = [];
    col_loc(~isvalid) = [];
end

% Additional input arguments that are also valid column names
in_args = lower(varargin(1:2:end));
[iscol, arg_col_loc] = ismember(in_args, header);
in_args = in_args(iscol);
arg_col_loc = arg_col_loc(iscol);

eval(process_varargin(in_args, varargin));

% Remove the rows that do not fit the criteria

for i = 1:length(arg_col_loc)
    select = ismember(data(:,arg_col_loc(i)), eval(in_args{i}));
    data = data(select, :);
end
if isempty(data),
    error('pset:event:load_xls:emptySelection', ...
        'There is no info for the events satisfying the specified criteria.');
    %return;
end

% Sort the events using the key (if provided)
if ~isempty(key),
    [tf,idx] = ismember(lower(key),header);
    if tf,
        key_vals = data(:, idx);
        [~, I] = sort(key_vals, 1, keyorder);
    else
        I = 1:size(data,1);
    end
else
    I = 1:size(data,1);
end

% Remove the columns that are not of interest
fields_data = data(I, col_loc);

if isempty(fields_data),
    warning('pset:event:import_info:emptySelection', ...
        'There is no info for the events satisfying the specified criteria.');
    return;
end

if numel(ev) < size(fields_data,1),
    fields_data = fields_data(end-numel(ev)+1:end, :);
elseif numel(ev) > size(fields_data, 1)
    error('pset:event:import_info:wrongDimensions', ...
        'The number of input events and the number of matching rows of the data matrix do not agree.');
    
end

% Update the events
for j = 1:numel(fields),
    for i = 1:numel(ev)
        ev(i) = set(ev(i), fields{j}, fields_data(i,j));
    end
end








