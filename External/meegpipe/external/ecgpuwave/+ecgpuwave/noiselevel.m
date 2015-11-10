function mnoise=noiselevel(X)

% ---- Mean noise level ----

inicio=1;
iew=length(X);
mnoise=0;
i=0;

while (inicio<iew)
   i=i+1;
   ifinal=min(inicio+5,iew);
   [ymin2,imin2]=min(X(inicio:ifinal));
   [ymax2,imax2]=max(X(inicio:ifinal));
   mnoise=(ymax2-ymin2)+mnoise;
   inicio=ifinal;
end

if i>0
   mnoise=abs(mnoise/i);
end
