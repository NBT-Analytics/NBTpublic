function [QRS1,Rp,Sp,R2p,QRS2,ymaxaux,type,Sgran]=buscaR(n,X,Xpb,D,Der,PKni,M,I,Fs,Kr,Ks,Krr)

%Clasifica el complejo QRS. En el caso RSR' halla
%los puntos significativos. En los casos QRS y QS devuelve
%la posición de la onda R y S respectivamente.


%Inicializacion variables.
QRS1=[]; QRS2=[]; Qp=[]; Rp=[]; Sp=[]; R2p=[]; Rex=0; Qex=0; Sex=0; R2ex=0;
type=0; noR=0; Sgran=0; 

%Busca pico a la derecha y la izquierda de la posición del QRS.

Ir=find(I>PKni); mpicd=I(Ir(1));
Ir=find(I<PKni); mpici=I(Ir(length(Ir)));

%Determinamos si nos encontramos en el caso RSR'.
ydi=D(mpici);
ydd=D(mpicd);
ymaxaux=max(abs(ydd),abs(ydi));
kpi=2;

if (Xpb(PKni)<0)|(ydi>0&ydd<0&(kpi*ydi<(-1)*ydd|kpi*(-1)*ydd<ydi))
   perc=0.25;
   if (Xpb(PKni)>0&ydi>0&ydd<0)|((1+perc)*(-1)*ydi>ydd&(1-perc)*(-1)*ydi<ydd)
      %Estamos en el caso RSR'.
      type=2;
      perc=0.35;
      if (Xpb(PKni)<0)
         %PKni corresponde a la onda S, R' estará 
         %a la derecha y R a la izquierda.
         Daux=D(mpicd:length(D));
         ncero=buscacero(Daux);
	 if isempty(ncero) break; end
         ncero=mpicd+ncero-1;
         Ir=find(I>ncero);
	 if ~isempty(Ir) mpda=I(Ir(1));
   	      %if (-1*D(mpda)<ydd/2)
  	       if ((-1*D(mpda)<ydd/5) & (abs(Xpb(ncero))<abs(Xpb(PKni))/10))  % JGM
    	        type=3; %disp('tipo 3.1'); %Estamos en el caso de Q ó S muy grande.
     	    else
      	      R2p=ncero;
       	      Sp=PKni;
              Daux=flipud(D(1:mpici));
              ncero=buscacero(Daux);
	      if isempty(ncero) break; end
              ncero=mpici-ncero+1;
              Ir=find(I<ncero);
	      if ~isempty(Ir)
		 mpda=I(Ir(length(Ir)));
  	          %if D(mpda)<-ydi/2
   	         if ((D(mpda)<-ydi/5) & (abs(Xpb(ncero))<abs(Xpb(PKni))/10))  % JGM
    	           type=3; %disp('tipo 3.2'); %Estamos en el caso de Q ó S muy grande.
     	         else
        	       Rp=ncero;
         	 end
	      end
	    end
         end
      elseif abs(ydi)<abs(ydd)
         %PKni corresponde a la onda R.
             Daux=D(mpicd:length(D));
             ncero=buscacero(Daux);
             if isempty(ncero) break; end 
	     ncero=mpicd+ncero-1;		
             Ir=find(I>ncero); 
	     if ~isempty(Ir) 
		mpic=I(Ir(1));
                if ~((1+perc)*abs(ydd)>abs(D(mpic))&(1-perc)*abs(ydd)<abs(D(mpic)))
                type=1; %Estamos en el caso de QRS normal.
                else 
       	         Sp=ncero;
        	 Daux=D(Sp:length(D));
                 ncero=buscacero(Daux);
		 if isempty(ncero) break; end
                 ncero=Sp+ncero-1;
                 R2p=ncero;
                 Rp=PKni;
                end
	      end

      elseif abs(ydi)>abs(ydd)
            %PKnii corresponde a la onda R'.
            Daux=flipud(D(1:mpici));
            ncero=buscacero(Daux);
            ncero=mpici-ncero+1;
	    if ~isempty(ncero) break; end
            Ir=find(I<ncero);
	    if ~isempty(Ir)
		 mpic=I(Ir(length(Ir)));
                 if (~((1+perc)*abs(ydi)>abs(D(mpic))&(1-perc)*abs(ydi)<abs(D(mpic))))
               type=1; %Estamos en el caso de QRS normal.
                 else 
                  Sp=ncero;
                  Daux=flipud(D(1:Sp));
                  ncero=buscacero(Daux);
                  if isempty(ncero) break; end
                  ncero=Sp-ncero+1;
                  Rp=ncero;
                  R2p=PKni;
                 end
	     end
      end
      if (type==2)&(R2p-Rp)/Fs>150e-3
            if Xpb(PKni)>0
               type=1;  %QRS normal.
            else type=3; %disp('tipo 3.3');  %Onda Q ó S muy grande.
            end
      end
   else type=3; %disp('tipo 3.4');  %Onda Q ó S muy grande.  
   end
