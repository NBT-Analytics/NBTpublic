% isqrs.m is a function for getting only QRS marks from annotator
% function [ann]=isqrs(ann,heasig,t)


% ------------------------------------------
% Salvador Olmos:
% e-mail: olmos@tsc1.cps.unizar.es
% Last modified: 20/Nov/1996
% ------------------------------------------

function [ann]=isqrs(ann,heasig,t)


aux=find(ann.anntyp~='N' & ann.anntyp~='A' & ann.anntyp~='V' & ann.anntyp~='L' & ann.anntyp~='R' & ann.anntyp~='J' & ...
         ann.anntyp~='F' & ann.anntyp~='S' & ann.anntyp~='j' & ann.anntyp~='J' & ann.anntyp~='e' & ann.anntyp~='a' & ...
         ann.anntyp~='?' );

ann.anntyp(aux)=[];
ann.time(aux)=[];
ann.num(aux)=[];
ann.subtyp(aux)=[];
ann.chan(aux)=[];
%ann.aux(aux,:)=[];


aux=find(ann.time<t(1) | ann.time>(t(2)+2*heasig.freq) );

ann.anntyp(aux)=[];
ann.time(aux)=[];
ann.num(aux)=[];
ann.subtyp(aux)=[];
ann.chan(aux)=[];
%ann.aux(aux,:)=[];
