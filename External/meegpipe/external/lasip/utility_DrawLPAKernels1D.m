% show convolution kernels for the WindowTypeCell{1}

nWinType = 1; 

for zzz=1:length(h),
    
    figure,
    
    plot(kernels{nWinType,zzz}(:)','-'), axis tight, grid on;
    
end;