function [annt,annAmp,banot,QT,QTC,QW,RW,SW,QRS]=limits(dirhea,dirsig,ecgnr,rtimes,typerec,res,nl,ti,tf,nbo_flag,Kq,Kr,Ks,Krr,Kpb,Kpe,Ktb,Kte,pco)


import safefid.safefid;

%-----  WL Principal program  ----------------------
%Deteccion de puntos significativos en el ECG.
%
%Input parameters:
%  dirhea: header directory
%  dirsig: signal directory
%  ecgnr: record name
%  rtimes: the locations (sample indices) of the R-peaks
%  typerec: type of recording (0:MIT-DB, 1:Lund-Siemens, 2:matlab)
%  res: results format (0: struct, 1: text file)
%  nl: leads (1:12)
%  ti: begin time of processing.
%  tf: end time of processing.
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

%t=[]; 

import ecgpuwave.*;

%Default parameters.
if nargin<6
   res=0;
end
if nargin<7
   nl=1;
end
if nargin<8
   ti=[];
end
if nargin<9
   tf=[];
end
if nargin<10
   nbo_flag=0;
end
if nargin<11  Kq=1.5; end
if nargin<12  Kr=5; end
if nargin<13  Ks=3; end
if nargin<14  Krr=5; end
if nargin<15  Kpb=1.35; end
if nargin<16  Kpe=2; end
if nargin<17  Ktb=2; end
if nargin<18  Kte=3.5; end
if nargin<19  pco=8; end


fidan=0;
if ~isempty(ti)&~isempty(tf)
    ti=timestr(ti); tf=timestr(tf);
    t=[ti,tf];
else
    t = [1 Inf];
end


if typerec==1
   % ---- Lund format ----
   hdsig=gethdsig(dirhea,ecgnr); 
   heasig.freq=hdsig.SamplingRate;
   heasig.nsamp=hdsig.NoSamples;
   heasig.nsig=hdsig.NoChannels;  

  %hd=getecghd(dirsig,ecgnr);
  %heasig.freq=hd(3);
  %heasig.nsamp=hd(7);
  %heasig.nsig=hd(6);
end
  
% ----  MIT format ----
if typerec==0,
    heasig=readheader([dirhea filesep ecgnr '.hea']); 
    heasig.gain=heasig.gain(1); 
    if (heasig.fmt(nl)==16) | (heasig.fmt(nl)==212) | (heasig.fmt(nl)==61),
        formato = num2str(heasig.fmt(nl));
    else
        error('This format is not supported by the program')
    end
    for kk=1:heasig.nsig, leadsfile(kk)=strcmp(heasig.fname(nl,:),heasig.fname(kk,:)); end
    leadsfile = cumsum(leadsfile);
    leadinfile = leadsfile(nl);  
    nsiginfile = leadsfile(end);
    if strcmp(formato,'16')|strcmp(formato,'61'),
       % fid = fopen([sigdir ecgnr '.dat'],'rb');
       % if fid == -1,
       fid = safefid.fopen([dirsig filesep heasig.fname(nl,:)],'rb');
       % end
       fseek(fid,0,-1);  % Rewind the file
       if strcmp(heasig.fname(nl,1),'_'),  % Siemens card recordings with MIT-type header
            timeoffset=512;
            fseek (fid, timeoffset,-1); % offset
       else
           timeoffset = 0;
       end
    end
end

% ---- Matlab file ----
if typerec==2,
    aux=[dirsig ecgnr];
    load ([aux '.mat'])
    heasig.nsamp=length(sinal);
    heasig.freq=fa;
    if exist('gain','var')
     heasig.gain=gain;
    else
     heasig.gain=200;  % When heasig.gain = 0 => default 200
    end
    heasig.gain(heasig.gain==0)=200;  % When heasig.gain = 0 => default 200
