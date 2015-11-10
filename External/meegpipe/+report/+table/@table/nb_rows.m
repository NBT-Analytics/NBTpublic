function nbRows = nb_rows(obj)
% NB_ROWS - Number of table rows
%
% nbRows = nb_rows(obj)
%
% Where
%
% NBROWS is the number of rows in table object OBJ
%
% See also: table

% Description: Number of table rows
% Documentation: class_report_table_table.txt

nbRows = size(obj.Rows, 1);


end