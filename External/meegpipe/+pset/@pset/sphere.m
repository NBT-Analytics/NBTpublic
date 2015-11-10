function y = sphere(a)
% SPHERE Spheres a pset object
%
%   Y = SPHERE(A)
%
% See also: pset.pset

transposed_flag = false;
if a.Transposed,
    transposed_flag = true;
    a.Transposed = false;
end

y = center(a);
Cy = cov(y);
y = (Cy^(-1/2))*y;

if transposed_flag,
    y.Transposed = true;
    y.Transposed = true;
end