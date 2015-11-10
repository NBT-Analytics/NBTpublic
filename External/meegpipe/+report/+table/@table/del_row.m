function obj = del_row(obj, idx)
% DEL_ROW - Delete table row(s)
%
% obj = del_row(obj, idx)
%
% Where
%
% IDX is an array with the indices of the rows to be removed
%
% See also: add_row, del_column, table

% Documentation: class_report_table_table.txt
% Description: Delete table rows

obj.Rows(idx, :) = [];

end