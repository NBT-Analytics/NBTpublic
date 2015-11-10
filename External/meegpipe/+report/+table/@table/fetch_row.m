function rows = fetch_row(obj, idx)
% FETCH_ROW - Fetches table rows
%
% rows = fetch_row(obj, idx)
%
% Where
%
% IDX is a 1xK array of row indices
%
% ROWS is a KxM cell array with the contents of the K relevant table rows.
%
%
% See also: fetch_column, fetch_cell, table

% Description: Fetches table rows
% Documentation: class_report_table_table.txt

if nargin < 2 || isempty(idx),
    
    idx = 1:nb_rows(obj);
    
end

rows = obj.Rows(idx, :);


end