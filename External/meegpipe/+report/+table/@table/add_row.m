function obj = add_row(obj, varargin)
% ADD_ROW - Add table rows
%
% obj = add_row(obj, col1, col2, ...)
% obj = add_row(obj, idx, col1, col2, ..., colN)
%
% Where
%
% COL1, COL2, ... are the values to be stored in each column of the new
% row.
%
% IDX is the row index on which the given row should be inserted. If not
% provided, IDX = nb_rows(obj)+1. Note that for IDX to be identified as a row
% index, rather than as a column value, the number of provided column
% values must match the number of columns in the table, even if one or more
% of the last columns are empty. 
%
% See also: add_column, del_row, del_column, table

% Description: Add table row
% Documentation: class_report_table_table.txt

import exceptions.*;
import misc.isnatural;

if nargin < 2,
    return;
end

if isnumeric(varargin{1}) && numel(varargin) > nb_cols(obj),
    
    idx = varargin{1};
    varargin = varargin(2:end);
    
else
    
    idx = nb_rows(obj)+1;
    
end

if numel(idx) > 1 || ~isnatural(idx),
    
    throw(InvalidArgValue('idx', 'Must be a natural scalar'));
    
end

if numel(varargin) > nb_cols(obj),
    
    error(['Number of provided columns (%d) exceeds number of columns ' ...
        'in table (%d)'], numel(varargin), nb_cols(obj));
    
end

row = cell(1, nb_cols(obj));
row(1:numel(varargin)) = varargin;

row = cellfun(@(x) misc.any2str(x, Inf), row, 'UniformOutput', false);
    
obj.Rows(idx, :) = row;



end