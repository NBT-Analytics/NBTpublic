function [Sp,QRS2,type,Sgran]=buscaS(n,X,D,Der,PKni,Rp,Sp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kr,Ks)

%Busca posición onda S y final QRS.

%Inicializamos variables.
Sp=[]; QRS2=[]; Sex=1; crece=0; iumb=[];
Daux=Der(imin:length(Der));
ncero=buscacero(Daux); ncero=imin+ncero-1;
%if abs(Der(ncero-1))< abs(Der(ncero)) ncero=ncero-1; end
Daux=D(imin:length(D));
nceau=buscacero(Daux); nceau=imin+nceau-1; 
%if abs(D(nceau-1))<abs(D(nceau)) nceau=nceau-1; end

if isempty(nceau)|isempty(ncero)
    Sex=0;
end
if (ncero-Rp)/Fs>130e-3&Rp>=PKni
   Sex=0;
end
if nceau<PKni&(X(PKni)<0)
   ncero=PKni; nceau=PKni;
end
if (Sex==1)
if ~isempty(Sp)&Sp==PKni
   ilim=nceau+round(140e-3*Fs); 
else ilim=nceau+round(80e-3*Fs);
end
if ilim>=length(D) ilim=length(D); end
Daux=D(nceau:ilim);
[ypic,mpic]=max(Daux); mpic=nceau+mpic-1;
if ypic<dermax/10
   Iq=find(I>=nceau);  %Cambio > por >='.
   mpic=I(Iq(1));
end
Iq=find(I>imin);
icep=I(Iq(1));

%Protección para casos en que la derivada casi crece el cero.
   if abs(D(mpic))>dermax/30 & (~(icep<mpic &abs(D(icep))<dermax/50)|PKni==ncero) %Antes /30.
      if (D(mpic))>=6.2 Ks=3*Ks+1; %Antes 6.2
      elseif (D(mpic))>=4.75 Ks=3*Ks; %Antes 4.75
      elseif (D(mpic))>=4 Ks=3*Ks-1; %Antes 4.
      end
      umbral=(D(mpic))/Ks;
     inicio=mpic+round(10e-3*Fs);
     Daux=D(mpic:length(D));
     iumb=crearumbral(Daux,umbral);
     iumb=mpic+iumb-1;
     Iq=find(I>inicio);
     if ~isempty(Iq)                  %RBL
	     ipic=I(Iq(1));
      	     if (ipic<iumb)&D(ipic)<dermax/15 iumb=ipic; 
      	     end
     end
      if (iumb-Rp)/Fs>200e-3  %Antes 200ms.
%No existe onda S.
          umbral=(D(mpic))/Kr;
          Daux=D(mpic:length(D));
          iumb=crearumbral(Daux,umbral);
          iumb=mpic+iumb-1; 
          inicio=mpic+round(10e-3*Fs);
          Is=find(I>inicio);
	  ipic=I(Is(1));
          if ipic<iumb & D(ipic)<dermax/3 iumb=ipic; 
          end
          end
    else 
%Trabajamos con la derivada sin filtrar.

     Daux=Der(ncero:length(Der));
     [Md,Id]=buscapic1(Der,0);
     Is=find(Id>ncero);
     mpic=Id(Is(1));
     mpic=testpic(Der,mpic,Fs,1);
     if abs(Der(mpic))<dermax/10&Rp>=PKni 
        Sex=0; 
     end
     if (Sex==1)
         umbral=(Der(mpic))/Ks;
         Daux=Der(mpic:length(Der));
         iumb=crearumbral(Daux,umbral);
         iumb=mpic+iumb-1; 
         inicio=mpic+round(10e-3*Fs);
         Is=find(I>inicio);
         ipic=I(Is(1));
         if ipic<iumb iumb=ipic; 
         end
         if (iumb-Rp)/Fs>200e-3
%No existe onda S.
             umbral=(D(mpic))/Kr;
             Daux=D(mpic:length(D));
             iumb=crearumbral(Daux,umbral);
             iumb=mpic+iumb-1; 
             inicio=mpic+round(10e-3*Fs);
             Is=find(I>inicio);
             ipic=I(Is(1));
             if ipic<iumb & D(ipic)<dermax/3 iumb=ipic; 
             end
          end
       end
    end
 end
 if ~isempty(iumb)&(iumb-Rp)/Fs>200e-3&Rp>=PKni
    Sex=0; Sp=[];     
 end
%Si no existe onda S, buscamos el final de la onda R.
if (Sex==0) 
    umbral=(D(imin))/Kr;
    Daux=D(imin:length(D));
    iumb=crearumbral(Daux,umbral);
    iumb=imin+iumb-1;
    inicio=imin+round(10e-3*Fs);
    Is=find(I>inicio);
    ipic=I(Is(1));
    if ipic<iumb iumb=ipic; %Añado condición.
    end
end
if (Sex==1) Sp=ncero;
   else Sp=[];
%else if (type==3)&(Sgran==1)
%         type=1;
%      end
end
QRS2=iumb;
if QRS2<PKni QRS2=PKni+1; end
if Sex==1
   Sp=testpic(X,Sp,Fs,0);
%if Sp>QRS2 
%   Sex=0; Sp=[];
%end  
end                
          
         
   
