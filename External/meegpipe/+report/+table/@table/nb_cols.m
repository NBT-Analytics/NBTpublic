function nbCols = nb_cols(obj)
% NB_COLS - Number of table columns
%
% nbCols = nb_cols(obj)
%
% Where
%
% NBCOLS is the number of columns in table object OBJ
%
% See also: table

% Description: Number of table columns
% Documentation: class_report_table_table.txt

nbCols = numel(obj.Columns);


end