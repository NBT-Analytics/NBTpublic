function [Sp,QRS2,type,Sgran]=Swave(n,X,D,Der,PKni,Rp,Sp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kr,Ks)

% ---- S wave and QRS offset ----

import ecgpuwave.*;

Sp=[]; QRS2=[]; Sex=1; crece=0; iumb=[];
Daux=Der(imin:length(Der));
ncero=zerocross(Daux); ncero=imin+ncero-1;
%if abs(Der(ncero-1))< abs(Der(ncero)) ncero=ncero-1; end
Daux=D(imin:length(D));
nceau=zerocross(Daux); nceau=imin+nceau-1; 
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
   Iq=find(I>=nceau); 
   mpic=I(Iq(1));
end
Iq=find(I>imin);
icep=I(Iq(1));

% ---- Protection against cases in which the derivative almost exceeds zero
% ----
   if abs(D(mpic))>dermax/30 & (~(icep<mpic &abs(D(icep))<dermax/50)|PKni==ncero) %Antes /30.
      if (D(mpic))>=6.2 Ks=3*Ks+1;
      elseif (D(mpic))>=4.75 Ks=3*Ks;
      elseif (D(mpic))>=4 Ks=3*Ks-1; 
      end
      umbral=(D(mpic))/Ks;
     inicio=mpic+round(10e-3*Fs);
     Daux=D(mpic:length(D));
     iumb=thresholdcross(Daux,umbral);
     iumb=mpic+iumb-1;
     Iq=find(I>inicio);
     if ~isempty(Iq)                  %RBL
	     ipic=I(Iq(1));
      	     if (ipic<iumb)&D(ipic)<dermax/15 iumb=ipic; 
      	     end
     end
      if (iumb-Rp)/Fs>200e-3
          
% ---- There is not S wave ----
          umbral=(D(mpic))/Kr;
          Daux=D(mpic:length(D));
          iumb=thresholdcross(Daux,umbral);
          iumb=mpic+iumb-1; 
          inicio=mpic+round(10e-3*Fs);
          Is=find(I>inicio);
	  ipic=I(Is(1));
          if ipic<iumb & D(ipic)<dermax/3 iumb=ipic; 
          end
          end
   else 
        
% ---- Working with the unfiltered derivative ----

     Daux=Der(ncero:length(Der));
     [Md,Id]=peaksearch(Der,0);
     Is=find(Id>ncero);
     mpic=Id(Is(1));
     mpic=testpeak(Der,mpic,Fs,1);
     if abs(Der(mpic))<dermax/10&Rp>=PKni 
        Sex=0; 
     end
     if (Sex==1)
         umbral=(Der(mpic))/Ks;
         Daux=Der(mpic:length(Der));
         iumb=thresholdcross(Daux,umbral);
         iumb=mpic+iumb-1; 
         inicio=mpic+round(10e-3*Fs);
         Is=find(I>inicio);
         ipic=I(Is(1));
         if ipic<iumb iumb=ipic; 
         end
         if (iumb-Rp)/Fs>200e-3
             
% ---- There is not S wave ----
             umbral=(D(mpic))/Kr;
             Daux=D(mpic:length(D));
             iumb=thresholdcross(Daux,umbral);
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

% ---- If there is not S wave, search for the onset of R wave ---- 
if (Sex==0) 
    umbral=(D(imin))/Kr;
    Daux=D(imin:length(D));
    iumb=thresholdcross(Daux,umbral);
    iumb=imin+iumb-1;
    inicio=imin+round(10e-3*Fs);
    Is=find(I>inicio);
    ipic=I(Is(1));
    if ipic<iumb iumb=ipic; 
    end
end
if (Sex==1) Sp=ncero;
   else Sp=[];
end
QRS2=iumb;
if QRS2<PKni QRS2=PKni+1; end
if Sex==1
   Sp=testpeak(X,Sp,Fs,0);
end                
          
         
   
