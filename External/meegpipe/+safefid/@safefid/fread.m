function [data, count] = fread(this, varargin)

s(1).type = '.';
s(1).subs = 'fread';
s(2).subs = varargin;

[data, count] = subsref(this, s);


end