function cellArray = fetch_cell(obj, i, j)
% FETCH_CELL - Fetches table cells
%
% cellArray = fetch_cell(obj, i, j)
%
% Where
%
% I and J are the row and column indices of the cells to be fetched. 
%
% CELLARRAY is a cell array containing the specified cells
%
% See also: fetch_column, fetch_row, table

% Description: Fetches table cells
% Documentation: class_report_table_table.txt

if nargin < 1 || (isempty(i) && isempty(j))

    cellArray = {};
    return;
    
elseif nargin < 3 || isempty(j),
    
    cellArray = fetch_row(obj, i);
    return;
    
elseif isempty(i),
    
    cellArray = fetch_column(obj, j);
    return;
    
end


if numel(i) > 1 && numel(j) == 1,
    
    j = repmat(j, 1, size(i));
    
elseif numel(i) == 1 && numel(j) > 1,
    
    i = repmat(i, 1, size(j));
    
elseif numel(i) ~= numel(j),
    
    error('The dimensions of the I and J indices do not match');
    
end

cellArray = cell(size(i));

for iIter = 1:numel(i)
   
    for jIter = 1:numel(j)
        
       cellArray(iIter, jIter) = obj.Rows(iIter, jIter);
        
    end
    
end




end