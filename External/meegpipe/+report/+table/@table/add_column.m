function obj = add_column(obj, varargin)
% ADD_COLUMN - Add table column
%
% obj = add_column(obj, colName1, colNam2, ...)
% obj = add_column(obj, idx, colName1, colName2, ...)
%
% Where
%
% OBJ is a table object
%
% COLNAME1, COLNAME2, ... are the names of the columns to be added to the
% table (i.e. one or more strings).
%
% IDX is the column index on which the columns are to be inserted. If not
% provided, IDX will default to nb_cols(obj)+1. Alternatively, IDX can also
% be the name of an existing table column, in which case the new columns
% will be inserted at the position of that particular column.
%
% See also: del_column, add_row, del_row, table

% Description: Add table column
% Documentation: class_report_table_table.txt

import exceptions.*;

if nargin < 2,
    return;
end

if isnumeric(varargin{1}),
    
   idx = varargin{1};
   varargin = varargin(2:end);
   
elseif ischar(varargin{1}),
    
    % If the column exists already -> this is an index
    [colExists, idx] = ismember(varargin{1}, fetch_column(obj));
    
    if ~colExists,
        idx = nb_cols(obj) + 1;
    end
    
else
    
    throw(InvalidArgValue('idx', ['Must be a column index or the name ' ...
        'of an existing table column']));
    
end

[b,~,j] = unique(varargin);
varargin = b(j);

if nb_cols(obj) > 0,
    
    varargin(ismember(varargin, obj.Columns)) = [];
    
end

obj.Columns = [obj.Columns(1:idx-1) varargin obj.Columns(idx:end)];


end