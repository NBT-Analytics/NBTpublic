function disp_body(obj)

import misc.any2str;

fNames = fieldnames(obj);

for i = 1:numel(fNames),
   
    fprintf('%20s : %s\n', fNames{i}, any2str(obj.(fNames{i}), 50));
    
end



end