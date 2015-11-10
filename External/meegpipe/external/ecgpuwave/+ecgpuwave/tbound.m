function [T1,Tp2,Tp,T2,Ttype]=tbound(n,X,Xpa,F,PKni,Rp,QRS1,QRS2,PKnii,dermax,basel,RRm,Fs,ktb,kte,pco)

% ---- T wave delineation ----

import ecgpuwave.*;

T1=[]; T2=[]; Tp=[]; Tp2=[]; Ttype=6; peaks=0;
flag1=1;
kdis=round(50e-3*Fs);
RRav=RRm/Fs;
[M,I]=peaksearch(F,0);
if RRav>900e-3
   itqlim=round(280e-3*Fs);
   ewindt=800e-3;  
elseif RRav>800e-3
   itqlim=round(250e-3*Fs);
   ewindt=600e-3;   
elseif RRav>600e-3
   itqlim=round(200e-3*Fs);
   ewindt=450e-3;    
else itqlim=round(170e-3*Fs);
   ewindt=450e-3;   
end
back=ones(1,6);
bwindt=100e-3;
ibw=Rp+round(bwindt*Fs);
iew=Rp+round(ewindt*Fs);

if n>1
if RRav<750e-3
   ibw=Rp+round(125e-3*Fs);
   iew=Rp+round(RRav*0.6*Fs);
else  
   ibw=Rp+round(bwindt*Fs);
   iew=Rp+round(ewindt*Fs);
end
end

if ibw<=QRS2+kdis
   iew=iew+QRS2-ibw+kdis;
   ibw=QRS2+kdis;
end

if PKnii>0 & iew>PKnii-round(210e-3*Fs)
   iew=PKnii-round(210e-3*Fs);
elseif PKnii==0  
       if Rp+round(400e-3*Fs)<=length(X)
          iew=Rp+round(400e-3*Fs);
          else iew=length(X);
       end
end

% ---- Detecting upslope or downslope T ----
[ymax,imax]=max(F(ibw:iew)); imax=imax+ibw-1;
[ymin,imin]=min(F(ibw:iew)); imin=imin+ibw-1;
if ymin>0 | ymax<0
   if iew==PKnii-round(210e-3*Fs)
      if ymin>0 ymin=0; end
      if ymax<0 ymax=0; end
   else while (ymin>0 | ymax<0) & PKnii>0 & iew<PKnii-round(250e-3*Fs)
         iew=iew+round(25e-3*Fs);
         [ymax,imax]=max(F(ibw:iew));
         imax=imax+ibw-1;
         [ymin,imin]=min(F(ibw:iew));
         imin=imin+ibw-1;
        end
   end
end

while (flag1==1)&(iew>ibw)
peaks=0;
kint1=round(250e-3*Fs);
kint2=round(300e-3*Fs);
kend=50;
ampmi=0.075;
kk=3;
com=0.3;
if (-com*ymin<ymax & -ymin>com*ymax)
   if imin<imax
      [ymaxa,imaxa]=max(F(ibw:imin));
      imaxa=imaxa+ibw-1;
      [yminp,iminp]=min(F(imax:iew));
      iminp=iminp+imax-1;
      if (ymaxa<ymax/kk & -yminp<-ymin/kk) | (ymaxa>=ymax/kk&-yminp>=-ymin/kk)
         Ttype=1;
      elseif ymaxa>=ymax/kk | -yminp>=-ymin/kk
         peaks=1;
      end
   else [ymina,imina]=min(F(ibw:imax));
      imina=imina+ibw-1;
      [ymaxp,imaxp]=max(F(imin:iew));
      imaxp=imaxp+imin-1;
      if (ymaxp<ymax/kk&(-ymina)<(-ymin)/kk) | (ymaxp>=ymax/kk&(-ymina)>=(-ymin)/kk)
         Ttype=0;
      elseif ymaxp>=ymax/kk | (-ymina)>=(-ymin)/kk
         peaks=1;
      end
   end
else peaks=1;
end

