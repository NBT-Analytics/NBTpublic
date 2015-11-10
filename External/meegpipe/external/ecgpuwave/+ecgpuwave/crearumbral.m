function iumb=crearumbral(X,umbral)

%Devuelve la posición del primer valor que cruza
%el umbral.
if ~isempty(X)  % JGM

if X(1)>umbral
  I=find(X<umbral);
  if ~isempty(I)
  iumb=I(1);
  if abs(X(iumb-1)-umbral)<abs(X(iumb)-umbral)
   iumb=iumb-1;
  end
  else iumb=[];
  end
else I=find(X>umbral);
   if ~isempty(I)
      iumb=I(1);
      if abs(X(iumb-1)-umbral)<abs(X(iumb)-umbral)
         iumb=iumb-1;
      end
   else iumb=[];
   end
end

end
