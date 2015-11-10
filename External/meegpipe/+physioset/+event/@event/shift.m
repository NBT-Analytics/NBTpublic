function ev = shift(ev, nSamples)


for i = 1:numel(ev)
   ev(i).Sample = ev(i).Sample + nSamples; 
end
    
    



end