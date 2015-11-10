function [r,p] = corrcoef(X)



for i=1:size(X,2)
    for j=i:size(X,2)
       [ r(i,j),p(i,j)]=nancorrcoef(X(:,i),X(:,j));
        r(j,i)=r(i,j);
        p(j,i)=p(i,j);
    end
end



function[r,p] = nancorrcoef(x,y)

tf = ~isnan(x) & ~isnan(y);  %Logical flag
x = x(tf);   y = y(tf);

if length(x)>1
    [r,p]=corrcoef(x,y);
    r=r(1,2);
    p=p(1,2);
else
    r=NaN;
    p=NaN;
end

if isnan(r)
    r=0;
    p=1;
end