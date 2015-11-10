function bool = isbuiltin(x)


bool = isa(x, 'builtin');

if bool, return; end

fullPath = which(x);
if ~isempty(strfind(fullPath, matlabroot)),
    bool = true;
else
    bool = false;
end


end