end


   
if ~isempty(t) t=round(t*heasig.freq/1000); 
end
if isempty(t)  t=[1 round(heasig.nsamp-0.1*heasig.freq)]; end
if t(1) < 1, t(1) = 1; end
if t(2) == Inf, t(2) = round(heasig.nsamp-0.1*heasig.freq); end


%---------------------------------------------------------------------------
% Build the annot structure using the provided QRS locations
annot.time = rtimes(:);
annot.anntyp = repmat('N', numel(rtimes), 1);
annot.num=zeros(length(length(rtimes)),1);
annot.subtyp=zeros(length(length(rtimes)),1);
annot.chan=zeros(length(length(rtimes)),1);
%---------------------------------------------------------------------------


no_leads=heasig.nsig;
if nl>no_leads
   disp('There are not nl signals at the record');
   return;
end
Fs=round(heasig.freq);
nsamp=heasig.nsamp;
if tf>nsamp tf=nsamp; end


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


% ----  Removing of first beat  ----
%if (annot.time(1)<0.5*heasig.freq) annot(1)=[]; end

if isempty(annot.time), disp('no events detected'), return, end
no_beats=length(annot.time);

% ---- Removing of non-NORMAL labelled beats and adjacents ----
%if nbo_flag==1
%   [annot,rr]=isnormal(annot,heasig,t,rr);
%   no_beats=length(annot.time);
%end

s=sprintf('%s%s.ecgpuwave.txt',[dirsig, filesep], ecgnr);
if res==1
fidan=safefid.fopen(s,'wt+');
end

%READING SIGNAL SEGMENTS
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
  
   if typerec==1
         X=getsig(dirsig,ecgnr,[ti+1 tf],nl);
         X=X'/1000;
      end
   if typerec==0 
       if strcmp(formato,'212'), 
            X= rdsign212([dirsig ecgnr '.dat'],nsiginfile,ti+1, tf); 
        elseif strcmp(formato,'16')|strcmp(formato,'61'),
            fseek(fid, timeoffset+2*(ti)*nsiginfile, -1); % Locate the pointer
            X = fread(fid,[nsiginfile tf-ti] ,'int16')';
            if (strcmp(computer,'SOL2')&strcmp(formato,'16'))|(~strcmp(computer,'SOL2')&strcmp(formato,'61')),
                X=swap16(X);
            end
        end
        X = X(:,leadinfile);   
        X = (X - heasig.adczero(nl))/heasig.gain(nl); %*1e3; % conversion to microV
   end
   if typerec==2 
       X=sinal(nl,ti+1:tf)';
   end
   
   %keyboard
   
%get signals for processing.
[Xpa,Xpb,D,F,Der]=lynfilt(index,X,Fs,ns); 

n=1;
nqrs=0;
%Determine peak position of QRS.
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
      %plot(T,SIGNAL)

%Detection of limits and peaks.
[POS,AMP,ANNOT,POS_ANNOT,NUMFIELD,SUBTYPEFIELD,CHANFIELD,POS_QT,VAL_QT,VAL_QTC,AMP_Q,POS_Q,AMP_R,POS_R,AMP_S,POS_S,VAL_QRS,POS_QRS,prewindt]=proces...
(fidan,X,Xpa,Xpb,D,F,Der,ti,tf,iprimerqrs,nqrs,iqrs,atyp,ns,Fs,nl,res,prewindt,Kq,Kr,Ks,Krr,Kpb,Kpe,Ktb,Kte,pco); 

%Recording of results.
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

%banot(j)=struct('time',POS_ANNOT,'anntyp',setstr(ANNOT),'subtyp',num2str(SUBTYPEFIELD),'chan',num2str(CHANFIELD),'num',num2str(NUMFIELD));
if n>=1 
ilastqrs=iqrs(nqrs-2)+ti;
end
ilat=ilat+nlat;
nlat=min(nlat,no_beats-ilat-3);
ti=annot.time(ilat)-round(2*heasig.freq);
end
%if res==1 fclose(fidan); 
%end

%if res==0 save('fanot','banot'); end
