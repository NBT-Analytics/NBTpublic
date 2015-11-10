function RRm=calcrr(RRm,n,Fs,t)

% ---- Mean beat-to-beat distance ----
perc=0.5;
if n<=1
   if RRm==0
      RRm=t(2)-t(1);
      if RRm>(1000e-3*Fs) | RRm<(500e-3*Fs)
         RRm=round(650e-3*Fs);
       end
   end
else
  if n<7
   if (t(n)-t(n-1))>RRm*(1-perc) & (t(n)-t(n-1))<RRm*(1+perc)
      RRm=(RRm*(n-2)/(n-1))+((t(n)-t(n-1))/(n-1));
   end
  else
     if (t(n)-t(n-1))>RRm*(1-perc) & (t(n)-t(n-1))<RRm*(1+perc)
         RRm=(RRm*4/5)+((t(n)-t(n-1))/5);
      end
   end
end
