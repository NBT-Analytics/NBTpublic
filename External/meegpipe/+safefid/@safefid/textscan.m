function C = textscan(this, varargin)

S(1).type = '.';
S(1).subs = 'textscan';
S(2).type = '()';
S(2).subs = varargin;

C = subsref(this, S);

end