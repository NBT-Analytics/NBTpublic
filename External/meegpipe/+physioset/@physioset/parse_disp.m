function  myTable = parse_disp(obj) %#ok<INUSD>

import mperl.split;
import report.table.table;

dispOutput = evalc('disp(obj)');
dispOutput = split(char(10), dispOutput);
dispOutput = dispOutput(5:end,:);

count = 0;

myTable = add_column(table, 'Property', 'Value');


for i = 1:size(dispOutput,1)
    
    tmp = strfind(dispOutput{i}, ':');
    if isempty(tmp), continue; end
    
    tmp = tmp(1);
    if tmp < 2 || tmp > numel(dispOutput{i}), continue; end
    
    count   = count + 1;
    pName   = regexprep(strtrim(dispOutput{i}(1:tmp-1)),   '^\[\]$', '');
    pValue  = regexprep(strtrim(dispOutput{i}(tmp+1:end)), '^\[\]$', '');
    
    add_row(myTable, pName, pValue);
    
end


end