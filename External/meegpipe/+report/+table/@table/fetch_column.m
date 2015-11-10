function colNames = fetch_column(obj, idx)
% fetch_column - Fetches table column names
%
% colName = fetch_column(obj, idx)
%
% Where
%
% IDX is an array of column indices
%
% COLNAME is a cell array containing the corresponding column names. If a
% single column index is provided, then COLNAME will be a string with the
% corresponding column name. If IDX is not provided or is empty then, all
% column names will be fetched.
%
% See also: fetch_row, table

% Description: Fetches table column names
% Documentation: class_report_table_table.txt

if nargin < 2 || isempty(idx),
    
    idx = 1:nb_cols(obj);
    
end

colNames = obj.Columns(idx);

if numel(colNames) == 1,
    
    colNames = colNames{1};
    
end




end