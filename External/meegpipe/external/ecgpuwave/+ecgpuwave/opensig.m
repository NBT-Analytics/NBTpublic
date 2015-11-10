% opensig.m  function for opening signal files from header
%   it creates a vector of pointers to signal files in header
%
% function [fid]=opensig(dirsig,heasig);


function [fid]=opensig(dirsig,heasig);

nfile=heasig.nsig./heasig.group(1);
fid=zeros(size(heasig.fname(1,:),1));
i=1;
while i<=heasig.nsig,
   if strcmp(heasig.fname(i,:),'-'),
	fid(i)=0;
   else
	fid(i)=fopen([dirsig heasig.fname(i,:)],'rb');
   end
   i=i+heasig.group(i);   
end
