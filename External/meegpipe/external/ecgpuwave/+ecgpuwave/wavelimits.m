function [annt,annAmp,banot,QT,QTC,QW,RW,SW,QRS]=wavelimits(dirhea,dirsig,dirann,ecgnr,anot,typerec,res,nl,ti,tf,nbo_flag,Kq,Kr,Ks,Krr,Kpb,Kpe,Ktb,Kte,pco)

%----- Principal program  ----------------------
%ECG wave limits detection.
%
%Input parameters:
%  dirhea: header directory
%  dirsig: signal directory
%  dirann: annotator directory
%  ecgnr: record name
%  anot: annotator name; 0 if not DB-annotation file
%  typerec: type of recording (0:MIT-DB, 1:Lund-Siemens)
%  res: results format (0: struct, 1: text file)
%  nl: leads (1:12)
%  ti: begin time of processing in s.
%  tf: end time of processing in s.
%  nbo_flag: rejection of non-normal beats and neighbours (0:not applied, 1:applied)
%  Kq: threshold Q-wave begin.
%  Kr: threshold R-wave begin and end.
%  Ks: threshold S-wave end.
%  Krr: threshold R'-wave end.
%  Kpb: threshold P-wave begin.
%  Kpe: threshold P-wave end.
%  Ktb: threshold T-wave begin.
%  Kte: threshold T-wave end.
%  pco: threshold T-wave morphology classification.
%
%Output parameter:
%  banot: struct with the annotator.
%  annt: struct with wave limits: Ponset, P, Poffset,
%  QRSonset, Q, R, fiducial point, S, R2, QRSoffset, Tonset, T, T2,
%  Toffset.
%  annAmp: struct with wave amplitudes: P, Q, R, S, R2, T, T2.
%  QT, QTC, QW, RW, SW, QRS: structs with position and values of the
%  different waves and intervals.


%Default parameters.

if nargin<7
   res=0;
end
if nargin<8
   nl=1;
end
if nargin<9
   ti=0;
end
if nargin<10
   tf=Inf;
end
if nargin<11
   nbo_flag=0;
end
if nargin<12  Kq=1.5; end
if nargin<13  Kr=5; end
if nargin<14  Ks=3; end
if nargin<15  Krr=5; end
if nargin<16  Kpb=1.35; end
if nargin<17  Kpe=2; end
if nargin<18  Ktb=2; end
if nargin<19  Kte=3.5; end
if nargin<20  pco=8; end


fidan=0;

t=[ti tf];

% ----  Getting header of the signal  ----

heasig=readheader([dirhea ecgnr '.hea']);

if ~isempty(t) t=round(t*heasig.freq); 
end
if isempty(t)  t=[1 round(heasig.nsamp-0.1*heasig.freq)]; end
if t(1) < 1, t(1) = 1; end
if t(2) == Inf, t(2) = round(heasig.nsamp-0.1*heasig.freq); end

if anot~=0,
anname=[dirann ecgnr '.' anot]; 
annot=readannot([dirann ecgnr '.' anot],t); 
else
    disp('DB-annotation file needed')
    return;
end

no_leads=heasig.nsig;
if nl>no_leads
   disp('There are not nl signals at the record');
   return;
end

Fs=round(heasig.freq);
nsamp=heasig.nsamp;
timeoffset=0;
if tf>nsamp tf=nsamp; end

if typerec==0,
    if (heasig.fmt(nl)==16) | (heasig.fmt(nl)==212) | (heasig.fmt(nl)==61),
        formato = num2str(heasig.fmt(nl));
    else
        error('This format is not supported by the program')
    end
end

if strcmp(formato,'16')|strcmp(formato,'61'),
       fid = fopen([dirsig heasig.fname(nl,:)],'rb');
       fseek(fid,0,-1);  % Rewind the file
       if strcmp(heasig.fname(nl,1),'_'),  % Siemens card recordings with MIT-type header
            timeoffset=512;
            fseek (fid, timeoffset,-1); % offset
       end 
end

if typerec==0,
   fid = fopen([dirsig heasig.fname(nl,:)],'rb');
   gain=heasig.gain(nl);
   ioffset=heasig.adczero(nl);
   if gain>0 gain=round(gain);
   else gain=200;
   end
 %  if ioffset==0
 %     v=getvec(fid,heasig,1,2*Fs);
 %     ioffset=mean(v(:,nl));
 %  end
end

