function [QRS1,Rp,Sp,R2p,QRS2,ymaxaux,type,Sgran]=Rwave(n,X,Xpb,D,Der,PKni,M,I,Fs,Kr,Ks,Krr)

% ---- QRS complex classification ----
% In RSR' type significative points are returned, 
% in QRS and QR types, R and S wave positions, are returned respectively.

import ecgpuwave.*;

% ---- Initialization ----
QRS1=[]; QRS2=[]; Qp=[]; Rp=[]; Sp=[]; R2p=[]; Rex=0; Qex=0; Sex=0; R2ex=0;
type=0; noR=0; Sgran=0; 

% ---- Previous and former peaks ----

Ir=find(I>PKni); mpicd=I(Ir(1));
Ir=find(I<PKni); mpici=I(Ir(length(Ir)));

% ---- RSR' type? ----
ydi=D(mpici);
ydd=D(mpicd);
ymaxaux=max(abs(ydd),abs(ydi));
kpi=2;

if (Xpb(PKni)<0)|(ydi>0&ydd<0&(kpi*ydi<(-1)*ydd|kpi*(-1)*ydd<ydi))
   perc=0.25;
   if (Xpb(PKni)>0&ydi>0&ydd<0)|((1+perc)*(-1)*ydi>ydd&(1-perc)*(-1)*ydi<ydd)
      % ---- RSR'type ----
      type=2;
      perc=0.35;
      if (Xpb(PKni)<0)
         % ---- PKni corresponds to S wave, R' will be on the right and R
         % on the left ----
         Daux=D(mpicd:length(D));
         ncero=zerocross(Daux);
	 if isempty(ncero) return; end
         ncero=mpicd+ncero-1;
         Ir=find(I>ncero);
	 if ~isempty(Ir) mpda=I(Ir(1));
  	       if ((-1*D(mpda)<ydd/5) & (abs(Xpb(ncero))<abs(Xpb(PKni))/10))  % JGM
    	        type=3; % ---- Very large Q or S wave ----
     	    else
      	      R2p=ncero;
       	      Sp=PKni;
              Daux=flipud(D(1:mpici));
              ncero=zerocross(Daux);
            if isempty(ncero) return; end
            ncero=mpici-ncero+1;
            Ir=find(I<ncero);
	        if ~isempty(Ir)
		        mpda=I(Ir(length(Ir)));
   	         if ((D(mpda)<-ydi/5) & (abs(Xpb(ncero))<abs(Xpb(PKni))/10))  % JGM
    	           type=3; % ---- Very large Q or S wave ----
     	         else
        	       Rp=ncero;
         	 end
	      end
	    end
         end
      elseif abs(ydi)<abs(ydd)
         % ---- PKni corresponds to R wave ----
             Daux=D(mpicd:length(D));
             ncero=zerocross(Daux);
             if isempty(ncero) return; end 
            ncero=mpicd+ncero-1;		
             Ir=find(I>ncero); 
	     if ~isempty(Ir) 
		mpic=I(Ir(1));
                if ~((1+perc)*abs(ydd)>abs(D(mpic))&(1-perc)*abs(ydd)<abs(D(mpic)))
                type=1; % ---- Normal QRS type ----
                else 
       	         Sp=ncero;
        	 Daux=D(Sp:length(D));
                 ncero=zerocross(Daux);
		 if isempty(ncero) return; end
                 ncero=Sp+ncero-1;
                 R2p=ncero;
                 Rp=PKni;
                end
	      end

      elseif abs(ydi)>abs(ydd)
            % ---- PKnii corresponds to R' wave ----
            Daux=flipud(D(1:mpici));
            ncero=zerocross(Daux);
            if isempty(ncero) return; end
            ncero=mpici-ncero+1;	    
            Ir=find(I<ncero);
	    if ~isempty(Ir)
		 mpic=I(Ir(length(Ir)));
                 if (~((1+perc)*abs(ydi)>abs(D(mpic))&(1-perc)*abs(ydi)<abs(D(mpic))))
               type=1; % ---- Normal QRS type ----
                 else 
                  Sp=ncero;
                  Daux=flipud(D(1:Sp));
                  ncero=zerocross(Daux);
                  if isempty(ncero) return; end
                  ncero=Sp-ncero+1;
                  Rp=ncero;
                  R2p=PKni;
                 end
	     end
      end
      if (type==2)&(R2p-Rp)/Fs>150e-3
            if Xpb(PKni)>0
               type=1;  % ---- Normal QRS type ----
            else type=3; % ---- Very large Q or S wave ----
            end
      end
   else type=3; % ---- Very large Q or S wave ----  
   end
