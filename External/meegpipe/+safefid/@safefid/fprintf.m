function count = fprintf(this, varargin)

s(1).type = '.';
s(1).subs = 'fprintf';
s(2).type = '()';
s(2).subs = varargin;
count = subsref(this, s);


end