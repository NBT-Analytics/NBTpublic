function y = link2mfile(mfile, name, line)
% LINK2MFILE - Generate hyperlink to an mfile

if nargin < 3 || isempty(line), line = []; end
if nargin < 2 || isempty(name), name = mfile; end

if isempty(line),
    
    if usejava('Desktop'),
        y = sprintf('<a href="matlab: open(''%s'')">%s</a>', mfile, name);
    else
        y = name;
    end
    
else
    
    if usejava('Desktop'),
        y = sprintf('<a href="matlab: opentoline(''%s'', %d)">%s</a>', ...
            mfile, line, name);
    else
        y = sprintf('line %d', line);
    end
    
end


end