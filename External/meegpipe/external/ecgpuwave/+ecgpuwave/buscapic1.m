function [peaks,locs]=buscapic1(x,thresh,number,sortem)
%Devuelve la posición y valor de los picos de un 
%segmento de señal. 


if nargin==1
   thresh=-inf; number=-1; sortem=0;
elseif nargin==2
       number=-1; sortem=0;
elseif nargin==3
       sortem=0;
end
if (strcmp(sortem,'sort'))
    sortem=1;
end

%[M,N]=size(x);
%if M==1
%   x=x(:);
%   [M,N]=size(x);
%end

M=length(x);

if any(imag(x(:))~=0)
   x=abs(x);
end

mask=diff(sign(diff(x(:))));
mask=[0;mask;0];
jkl=find(abs(mask)>0 &abs(x)>=thresh);
if number>0 &length(jkl)>number
        [tt,ii]=sort(abs(x(jkl)));
        ii=flipud(ii);
        jkl=jkl(ii(1:number));
        jkl=sort(jkl); 
end

L=length(jkl);
peaks(1:L)=x(jkl);
locs(1:L)=jkl;

