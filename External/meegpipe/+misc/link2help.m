function y = link2help(mfile, name)
% LINK2HELP - Generate hyperlink to function/class documentation

if nargin < 2 || isempty(name), name = mfile; end

if usejava('Desktop'),
    y = sprintf('<a href="matlab: help(''%s'')">%s</a>', mfile, name);
else
    y = name;
end


end