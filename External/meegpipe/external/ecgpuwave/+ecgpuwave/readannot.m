function anot=readannot(name,heasig,t)
% READANNOT  READS DB-ANNOTATION FILES
%
%	Input parameters: name -> character string with name of annotation file
%			  heasig -> header structure signal
%			  t=[t0 t1] -> vector of interval of reading in samples

% Salvador Olmos
% e-mail: olmos@posta.unizar.es


dim=ceil(heasig.nsamp/heasig.freq*2);
% pre-allocating of memory
anot=struct('time',zeros(dim,1),'anntyp',blanks(dim)','subtyp',blanks(dim)','chan',blanks(dim)','num',blanks(dim)','aux',repmat(blanks(dim)',1,10));

del=1;

% Opening binary file
fida=fopen(name,'rb');
if fida<0
   disp('can not open annotation file');
   keyboard;
end

% Initialization of variables
pos=0; 	% relative position to the beginnning of file
i=1; 	% index of annotation number
currnumfield='0';
currchanfield='0';
subtyp='0';

% Reading of the two first bytes for annotation code
data=fread(fida,2,'uchar');
L=['NLRaVFJASEj/Q~ | sT*D"=pB^t+u?!{}en xf()r'];	% Dictionaty of annotation types


while (~feof(fida) & pos<t(2) ),

	A=data(1)+data(2)*256;
	II=rem(A,1024);  	% Distance (in samples) respect to last annotation
	A=floor(A/1024); 	% Annotation code
        if ((A~=0) & A<=length(L)) anot.anntyp(i)=L(A); end  % JGM 100699
        %if (A~=0)  anot.anntyp(i)=L(A); end

        data=fread(fida,2,'uchar');
        if (feof(fida))  del=0; break; end
	A=data(1)+data(2)*256;
	I=rem(A,1024);
	A=floor(A/1024);
      
        while (A>=59)		% Special annotation codes
  	  if A==59,
		skip=fread(fida,4,'uchar');
		I=skip(3)+256*(skip(4)+256*(skip(1)+256*skip(2)));
		pos=pos+I;
	 	I=0;
	  elseif A==60,
		currnumfield=setstr(I);                                
	  elseif A==61,
		subtyp=num2str(I);
	  elseif A==62,
		currchanfield=setstr(I);
	  elseif A==63,
		if rem(I,2)==1,
			I=I+1;
		end;
                h=setstr(fread(fida,I,'char'))';
		anot.aux(i,1:length(h))=h;
	  end;
	  data=fread(fida,2,'uchar');
          if (feof(fida))  del=0; break; end
   	  A=data(1)+data(2)*256;
	  I=rem(A,1024);
	  A=floor(A/1024);
        end
	 
	pos=pos+II;
	anot.time(i)=pos;
	anot.num(i)=currnumfield;
	anot.chan(i)=currchanfield;
	anot.subtyp(i)=str2num(subtyp);
	subtyp='0';
	i=i+1;

end
fclose(fida);

if i<dim
  anot.anntyp(i:dim)=[];
  anot.time(i:dim)=[];
  anot.num(i:dim)=[];
  anot.subtyp(i:dim)=[];
  anot.chan(i:dim)=[];
  anot.aux(i:dim,:)=[];
end


aux=find(anot.time<t(1) | anot.time>=t(2));
anot.time(aux)=[];
anot.anntyp(aux)=[];
anot.subtyp(aux)=[];
anot.num(aux)=[];
anot.chan(aux)=[];  
anot.aux(i-del,:)=' ';

anot.aux=anot.aux(1:i-1-del,:);


%	if A==0,
%elseif A==1,anot.anntyp(i)='N'; %Normal beat
%elseif A==2,anot.anntyp(i)='L'; %Left bundle branch block beat
%elseif A==3,anot.anntyp(i)='R'; %Right bundle branch block beat
%elseif A==4,anot.anntyp(i)='a'; %Aberrated atrial premature beat
%elseif A==5,anot.anntyp(i)='V'; %Premature ventricular contraction
%elseif A==6,anot.anntyp(i)='F'; %Fusuion of ventricular and normal beat
%elseif A==7,anot.anntyp(i)='J'; %Nodal (junctional) premature beat
%elseif A==8,anot.anntyp(i)='A'; %Atrial premature beat
%elseif A==9,anot.anntyp(i)='S'; %Premature or ectopic supraventricular beat
%elseif A==10,anot.anntyp(i)='E'; %Ventricular escape beat
%elseif A==11,anot.anntyp(i)='j'; %Nodal (junctional) escape beat
%elseif A==12,anot.anntyp(i)='/'; %Paced beat
%elseif A==13,anot.anntyp(i)='Q'; %Unclassifiable beat
%elseif A==14,anot.anntyp(i)='~'; %Signal quality change
%elseif A==15,anot.anntyp(i)=''; %Not specified
%elseif A==16,anot.anntyp(i)='|'; %Isolated QRS-like artifact
%elseif A==17,anot.anntyp(i)=''; %Not specified
%elseif A==18,anot.anntyp(i)='s'; %ST change
%elseif A==19,anot.anntyp(i)='T'; %T-wave change
%elseif A==20,anot.anntyp(i)='*'; %Systole
%elseif A==21,anot.anntyp(i)='D'; %Diastole
%elseif A==22,anot.anntyp(i)='"'; %Comment annotation
%elseif A==23,anot.anntyp(i)='='; %Measurement annotation
%elseif A==24,anot.anntyp(i)='p'; %P-wave peak
%elseif A==25,anot.anntyp(i)='B'; %Left or right bundle branch block
%elseif A==26,anot.anntyp(i)='^'; %Non-conducted pacer spike
%elseif A==27,anot.anntyp(i)='t'; %T-wave peak
%elseif A==28,anot.anntyp(i)='+'; %Rythm change         
%elseif A==29,anot.anntyp(i)='u'; %U-wave peak
%elseif A==30,anot.anntyp(i)='?'; %Learning
%elseif A==31,anot.anntyp(i)='!'; %Ventricular flutter wave
%elseif A==32,anot.anntyp(i)='['; %Start of ventricular flutter/fibrillation
%elseif A==33,anot.anntyp(i)=']'; %End of ventricular flutter/fibrillation
%elseif A==34,anot.anntyp(i)='e'; %Atrial escape beat
%elseif A==35,anot.anntyp(i)='n'; %Supraventricular espace beat
%elseif A==36,anot.anntyp(i)=''; %Not specified
%elseif A==37,anot.anntyp(i)='x'; %Non-conducted P-wave (blocked APB)
%elseif A==38,anot.anntyp(i)='f'; %Fusion of paced and normal beat
%elseif A==39,anot.anntyp(i)='('; %Waveform onset
%elseif A==40,anot.anntyp(i)=')'; %Waveform end
%elseif A==41,anot.anntyp(i)='r'; %R-on-T premature ventricular contraction
%end; % Fin de decodificacion de anotacion
 
 