rmax=0;
index=0;
ilastqrs=0;
fin=0;
ns=0;
prewindt=0;
a1=1;
qt1=1;
q1=1;
r1=1;
s1=1;
qrs1=1; nt1=1;
QT.pos=[]; QT.val=[]; 
QTC.pos=[]; QTC.val=[];
QW.pos=[]; QW.val=[];
RW.pos=[]; RW.val=[];
SW.pos=[]; SW.val=[];
QRS.pos=[]; QRS.val=[];
annt.Ponset=[]; annt.P=[]; annt.Poffset=[]; annt.QRSonset=[]; annt.Q=[];
annt.R=[]; annt.fiducial=[]; annt.S=[]; annt.R2=[]; annt.QRSoffset=[];
annt.Tonset=[]; annt.T=[]; annt.T2=[]; annt.Toffset=[];
annAmp.P=[]; annAmp.Q=[]; annAmp.R=[]; annAmp.S=[]; annAmp.R2=[]; annAmp.T=[]; annAmp.T2=[];
banot.time=[]; banot.anntyp=[]; banot.subtyp=[]; banot.num=[]; banot.chan=[];

% ----  Removing of non-QRS annotations  ----
annot=isqrs(annot,heasig,t);

if isempty(annot.time), disp('no events detected'), return, end
no_beats=length(annot.time);

% ---- Removing of non-NORMAL labelled beats and adjacents ----
if nbo_flag==1
   [annot,rr]=isnormal(annot,heasig,t,rr);
   no_beats=length(annot.time);
end

s=sprintf('%s.b%d',ecgnr,nl-1);
if res==1
fidan=fopen(s,'wt+');
end

% ---- Reading signal segments ----
ti=t(1);
nlat=100;
iqrs=zeros(1,nlat);
atyp=char(zeros(1,nlat)); 
ilat=1;
nlat=min(nlat,length(annot.time));
while ilat<no_beats-3
   flat=ilat+nlat+3;
   if nlat+3>=length(annot.time)
      tf=annot.time(nlat)+round(2*heasig.freq);
      flat=length(annot.time);
      nlat=nlat-3;
   else tf=annot.time(flat)+round(2*heasig.freq);
   end
   ta=annot.time(ilat:flat);
   antyp=annot.anntyp(ilat:flat);

   if typerec==0 % MIT format
        if strcmp(formato,'212'),  % !!!!! Different formats (heasig)
            X = rdsign212([dirsig ecgnr '.dat'],heasig.nsig,ti+1,tf);
        elseif strcmp(formato,'16')|strcmp(formato,'61'),
            fseek(fid, timeoffset+2*(ti)*heasig.nsig, -1); % Locate the pointer
            X = fread(fid,[heasig.nsig tf-ti] ,'int16')';
            if (strcmp(computer,'SOL2')&strcmp(formato,'16'))|(~strcmp(computer,'SOL2')&strcmp(formato,'61')),
                X=swap16(sig);
            end
        end
        X = X(:,nl);   % Only selected lead
        X = (X - heasig.adczero(nl))/heasig.gain(nl); % mV
   elseif typerec==1  % LUND format
        X=getsig(dirsig,ecgnr,[ti+1,tf],nl)';
        X=X.'/1000; % mV
   end
   
% ---- Get signals for processing ----
[Xpa,Xpb,D,F,Der]=lynfilt2(index,X,Fs,ns); 

n=1;
nqrs=0;
% ---- Determine peak position of QRS complex ----
for i=1:length(ta)
   if nbo_flag==0|(nbo_flag==1&antyp(i)=='N')
      ibe=max(1,ta(i)-ti-round(0.2*Fs)); 
      ien=ta(i)-ti+round(0.17*Fs); 
      if ien<length(Xpa)
      [ymax,imax]=max(Xpa(ibe:ien)); imax=ibe+imax-1;
      [ymin,imin]=min(Xpa(ibe:ien)); imin=ibe+imin-1; 
      %if abs(ymin)>abs(ymax) 
      if abs(ymin)>1.3*abs(ymax)  %JGM
         iqrs(n)=imin;
      else iqrs(n)=imax;
      end
      atyp(n)=antyp(i);
      nqrs=nqrs+1;
      n=n+1;
      end
    
   end
end

index=1;
   
