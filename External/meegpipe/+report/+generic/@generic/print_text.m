function count = print_text(obj, varargin)

text = str2multiline(sprintf(varargin{:}));

count = fprintf(obj, text);


end