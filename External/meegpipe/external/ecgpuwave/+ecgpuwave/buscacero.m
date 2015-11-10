function ncero=buscacero(X)

%Devuelve el primer cruce por cero en la señal.

I=find(sign(X)~=sign(X(1)));
if ~isempty(I)
ncero=I(1); ncero=ncero-(abs(X(ncero-1))<abs(X(ncero)));  % JGM
else ncero=[];
end
