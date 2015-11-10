function [peaks,locs]=buscapic2(x,thresh,number,sortem)
%Devuelve la posición y valor de los picos de un
%segmento de señal. Evita picos de una sola muestra.
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
njkl=zeros(1,number);
if number>0 & length(jkl)>number
	[tt,ii]=sort(abs(x(jkl)));
        ii=flipud(ii);
	njkl(1)=jkl(ii(1));
	i=2;
	for l=2:length(jkl)-1
		if (abs(x(jkl(ii(l))))>=0.5*abs(x(jkl(ii(l-1))))) & (abs(x(jkl(ii(l))))>=0.5*abs(x(jkl(ii(l+1)))))
	         	if i<=number	
				njkl(i)=jkl(ii(l));
				i=i+1;
			end
		end
    	end
	njkl=sort(njkl); 
end

L=length(njkl);
peaks(1:L)=x(njkl);
locs(1:L)=njkl;