else type=1;   % ---- Normal QRS type ----
end
   

% ---- Onset and offset of RSR' ----
if (type==2)
      Ir=find(I>R2p); mpicd=I(Ir(1));
      Ir=find(I<Rp); mpici=I(Ir(length(Ir)));
      R2p=testpeak(X,R2p,Fs,1);
      Sp=testpeak(X,Sp,Fs,0);
      Rp=testpeak(X,Rp,Fs,1);
      umbral=D(mpicd)/Krr;
      Daux=D(mpicd:length(D));
      QRS2=thresholdcross(Daux,umbral);
      QRS2=mpicd+QRS2-1;
      if isempty(QRS2) return; end
      umbral=X(QRS2);
      Xaux=flipud(X(1:R2p));
      S1=thresholdcross(Xaux,umbral);
      S1=R2p-S1+1;
      umbral=D(mpici)/Kr;
      Daux=flipud(D(1:mpici));
      QRS1=thresholdcross(Daux,umbral);
      QRS1=mpici-QRS1+1;
      if isempty(QRS1) return; end
      umbral=X(QRS1);
      Xaux=X(Rp:length(X));
      Q2=thresholdcross(Xaux,umbral);
      Q2=Rp+Q2-1;
end


% ---- R wave location in the very large Q or S wave case ----
if (type==3)
      R2p=[]; Rp=[]; Sp=[];
      Daux=D(mpicd:length(D));
      nrted=zerocross(Daux);
      nrted=mpicd+nrted-1;
      Daux=flipud(D(1:mpici));
      nrtei=zerocross(Daux);
      nrtei=mpici-nrtei+1;
      prr=1.4;
      if (abs(D(mpicd))>prr*abs(D(mpici))|(PKni-nrtei)>(nrted-PKni))
         % ---- PKni corresponds to Q wave, R wave will be on the right
 % ----
         Daux=D(mpicd:length(D));
         ncero=zerocross(Daux);
  	 if isempty(ncero) return; end
 	 ncero=mpicd+ncero-1;
         Ir=find(I>ncero); mpda=I(Ir(1));
         if (ncero-PKni)/Fs>150e-3|(-1)*D(mpda)<ydd/10
            Sgran=1;
         else Rp=ncero;
         end
      else Sgran=1;
      end
      if Sgran==1
         % ---- PKni corresponds to S wave, R wave will be on the left ---- 
         Daux=flipud(D(1:mpici));
         ncero=zerocross(Daux);
  	 if isempty(ncero) return; end
         ncero=mpici-ncero+1;
         ilim=ncero-round(60e-3*Fs);
         if ilim<=0 ilim=1; end
         Daux=D(ilim:ncero);
	 if (~isempty(Daux))
         	[ymax2,imax2]=max(Daux);
	 	imax2=ilim+imax2-1;
       		  %if (PKni-ncero)/Fs>140e-3|(ymax2<(-1)*ydi/10)|((Xpb(ncero))<-abs(Xpb(PKni))*1/6)
	         if (PKni-ncero)/Fs>140e-3|(ymax2<(-1)*ydi/100)|(Xpb(ncero)<-abs(Xpb(PKni))*1/3)  			%JGM
            	Rp=PKni;  
            	type=4;  % ---- QS type ----
         else Rp=ncero;
	 end
         end
      end
end


% ---- R wave location in the normal QRS type ----
if (type==1)
      Rp=PKni;
      R2p=[];
end

