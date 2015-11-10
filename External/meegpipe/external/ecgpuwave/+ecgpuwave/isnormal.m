function [annot,rr]=isnormal(annot,heasig,t,rr)

% Extraction of beats labeled as NORMAL with NORMAL adjacents in the annotation file
% function [annot,rr]=isnormal(annot,heasig,t,rr)
%
% Copyright (c), Jose Garcia Moros, Zaragoza University, Spain
% email: jogarmo@posta.unizar.es
% last revision: 28 Apr 1997

aux=find(annot.anntyp~='N');
auxm=unique([aux-1;aux;aux+1]);
excl=[-1,0,length(annot.time),length(annot.time)+1];
auxm=setdiff(auxm,excl);
 
if (~isempty(auxm))
  annot.anntyp(auxm)=[];
  annot.time(auxm)=[];
  annot.num(auxm)=[];
  annot.subtyp(auxm)=[];
  annot.chan(auxm)=[];
  annot.aux(auxm,:)=[];
  rr(auxm)=[];
end

auxm=find(annot.time&lt;t(1) | annot.time&gt;(t(2)+heasig.freq) );
if (~isempty(auxm))
 annot.anntyp(auxm)=[];
 annot.time(auxm)=[];
 annot.num(auxm)=[];
 annot.subtyp(auxm)=[];
 annot.chan(auxm)=[];
 annot.aux(auxm,:)=[];
 rr(auxm)=[];
end
