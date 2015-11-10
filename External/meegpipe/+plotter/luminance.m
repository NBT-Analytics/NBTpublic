function y = luminance(rgb)

y = 0.2126*rgb(:,1) + 0.7152*rgb(:,2) + 0.0722*rgb(:,3);


end