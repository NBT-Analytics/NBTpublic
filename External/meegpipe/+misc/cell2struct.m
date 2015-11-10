function str = cell2struct(c)

str = cell2struct(c(1:2:end), c(2:2:end), 2);


end