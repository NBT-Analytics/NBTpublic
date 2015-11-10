function [P1,Pp,P2,type]=pbound(n,X,Xpb,F,PKni,Rp,QRS1,prevt,dermax,Fs,Kpb,Kpe)

% ---- P wave detection ----

import ecgpuwave.*;

Pex=1; P1=[]; Pp=[]; P2=[];
type=0;
nofi=1;
bwindp=200e-3;
ewindp=30e-3;
iew=QRS1-round(ewindp*Fs);
ibw=QRS1-round(bwindp*Fs);
if ibw<=0 ibw=1; end

while (nofi==1)&isempty(Pp)&(QRS1-ibw)/Fs<300e-3
if n==1|prevt==0
   nofi=0;
else if ibw<prevt
        ibw=prevt;
        nofi=0;
     else nofi=1;
     end
end

if ibw>iew Pex=0; type=2; 
   else
[ymin,imin]=min(F(ibw:iew)); imin=imin+ibw-1;
[ymax,imax]=max(F(ibw:iew)); imax=imax+ibw-1;
if (imin<=imax) & (QRS1-imax)/Fs<30e-3
   iew=QRS1-round(30e-3*Fs);
   ibw=ibw-round(30e-3*Fs);
   [ymin,imin]=min(F(ibw:iew)); imin=imin+ibw-1;
   [ymax,imax]=max(F(ibw:iew)); imax=imax+ibw-1;
end
Xaux=Xpb(QRS1-round(15e-3*Fs):QRS1-1);
base=mean(Xaux);
ecgpbmax=max(abs(Xpb(ibw:iew)-base));

if (ecgpbmax<=abs(Xpb(PKni)-base)/30) | ((ymax<dermax/(100)&abs(ymin)<dermax/(100))&(ymax<abs(ymin)/1.5|ymax>abs(ymin)*1.5)) |  (ymax<0 | ymin>0) 
   Pex=0; type=2;
else if imin<=imax 
      type=1;
      iaux=imin; yaux=ymin;
      imin=imax; ymin=ymax;
      imax=iaux; ymax=yaux;
   end
   % ---- P wave onset ----
   umbral=(ymax/Kpb);
   Faux=flipud(F(1:imax));
   iumb=thresholdcross(Faux,umbral);
   if isempty(iumb) iumb=imax;
   else
   iumb=imax-iumb+1; end
      while Pex==1 & ((QRS1-iumb)/Fs>=240e-3 | iumb<=prevt)
      ibw=ibw+20;
      if ibw>iew-round(20e-3*Fs)
         Pex=0; type=2;
      else [ymin2,imin2]=min(F(ibw:iew)); 
         imin2=imin2+ibw-1;
         [ymax2,imax2]=max(F(ibw:iew));
         imax2=imax2+ibw-1;
         Faux=flipud(F(1:imax2));
         iumb=thresholdcross(Faux,umbral);
         iumb=imax2-iumb+1;
      end
    end
    if Pex==1
       P1=iumb;
    end

    % ---- P wave position ----
   if Pex==1
   Faux=F(imax:QRS1);
   icero1=zerocross(Faux); icero1=imax+icero1-1;
   Faux=flipud(F(1:imin));
   icero2=zerocross(Faux); icero2=imin-icero2+1;
   Pp=round((icero1+icero2)/2); 
   
   % ---- Check noise level ----
   inic=P1-40+1;
   fin=P1-5;
   if inic<=0 inic=1; end
   if fin<=0 fin=1; end
   Xaux=X(inic:fin);
   ruido=noiselevel(Xaux);
   if abs(Xpb(P1)-Xpb(Pp))<1.5*ruido & (Pp-P1)/Fs<40e-3
      Pex=0; type=2; 
      P1=[]; Pp=[];
   end
   end

    % ---- P wave offset ----
    if Pex==1
    umbral=(ymin)/Kpe;
    Faux=F(imin:length(F));
    iumb=thresholdcross(Faux,umbral);
    iumb=imin+iumb-1;
    if iumb>=QRS1
       [ymin,iumb]=min(F(imin:QRS1)); 
       iumb=imin+iumb-1;
    end
    P2=iumb;
    if P2>=QRS1
       P2=QRS1-1;
    end
 end
end

% ---- Check noise level ----
if (Pex==1)
Xaux=X(ibw:iew);
ruido=noiselevel(Xaux);
if abs(Xpb(Pp)-Xpb(P2))<=(1.5*ruido)
   Pex=0; P1=[]; Pp=[]; P2=[]; type=2;
end
end

% ---- Validation ----
if (Pex==1)
if P1>=P2|Pp<=P1|Pp>=P2|P1<=prevt|(P2-P1)/Fs>180e-3|(P2-P1)/Fs>150e-3
   Pex=0; P1=[]; Pp=[]; P2=[]; type=2;
end
else P1=[]; Pp=[]; P2=[];
end
end
iew=iew-round(50e-3*Fs);
ibw=ibw-round(50e-3*Fs);
end
