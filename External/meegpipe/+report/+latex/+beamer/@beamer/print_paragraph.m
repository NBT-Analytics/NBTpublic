function print_paragraph(obj, txt, size)


if nargin < 3, size = 'normalsize'; end

size = regexprep(size, '^\\+', '');

size = ['\' size];

fprintf(obj.FID, '\n\n{%s %s}\n\n', size, txt);



end