if iqrs(1)+ti>ilastqrs+0.4*Fs iprimerqrs=1;
elseif iqrs(2)+ti>ilastqrs+0.4*Fs iprimerqrs=2;
elseif iqrs(3)>ilastqrs+0.4*Fs iprimerqrs=3;
elseif iqrs(3)<=ilastqrs+0.4*Fs iprimerqrs=4; 
end
            
T=linspace(ti,tf,ns);

% ---- Detection of limits and peaks ----
[POS,AMP,ANNOT,POS_ANNOT,NUMFIELD,SUBTYPEFIELD,CHANFIELD,POS_QT,VAL_QT,VAL_QTC,AMP_Q,POS_Q,AMP_R,POS_R,AMP_S,POS_S,VAL_QRS,POS_QRS,prewindt]=proces...
(fidan,X,Xpa,Xpb,D,F,Der,ti,tf,iprimerqrs,nqrs,iqrs,atyp,ns,Fs,nl,res,prewindt,Kq,Kr,Ks,Krr,Kpb,Kpe,Ktb,Kte,pco); 

% ---- Recording of results ----
if (~isempty(POS_ANNOT))
a2=a1+length(POS_ANNOT)-1;
banot.time(a1:a2,1)=POS_ANNOT;
banot.anntyp(a1:a2,1)=setstr(ANNOT); 
banot.subtyp(a1:a2,1)=num2str(SUBTYPEFIELD);
banot.chan(a1:a2,1)=num2str(CHANFIELD);
banot.num(a1:a2,1)=num2str(NUMFIELD);     
a1=a2+1;
if ~isempty(POS_QT)
qt2=qt1+length(POS_QT)-1;
QT.pos(qt1:qt2,1)=POS_QT;
QT.val(qt1:qt2,1)=VAL_QT;
QTC.pos(qt1:qt2,1)=POS_QT;
QTC.val(qt1:qt2,1)=VAL_QTC;
qt1=qt2+1;
end
if ~isempty(POS_Q)
q2=q1+length(POS_Q)-1;
QW.pos(q1:q2,1)=POS_Q;
QW.val(q1:q2,1)=AMP_Q;
q1=q2+1;
end
if ~isempty(POS_R)
r2=r1+length(POS_R)-1;
RW.pos(r1:r2,1)=POS_R;
RW.val(r1:r2,1)=AMP_R;
r1=r2+1;
end
if ~isempty(POS_S)
s2=s1+length(POS_S)-1;
SW.pos(s1:s2,1)=POS_S;
SW.val(s1:s2,1)=AMP_S;
s1=s2+1;
end
if ~isempty(POS_QRS)
qrs2=qrs1+length(POS_QRS)-1;
QRS.pos(qrs1:qrs2,1)=POS_QRS;
QRS.val(qrs1:qrs2,1)=VAL_QRS;
qrs1=qrs2+1;
end

nt2=nt1+length(POS.Ponset)-1;
annt.Ponset(nt1:nt2)=POS.Ponset; 
annt.P(nt1:nt2)=POS.P;
annt.Poffset(nt1:nt2)=POS.Poffset;
annt.QRSonset(nt1:nt2)=POS.QRSonset;
annt.Q(nt1:nt2)=POS.Q;
annt.R(nt1:nt2)=POS.R;
annt.fiducial(nt1:nt2)=POS.fiducial;
annt.S(nt1:nt2)=POS.S;
annt.R2(nt1:nt2)=POS.R2;
annt.QRSoffset(nt1:nt2)=POS.QRSoffset;
annt.Tonset(nt1:nt2)=POS.Tonset;
annt.T(nt1:nt2)=POS.T;
annt.T2(nt1:nt2)=POS.T2;
annt.Toffset(nt1:nt2)=POS.Toffset;
annAmp.P(nt1:nt2)=AMP.P;
annAmp.Q(nt1:nt2)=AMP.Q;
annAmp.R(nt1:nt2)=AMP.R;
annAmp.S(nt1:nt2)=AMP.S;
annAmp.R2(nt1:nt2)=AMP.R2;
annAmp.T(nt1:nt2)=AMP.T;
annAmp.T2(nt1:nt2)=AMP.T2;
nt1=nt2+1;
end

if n>=1 
ilastqrs=iqrs(nqrs-2)+ti;
end
ilat=ilat+nlat;
nlat=min(nlat,no_beats-ilat-3);
ti=annot.time(ilat)-round(2*heasig.freq);
end
if res==1 fclose(fidan); 
end

%if res==0 save('fanot','banot'); end

fclose('all');    


keyboard