% ---- Different peaks ----
if (peaks==1)
   if ymax>abs(ymin)
      [ymina,imina]=min(F(ibw:imax));
      imina=imina+ibw-1;
      [yminp,iminp]=min(F(imax:iew));
      iminp=iminp+imax-1;
      Faux=F(imina:length(F));
      ncea=imina;
      if ymina<0
      ncea=zerocross(Faux);
      ncea=imina+ncea-1;
      end 
      ampa=basel-X(ncea); 
      Faux=flipud(F(1:iminp));
      ncep=iminp;
      if yminp<0
      ncep=zerocross(Faux);
      ncep=iminp-ncep+1;
      end
      ampp=X(ncep)-basel;
      if (ampa+ampp)>ampmi
         if -ymina<ymax/pco & -yminp<ymax/pco
            Ttype=2;
         elseif -ymina>=ymax/pco & -yminp>=ymax/pco
            Ttype=4; 
         elseif -ymina>=ymax/pco & -yminp<ymax/pco
            Ttype=1; 
            ymin=ymina; imin=imina;
         elseif -ymina<ymax/pco & -yminp>=ymax/pco
            Ttype=0;
            ymin=yminp; imin=iminp;
         end
      else Ttype=6;
      end
            
   elseif ymax<abs(ymin)
      [ymaxa,imaxa]=max(F(ibw:imin));
      imaxa=imaxa+ibw-1;
      [ymaxp,imaxp]=max(F(imin:iew));
      imaxp=imaxp+imin-1;
      Faux=F(imaxa:length(F));
      ncea=imaxa;
      if ymaxa>0
      ncea=zerocross(Faux);
      ncea=imaxa+ncea-1;
      end
      ampa=X(ncea)-basel;
      Faux=flipud(F(1:imaxp));
      ncep=imaxp;
      if ymaxp>0
      ncep=zerocross(Faux);
      ncep=imaxp-ncep+1;
      end
      ampp=basel-X(ncep);
      if (ampa+ampp)>ampmi
         if ymaxa<-ymin/pco & ymaxp<-ymin/pco
            Ttype=3; 
         elseif ymaxa>=-ymin/pco & ymaxp>=-ymin/pco
            Ttype=5;
         elseif ymaxa>=-ymin/pco & ymaxp<-ymin/pco
            Ttype=0; 
            ymax=ymaxa; imax=imaxa;
         elseif ymaxa<-ymin/pco & ymaxp>=-ymin/pco
            Ttype=1;
            ymax=ymaxp; imax=imaxp;
         end
      else Ttype=6;
      end 
      end
end


% ---- Normal or inverted T wave ----
if (Ttype==0)|(Ttype==1)
Tp2=[];
   if (Ttype==1) 
      yaux=ymax; iaux=imax;
      ymax=ymin; imax=imin;
      ymin=yaux; imin=iaux;
   end
   umbral=(ymax)/ktb;
   Faux=flipud(F(1:imax));
   iumba=thresholdcross(Faux,umbral);
   iumba=imax-iumba+1;
    
   if (iumba<=QRS2)
      It=find(I<imax);
      if ~isempty(It)
      	iumba=I(It(length(It)));
      	if iumba<=QRS2
         	iumba=QRS2+2;
      	end
      end
   end
   T1=iumba;
   if abs(ymin)>=0.41 kte1=kte*2;
   elseif abs(ymin)>=0.35 kte1=kte*2-1;
   elseif abs(ymin)>=0.25 kte1=kte*2-2;
   elseif abs(ymin)>=0.10 kte1=kte*2-3;
   elseif abs(ymin)<0.10 kte1=kte;
   end
   if kte/back(1)>=1.1
      umbral=ymin*back(1)/kte1;
   else umbral=ymin/1.1;
   end
   Faux=F(imin:length(F));
   iumbp=thresholdcross(Faux,umbral);
   iumbp=imin+iumbp-1;
   T2=iumbp; 
   Faux=flipud(F(1:imin));
   icero1=zerocross(Faux);
   icero1=imin-icero1+1;
   Faux=F(imax:length(F));
   icero2=zerocross(Faux);
   icero2=imax+icero2-1;
   icero=round((icero1+icero2)/2);
   if (icero>=T2 | icero<=T1)
      icero=T1+round((T2-T1)/2);
   end
   Tp=icero;
   back(1)=back(1)*1.8;
   
