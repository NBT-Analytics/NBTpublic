function status = fseek(this, varargin)

s(1).type = '.';
s(1).subs = 'fseek';
s(2).type = '()';
s(2).subs = varargin;
status = subsref(this, s);


end