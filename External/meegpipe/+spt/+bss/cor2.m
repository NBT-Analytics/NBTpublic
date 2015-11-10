function K=cor2(x,tau)

if isvector(x),
    x = x(:);  
end
 
if nargin < 2, 
   tau=0;
end

m = size(x, 1);

tau = fix(abs(tau));

if tau>m 
   error('Choose tau smaller than Vector size');
end

L=x(1:m-tau,:);  
R=x(1+tau:m,:);
K=L'*R / (m-tau); 
%K=(K+K')/2; 