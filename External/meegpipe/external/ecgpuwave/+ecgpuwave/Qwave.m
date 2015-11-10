function [Qp,QRS1,type]=Qwave(n,X,D,Der,PKni,Rp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kq,Kr)

import ecgpuwave.*;

% ---- Q wave and QRS onset ----

Qp=[]; QRS1=[]; Qex=1; crece=0; Kq=1.8; 
Daux=flipud(Der(1:imax+1));
ncero=zerocross(Daux); ncero=imax+1-ncero+1;
%if abs(Der(ncero+1))<abs(Der(ncero)) ncero=ncero+1; end
Daux=flipud(D(1:imax));
nceau=zerocross(Daux); nceau=imax-nceau+1;
%if abs(D(nceau+1))<abs(D(nceau)) nceau=nceau+1; end 
if isempty(nceau)|isempty(ncero)
   Qex=0;
end
if (Rp-ncero)/Fs>80e-3&(Rp<=PKni)
     Qex=0;
end

if (Qex==1)
   Iq=find(I<nceau);
   if isempty(Iq)
      Qex=0;
   end
end

if Qex==1
   mpic=I(Iq(length(Iq)));

% ---- Protection against cases in which the derivative almost crosses zero
% ----
   Iq=find(I<imax);
   icep=I(Iq(length(Iq)));
   if  abs(D(mpic))>dermax/12 & ~(icep>mpic & abs(D(icep))<dermax/50) 
       
     % ---- Detection of P wave joint to Q wave ----
       if (Rp-mpic)/Fs>90e-3 |((nceau-mpic)/Fs>30e-3&Rp<=PKni)
          Qex=0;        
       end

     % ---- Q wave onset ----
       umbral=D(mpic)/Kq;
       Daux=flipud(D(1:mpic));
       iumb=thresholdcross(Daux,umbral);
       iumb=mpic-iumb+1;
       Iq=find(I<mpic); 
       if ~isempty(Iq)
           ipic=I(Iq(length(Iq)));
	   if ipic>iumb iumb=ipic;
	   end
       end
     if (Rp-iumb)/Fs>120e-3
        Qex=0; 
     end

% ---- Check that Q wave does not start with a small upslope peak ----
       ilimp=iumb-round(30e-3*Fs);
       if ilimp<=0 ilimp=1; end
       Daux=D(ilimp:iumb);
       [ymin2,imin2]=min(Daux); if ~isempty(imin2) imin2=ilimp+imin2-1; end
       [ymax2,imax2]=max(Daux); if ~isempty(imax2) imax2=ilimp+imax2-1; end
       if abs(ymin2)>=dermax/20
          umbral=(ymin2)/Kq;  
          Daux=flipud(D(1:imin2));
          iumb2=thresholdcross(Daux,umbral);
          iumb2=imin2-iumb2+1;
          if (iumb2>iumb-round(40e-3*Fs))
             iumb=iumb2; 
          end
       end

       if (imax2<imin2 | abs(ymin2)<dermax/20) & abs(ymax2)>dermax/20
           umbral=(ymax2)/Kq; 
           Daux=flipud(D(1:imax2));
           iumb2=thresholdcross(Daux,umbral);
           iumb2=imax2-iumb2+1;
           if (iumb2>iumb-round(40e-3*Fs))
              iumb=iumb2;
           end
        end
     else crece=1;     
   end

% ---- To detect high frequency Q waves, use the unfiltered derivative ----
    if (crece==1)
      Kq=Kq+1;
      [Md,Id]=peaksearch(Der,0);
      Iq=find(Id<ncero);
      if ~isempty(Iq)
          mpic=Id(Iq(length(Iq)));
          mpic=testpeak(Der,mpic,Fs,0);
      end
      if isempty(Iq) | abs(Der(mpic))<dermax/10 | (ncero-mpic)/Fs>30e-3
         Qex=0;   
      end
      if (Qex==1)
         umbral=(Der(mpic))/2.8; 
         Daux=flipud(Der(1:mpic));
         iumb=thresholdcross(Daux,umbral);
         iumb=mpic-iumb+1;
         if (Rp-iumb)/Fs>80e-3 Qex=0; 
         end
      end   
   end
end

% ---- If there is not Q wave, search for the onset of R wave ----
if (Qex==0)
    if D(imax)>=4 Kr=Kr*6-2;
    elseif D(imax)>=3 Kr=Kr*4-2;
    elseif D(imax)>=1.5 Kr=Kr*2-2;
    end
    umbral=D(imax)/Kr;
   
    Daux=flipud(D(1:imax));
    iumb=thresholdcross(Daux,umbral);
    if isempty(iumb)
       iumb=imax-round(30e-3*Fs);
    else 
       iumb=imax-iumb+1;
    end     

% ---- Check that R wave does not start with a small peak ----
    ib=max(1,iumb-round(30e-3*Fs));
    Daux=D(ib:iumb);
    [ymax2,imax2]=max(Daux); if ~isempty(imax2) imax2=ib+imax2-1; end
    if ymax2>=dermax/50 imax=imax2; ymax=ymax2; 
       umbral=ymax2/1.5;
       Daux=flipud(D(1:imax));
       iumb2=thresholdcross(Daux,umbral);
       iumb2=imax-iumb2+1;
       if iumb2>iumb-round(36e-3*Fs) iumb=iumb2; 
       end
    end
end  
if (Qex==1) Qp=ncero; 
else Qp=[];
end 
QRS1=iumb;

if ~isempty(Qp)
   Qp=testpeak(X,Qp,Fs,0);
end


