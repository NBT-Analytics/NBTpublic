function [SG0, SG1, SG2] = differential(x, F)

if ~mod(F,2),
    F = F+1;
end

[~,g] = sgolay(4, F);


HalfWin  = ((F+1)/2) -1;

SG0 = zeros(size(x));
SG1 = zeros(size(x));
SG2 = zeros(size(x));

for n = (F+1)/2:length(x)-(F+1)/2,
  % Zero-th derivative (smoothing only)
  SG0(n) =   dot(g(:,1), x(n - HalfWin: n + HalfWin));
  
  % 1st differential
  SG1(n) =   dot(g(:,2), x(n - HalfWin: n + HalfWin));
  
  % 2nd differential
  SG2(n) = 2*dot(g(:,3)', x(n - HalfWin: n + HalfWin))';
end

