function count = print_paragraph(obj, varargin)

import misc.str2multiline;

if ischar(varargin{1}),
    text = str2multiline(sprintf(varargin{:}));
    text = strrep(text, '%','%%');
    varargin = {text};
end
    

count = fprintf(obj, varargin{:});

count = count + fprintf(obj, '\n\n');

end