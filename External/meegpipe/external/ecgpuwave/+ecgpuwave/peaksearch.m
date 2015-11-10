function [peaks,locs]=peaksearch(x,thresh,number,sortem)

% ---- Find peak values and postions in a segment avoiding one-sample
% peaks ----
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

M=length(x);

if any(imag(x(:))~=0)
   x=abs(x);
end

mask=diff(sign(diff(x(:))));
mask=[0;mask;0];
jkl=find(abs(mask)>1 &abs(x)>=thresh);

if number>0 & length(jkl)>number
	[tt,ii]=sort(abs(x(jkl)));
    ii=flipud(ii);
    jkl=jkl(ii(1:number));
    jkl=sort(jkl); 
end

L=length(jkl);
peaks(1:L)=x(jkl);
locs(1:L)=jkl;

