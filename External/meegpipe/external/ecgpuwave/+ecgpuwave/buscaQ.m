function [Qp,QRS1,type]=buscaQ(n,X,D,Der,PKni,Rp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kq,Kr)

%Busca posición onda Q y principio QRS.


%Inicializamos las variables.
Qp=[]; QRS1=[]; Qex=1; crece=0; Kq=1.8; 
Daux=flipud(Der(1:imax+1));
ncero=buscacero(Daux); ncero=imax+1-ncero+1;
%if abs(Der(ncero+1))<abs(Der(ncero)) ncero=ncero+1; end
Daux=flipud(D(1:imax));
nceau=buscacero(Daux); nceau=imax-nceau+1;
%if abs(D(nceau+1))<abs(D(nceau)) nceau=nceau+1; end 
if isempty(nceau)|isempty(ncero)
   Qex=0;
end
if (Rp-ncero)/Fs>80e-3&(Rp<=PKni)
     Qex=0;
end
%if type==3&Sgran==1
%   Qex=0; 
%end

if (Qex==1)
   Iq=find(I<nceau);
   if isempty(Iq)
      Qex=0;
   end
end

if Qex==1
   mpic=I(Iq(length(Iq)));

%Protección para casos en que la derivada casi crece cero.
   Iq=find(I<imax);
   icep=I(Iq(length(Iq)));
   if  abs(D(mpic))>dermax/12 & ~(icep>mpic & abs(D(icep))<dermax/50) %Antes /12
     %Detectamos si la onda P está unida a Q.
       if (Rp-mpic)/Fs>90e-3 |((nceau-mpic)/Fs>30e-3&Rp<=PKni)
          Qex=0;        
       end

     %Buscamos el inicio
       umbral=D(mpic)/Kq;
       Daux=flipud(D(1:mpic));
       iumb=crearumbral(Daux,umbral);
       iumb=mpic-iumb+1;
       Iq=find(I<mpic); 
       if ~isempty(Iq)
           ipic=I(Iq(length(Iq)));
	   if ipic>iumb iumb=ipic;
	   end
       end
    %if (D(ipic))>abs(D(mpic))*0.8  %Antes *0.8
         %crece=1;
     %end
     if (Rp-iumb)/Fs>120e-3
        Qex=0; 
     end


%Comprueba que Q no comience con un pequeño pico de subida.
       ilimp=iumb-round(30e-3*Fs);
       if ilimp<=0 ilimp=1; end
       Daux=D(ilimp:iumb);
       [ymin2,imin2]=min(Daux); if ~isempty(imin2) imin2=ilimp+imin2-1; end
       [ymax2,imax2]=max(Daux); if ~isempty(imax2) imax2=ilimp+imax2-1; end
       if abs(ymin2)>=dermax/20
          umbral=(ymin2)/Kq;  
          Daux=flipud(D(1:imin2));
          iumb2=crearumbral(Daux,umbral);
          iumb2=imin2-iumb2+1;
          if (iumb2>iumb-round(40e-3*Fs))
             iumb=iumb2; 
          end
       end

       if (imax2<imin2 | abs(ymin2)<dermax/20) & abs(ymax2)>dermax/20
           umbral=(ymax2)/Kq; 
           Daux=flipud(D(1:imax2));
           iumb2=crearumbral(Daux,umbral);
           iumb2=imax2-iumb2+1;
           if (iumb2>iumb-round(40e-3*Fs))
              iumb=iumb2;
           end
        end
     else crece=1;     
     end

%Para detectar ondas Q de componente frecuencial muy elevada, trabajamos
%con la derivada del ECG sin filtrar.
    if (crece==1)
       Kq=Kq+1;
%   Daux=Der(Rp-round(200e-3*Fs):Rp+round(200e-3*Fs));
%dermax=max(abs(Daux)); %Añado cálculo de dermax.

      [Md,Id]=buscapic1(Der,0);
      Iq=find(Id<ncero);
      if ~isempty(Iq)
          mpic=Id(Iq(length(Iq)));
          mpic=testpic(Der,mpic,Fs,0);
      end
      if isempty(Iq) | abs(Der(mpic))<dermax/10 | (ncero-mpic)/Fs>30e-3 %Antes /10.
         Qex=0;   
      end
      if (Qex==1)
         umbral=(Der(mpic))/2.8; %Antes 2.8.
         Daux=flipud(Der(1:mpic));
         iumb=crearumbral(Daux,umbral);
         iumb=mpic-iumb+1;
         if (Rp-iumb)/Fs>80e-3 Qex=0; 
         end
      end   
   end
end

%Si no existe onda Q, buscamos el principio de la onda R.
if (Qex==0)
    if D(imax)>=4 Kr=Kr*6-2;
    elseif D(imax)>=3 Kr=Kr*4-2;
    elseif D(imax)>=1.5 Kr=Kr*2-2;
    end
    umbral=D(imax)/Kr;
   
    Daux=flipud(D(1:imax));
    iumb=crearumbral(Daux,umbral);
    if isempty(iumb)
       iumb=imax-round(30e-3*Fs);
    else 
       iumb=imax-iumb+1;
    end     
 
%Comprobamos que la onda R no comience con un pequeño pico.
    ib=max(1,iumb-round(30e-3*Fs));
    Daux=D(ib:iumb);
    [ymax2,imax2]=max(Daux); if ~isempty(imax2) imax2=ib+imax2-1; end
    if ymax2>=dermax/50 imax=imax2; ymax=ymax2; 
       umbral=ymax2/1.5;
       Daux=flipud(D(1:imax));
       iumb2=crearumbral(Daux,umbral);
       iumb2=imax-iumb2+1;
       if iumb2>iumb-round(36e-3*Fs) iumb=iumb2; 
       end
    end
end  
if (Qex==1) Qp=ncero; 
else Qp=[];
%else if (type==3)&(Sgran==0)
%        type=1;
%     end 
end 
QRS1=iumb;

if ~isempty(Qp)
   Qp=testpic(X,Qp,Fs,0);
end


