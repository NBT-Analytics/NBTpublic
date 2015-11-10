function y = num2strcell(x)

y = cell(size(x));

for i = 1:numel(x)
   y{i} = num2str(x(i)); 
end



end