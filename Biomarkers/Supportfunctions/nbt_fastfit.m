function fitparam = fastfit(x,y)

a = [x(:) ones(length(x),1)];
fitparam =(a\y);

end