% ---- Upslope or downslope T wave ----
elseif (Ttype==2)|(Ttype==3)
T1=[]; Tp2=[];
   if (Ttype==3) ymax=ymin; imax=imin; end
   if abs(ymax)>=0.41 kte1=kte*2;      
   elseif abs(ymax)>=0.30 kte1=kte*2-1;
   elseif abs(ymax)>=0.20 kte1=kte*2-2;
   elseif abs(ymax)>0.10 kte1=kte*2-3;
   elseif abs(ymax)<=0.10 kte1=kte;
   end
   if kte/back(3)>=1.1
      umbral=(ymax)*back(3)/kte1;
   else umbral=ymax/1.1;
   end
   Faux=F(imax:length(F));
   iumbp=thresholdcross(Faux,umbral);
   iumbp=imax+iumbp-1;
   T2=iumbp;
   Faux=flipud(F(1:imax));
   icero=zerocross(Faux);
   icero=imax-icero+1;
   It=find(I<(imax-kdis));
   if ~isempty(It)
   	ipic=I(It(length(It)));
      	Tp=max(ipic,icero);
   	if Tp<=QRS2 Tp=QRS2+1; end
   end
   back(3)=back(3)*1.8;
 
   % ---- Biphasic T wave ----
elseif (Ttype==4)|(Ttype==5)
   if (Ttype==5)
      ymina=ymaxa; imina=imaxa;
      ymax=ymin; imax=imin;
      yminp=ymaxp; iminp=imaxp;
   end
   umbral=(ymina)/ktb;
   Faux=flipud(F(1:imina));
   iumba=thresholdcross(Faux,umbral);
   iumba=imina-iumba+1;
   if (iumba<=QRS2)
      It=find(I<imina);
      if ~isempty(It)
      	iumba=I(It(length(It)));
      	if iumba<=QRS2
         	iumba=QRS2+2;
      	end
      end
   end
   T1=iumba;
   if abs(yminp)>=0.41 kte1=kte*2;    
   elseif abs(yminp)>=0.30 kte1=kte*2-1;
   elseif abs(yminp)>=0.20 kte1=kte*2-2;
   elseif abs(yminp)>=0.10 kte1=kte*2-3;
   elseif abs(yminp)<0.10 kte1=kte;
   end
   if kte/back(5)>=1.1
      umbral=(yminp)*back(5)/kte1;
   else umbral=yminp/1.1;
   end
   Faux=F(iminp:length(F));
   iumbp=thresholdcross(Faux,umbral);
   iumbp=iminp+iumbp-1;
   T2=iumbp;
   Faux=flipud(F(1:iminp));
   icero1=zerocross(Faux);
   icero1=iminp-icero1+1;
   Tp=icero1;
   Faux=F(imina:length(F));
   icero2=zerocross(Faux);
   icero2=imina+icero2-1;
   Tp2=icero2;
   if Tp<Tp2 Tp=Tp2; end
   back(5)=back(5)*1.8;
end 

% ---- Validation ----
if (T2-QRS1)<950e-3*Fs&((PKnii-T2>itqlim)|(PKnii==0)|(T2-QRS1<400e-3*Fs))
   flag1=0;
else 
   if iew>ibw+100e-3*Fs
      iew=iew-round(50e-3*Fs);
      else iew=iew-round(25e-3*Fs);
   end
   [ymin,imin]=min(F(ibw:iew)); imin=ibw+imin-1;
   [ymax,imax]=max(F(ibw:iew)); imax=ibw+imax-1;
end
end
if T2>PKnii-round(100e-3*Fs)&(PKnii~=0)
   Ttype=6;
end
if Ttype==6 T1=[]; Tp2=[]; Tp=[]; T2=[]; end




