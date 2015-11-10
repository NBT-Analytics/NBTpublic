function exception2str(ME)

import misc.cell2str;

fprintf('\n\n########## EXCEPTION INFORMATION:\n\n');

fprintf('identifier : %-20s\n', ME.identifier);
fprintf('message : %-20s\n', ME.identifier);
fprintf('cause : %-20s\n', cell2str(ME.cause));

fprintf('\nTrace information:\n\n');

st = ME.stack;

for i = 1:numel(st)
    
    fprintf('file : %-20s\n', st(i).file);
    fprintf('name : %-20s\n', st(i).name);
    fprintf('line : %-20d\n', st(i).line);
    
end

fprintf('########## END OF EXCEPTION INFORMATION\n\n');

end