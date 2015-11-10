function count = fscanf(this, varargin)

s(1).type = '.';
s(1).subs = 'fscanf';
s(2).type = '()';
s(2).subs = varargin;
count = subsref(this, s);


end