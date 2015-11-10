function ruido=buscaruido(X)
%Devuelve el nivel medio de ruido.

inicio=1;
iew=length(X);
ruido=0;
i=0;

while (inicio<iew)
   i=i+1;
   ifinal=min(inicio+5,iew);
   [ymin2,imin2]=min(X(inicio:ifinal));
   [ymax2,imax2]=max(X(inicio:ifinal));
   ruido=(ymax2-ymin2)+ruido;
   inicio=ifinal;
end

if i>0
   ruido=abs(ruido/i);
end
