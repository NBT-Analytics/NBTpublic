function count = fprintf(fid, obj)
% FPRINTF - Print table to open file
%
% count = fprintf(fid, obj)
%
% Where 
%
% FID is an open file identifier
%
% OBJ is a table object
%
% COUNT is the number of characters that were written to the file
%
% See also: table


if nb_cols(obj) < 1,
    count = 0;
    return;
end

% Find out column width
cWidth = nan(1, nb_cols(obj));
for i = 1:nb_cols(obj)-1
   cWidth(i) = max(cellfun(@(x) numel(x), obj.Rows(:, i))) + 5; 
end
colNames = fetch_column(obj);
cWidth(nb_cols(obj)) = numel(colNames{nb_cols(obj)})*2;

formatStr = strrep(repmat('%%-%ds', 1, nb_cols(obj)-1), 's%', 's | %'); 
formatStr = [sprintf(formatStr, cWidth(1:end-1)) '| %s\n'];

% Column headers

count = fprintf(fid, formatStr, colNames{:});
hl = arrayfun(@(x) repmat('-', 1, x), cWidth, 'UniformOutput', false);
count = count + fprintf(fid, formatStr, hl{:});

% Print rows
for i = 1:nb_rows(obj)
    thisRow = fetch_row(obj, i);
    count = count + fprintf(fid, formatStr, thisRow{:});
end

count = count + fprintf(fid, '\n\n');

% Print references, if any
for i = 1:nb_refs(obj)       
    [thisName, thisTarget] = get_ref(obj, i);
    count = count + fprintf(fid, '[%s]: %s\n', thisName, thisTarget);
end

end