else type=1;   %QRS normal.
end
   

%Buscamos inicio y final del RSR'.
if (type==2)
      Ir=find(I>R2p); mpicd=I(Ir(1));
      Ir=find(I<Rp); mpici=I(Ir(length(Ir)));
      %Ajuste de los picos del complejo QRS.
      R2p=testpic(X,R2p,Fs,1);
      Sp=testpic(X,Sp,Fs,0);
      Rp=testpic(X,Rp,Fs,1);
      umbral=D(mpicd)/Krr;
      Daux=D(mpicd:length(D));
      QRS2=crearumbral(Daux,umbral);
      QRS2=mpicd+QRS2-1;
      if isempty(QRS2) break; end
      umbral=X(QRS2);
      Xaux=flipud(X(1:R2p));
      S1=crearumbral(Xaux,umbral);
      S1=R2p-S1+1;
      umbral=D(mpici)/Kr;
      Daux=flipud(D(1:mpici));
      QRS1=crearumbral(Daux,umbral);
      QRS1=mpici-QRS1+1;
      if isempty(QRS1) break; end
      umbral=X(QRS1);
      Xaux=X(Rp:length(X));
      Q2=crearumbral(Xaux,umbral);
      Q2=Rp+Q2-1;
end


%Localizamos la onda R en el caso de onda Q ó S muy grande.
if (type==3)
      %Onda Q ó S muy grandes.
      R2p=[]; Rp=[]; Sp=[];
      %Buscamos la onda R.
      Daux=D(mpicd:length(D));
      nrted=buscacero(Daux);
      nrted=mpicd+nrted-1;
      Daux=flipud(D(1:mpici));
      nrtei=buscacero(Daux);
      nrtei=mpici-nrtei+1;
      prr=1.4;
      if (abs(D(mpicd))>prr*abs(D(mpici))|(PKni-nrtei)>(nrted-PKni))
         %PKni corresponde a la onda Q, la onda R
         %estará en el primer cero a la derecha.
         Daux=D(mpicd:length(D));
         ncero=buscacero(Daux);
  	 if isempty(ncero) break; end
 	 ncero=mpicd+ncero-1;
         Ir=find(I>ncero); mpda=I(Ir(1));
         if (ncero-PKni)/Fs>150e-3|(-1)*D(mpda)<ydd/10
            Sgran=1;
         else Rp=ncero;
         end
      else Sgran=1;
      end
      if Sgran==1
         %PKni corresponde a la onda S, la onda R
         %estará en el primer cero a la izquierda.
         Daux=flipud(D(1:mpici));
         ncero=buscacero(Daux);
  	 if isempty(ncero) break; end
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
            	type=4;  %Tipo complejo QS.
         else Rp=ncero;
	 end
         end
      end
end


%Localizamos la onda R en el caso de QRS normal.
if (type==1)
      Rp=PKni;
      R2p=[];
end

