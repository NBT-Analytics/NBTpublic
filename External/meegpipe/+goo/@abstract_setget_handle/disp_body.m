function disp_body(obj)

import misc.any2str;

if numel(obj) ~= 1,
    return;
end

[~, fNames] = fieldnames(obj);

for i = 1:numel(fNames)
   value = obj.(fNames{i});
   if numel(value) < 50,
       value = any2str(value);
   else
       dims = [regexprep(num2str(size(value)), '\s+', 'x') ' '];
       value = sprintf(['[ %s' class(value) ' ]'], dims); 
   end
   fprintf('%20s : %s\n',  fNames{i}, value);
end

end