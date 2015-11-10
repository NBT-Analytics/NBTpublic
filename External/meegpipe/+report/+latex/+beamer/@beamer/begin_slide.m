function begin_slide(obj, title)

if nargin < 2 || isempty(title), title = ''; end

fprintf(obj.FID, '\\frame{\n\\frametitle{%s}\n\n', title);


end

