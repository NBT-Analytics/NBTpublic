function m = row_mean(X)

m = zeros(size(X, 1), 1);

for i = 1:size(X,1)
   m(i) = mean(X(i,:)); 
end

end