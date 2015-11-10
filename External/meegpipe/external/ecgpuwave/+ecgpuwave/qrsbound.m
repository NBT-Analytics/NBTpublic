function [QRS1,Qp,Rp,Sp,R2p,QRS2,dermax,type,Sgran]=qrsbound(n,X,Xpb,D,Der,PKni,prevt,Fs,Kq,Kr,Ks,Krr)

% ---- QRS complex peak positions and limits depending on morphology ---- 

import ecgpuwave.*;

% ---- Initialization ----
QRS1=[]; QRS2=[]; Qp=[]; Rp=[]; Sp=[]; R2p=[]; Rex=0; Qex=0; Sex=0; R2ex=0;
type=0; noR=0; Sgran=0;

% ---- R wave identification ----
[M,I]=peaksearch(D,0);
[QRS1,Rp,Sp,R2p,QRS2,ymaxaux,type,Sgran]=Rwave(n,X,Xpb,D,Der,PKni,M,I,Fs,Kr,Ks,Krr);

Ir=find(I<Rp);
imax=I(Ir(length(Ir))); ymax=M(Ir(length(Ir)));
Ir=find(I>Rp); 
imin=I(Ir(1)); ymin=M(Ir(1));
if type==2 dermax=max(abs(ymax),abs(ymin)); end

% ---- QRS type ----
% Protection against cases in which the derivative presents several
% peaks.
if (type==1)|(type==3)
   if (ymax>ymaxaux/4)
      inicio=Rp-round(70e-3*Fs);
      Daux=D(inicio:Rp);
      [ymaxa,imaxa]=max(Daux); imaxa=inicio+imaxa-1;
      ilim=Rp+round(70e-3*Fs);
      Daux=D(Rp:ilim);
      [ymina,imina]=min(Daux); imina=Rp+imina-1;
      if ymaxa>ymax
         ymax=ymaxa; 
         imax=imaxa; 
      end
      if ymina<ymin
         ymin=ymina;
         imin=imina; 
      end
   end
   dermax=max(abs(ymax),abs(ymin));
   ilim=imax-round(70e-3*Fs);
   ilim2=imax-round(30e-3*Fs);
   if ymax>ymaxaux/4
      Daux=D(ilim:ilim2);
      [ymaxa,imaxa]=max(Daux); imaxa=ilim+imaxa-1;
      if ymaxa>dermax/5
         ymax=ymaxa; imax=imaxa; 
      end
      ilim=imin+round(40e-3*Fs);
      ilim2=imin+round(100e-3*Fs);
      Daux=D(ilim:ilim2);
      [ymina,imina]=min(Daux); imina=ilim+imina-1;
      if abs(ymina)>dermax/5
         ymin=ymina; imin=imina; 
      end
   end
end
   
% ---- QS type ----   
if (type==4)  
   inicia=Rp-round(150e-3*Fs);
   Daux=D(inicia:Rp);
   [ymin,imin]=min(Daux);
   imin=inicia+imin-1; 
   ilim=Rp+round(180e-3*Fs); 
   Daux=D(Rp:ilim);
   [ymax,imax]=max(Daux);
   imax=Rp+imax-1;
   dermax=max(abs(ymax),abs(ymin));

   umbral=ymin/Kr;
   Daux=flipud(D(1:imin));
   QRS1=thresholdcross(Daux,umbral);
   QRS1=imin-QRS1+1;

   ilim=QRS1-round(35e-3*Fs);
   Daux=D(ilim:QRS1);
   [ymax2,imax2]=max(Daux); imax2=ilim+imax2-1;
   [yaux,iaux]=min(Daux); iaux=ilim+iaux-1;

    if (ymax2)>=(dermax/30)
        Daux=flipud(D(1:imax2));
        umbral=ymax2/2;
        iumb2=thresholdcross(Daux,umbral);
        iumb2=imax2-iumb2+1;
        if iumb2>=QRS1-round(30e-3*Fs) 
           QRS1=iumb2;
        end
    end
    if (abs(yaux)>=dermax/30) & (iaux<imax2)
        Daux=flipud(D(1:iaux));
        umbral=yaux/2;
        iumb2=thresholdcross(Daux,umbral);
        iumb2=iaux-iumb2+1;
        if iumb2>QRS1-round(50e-3*Fs) 
           QRS1=iumb2;
        end
    end

    umbral=ymax/Kr;
    Daux=D(imax:length(D));
    QRS2=thresholdcross(Daux,umbral);
    QRS2=imax+QRS2-1;
    ilim=Rp+round(180e-3*Fs);
    if (QRS2-QRS1)/Fs<80e-3
        Daux=D(Rp:ilim);
        [ymax2,imax2]=max(Daux); imax2=Rp+imax2-1;
        if ymax2>ymax
           umbral=ymax2/Kr;
           Daux=D(imax2:length(D));
           QRS2=thresholdcross(Daux,umbral);
           QRS2=imax2+QRS2-1;
        end
    end

    ilim=QRS2+round(20e-3*Fs);
    Daux=D(QRS2:ilim);
    [ymin2,imin2]=min(Daux); 
    if ~isempty(imin2)
        imin2=QRS2+imin2-1;
        [yaux,iaux]=max(Daux); iaux=QRS2+iaux-1;
       if abs(ymin2)>dermax/20
          umbral=ymin2/2;
          Daux=D(imin2:length(D));
          iumb2=thresholdcross(Daux,umbral);
          iumb2=imin2+iumb2-1;
          if iumb2<QRS2+round(30e-3*Fs);
             QRS2=iumb2;
          end
       end
    end
end


% ---- QRS type ----
if (type==1)|(type==3)

% ---- Q wave and QRS onset ----
[Qp,QRS1,type]=Qwave(n,X,D,Der,PKni,Rp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kq,Kr);

% ---- S wave and QRS offset ----
[Sp,QRS2,type,Sgran]=Swave(n,X,D,Der,PKni,Rp,Sp,M,I,ymax,imax,ymin,imin,dermax,type,Sgran,Fs,Kr,Ks);
end

if QRS1<prevt QRS1=prevt+2; end
        
