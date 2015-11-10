function line = fgetl(this, varargin)

s(1).type = '.';
s(1).subs = 'fgetl';
s(2).type = '()';
s(2).subs = varargin;
line = subsref(this, s);


end