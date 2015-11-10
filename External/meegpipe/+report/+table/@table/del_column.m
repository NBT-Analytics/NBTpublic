function obj = del_column(obj, idx)
% DEL_COLUMN - Delete table column(s)
%
% obj = del_column(obj, idx)
%
% Where
%
% IDX is an array with the indices of the columns to be removed
%
% See also: add_column, del_row

% Documentation: class_report_table_table.txt
% Description: Delete table columns

obj.Columns(idx) = [];
obj.Rows(:, idx) = [];

end