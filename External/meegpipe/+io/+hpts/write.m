function write(file, M, varargin)

import misc.process_arguments;

keySet = {'-category', '-id'};

nCardPoints = min(3, size(M,1));
category = [repmat({'cardinal'}, nCardPoints, 1); ...
    repmat({'eeg'}, size(M,1)-nCardPoints, 1)];
id = num2cell((1:size(M,1))');
for i = 1:numel(id), id{i} = num2str(id{i}); end

eval(process_arguments(keySet, varargin));

if ischar(category),
    category = repmat({category}, size(M,1));
end

fid = fopen(file, 'w');

try
    fprintf(fid,  '%-15s%13s%13s%13s%13s\n',  ...
        '# <category>', '<identifier>', '<x/mm>', '<y/mm>', '<z/mm>');
    for i = 1:size(M,1)
        fprintf(fid,  '%-15s%13s%13.4f%13.4f%13.4f\n',  ...
        category{i}, id{i}, M(i,1), M(i,2), M(i,3));                                
    end 
    fclose(fid);
    
catch ME
    fclose(fid);
    rethrow(ME);
end


end