function y=getvec(fid,heasig,x1,x2);
% reads the piece of signal between x1 & x2
% returns each signal as a column of a matrix to ease plotting
%
% Salvador Olmos
% e-mail: olmos@posta.unizar.es


i=1;

while i<=heasig.nsig,
   % Leer los datos segun el formato
   if heasig.fmt(i)==8,           
      y=cumsum([INITIAL_VALUE fread(fid,...                      
             [SIGNALS_MUX(i,:) x2],'schar')].');             
      y=y(x1:x2,:);
      %fseek(fid,x1,-1);
      %y=fread(fid,[heasig.nsig,x2-x1],'int8');
   elseif heasig.fmt(i)==16,
      fseek(fid,2*x1,-1);
      y=fread(fid,[heasig.nsig,x2-x1],'int16');      
   elseif heasig.fmt(i)==61,
      fseek(fid,2*x1,-1);
      y=fread(fid,[heasig.nsig,x2-x1],'int16');
      y=swapbyte(y,'int16');
   elseif heasig.fmt(i)==80,
   elseif heasig.fmt(i)==160,
   elseif heasig.fmt(i)==212,    
      fseek(fid,heasig.group(i,:)*3/2*x1,-1);    
      %data=fread(fid,[3 (heasig.group(i,:)*(x2-x1)/2)],'uchar');       
      data=fread(fid,[3 (heasig.group(1)*(x2-x1)/2)],'uchar');  % JG 170398     
      low=rem(data(2,:),16);  
      %samples(1:2:heasig.group(i)*(x2-x1)-1)=data(1,:)+256*low-(low>7)*4096;  
      samples(1:2:floor(heasig.group(i)*(x2-x1)-1))=data(1,:)+256*low-(low>7)*4096;

      low=data(2,:)-low;      
      %samples(2:2:heasig.group(i,:)*(x2-x1))=data(3,:)+16*low-(low>127)*4096;  
      samples(2:2:floor(heasig.group(i,:)*(x2-x1)))=data(3,:)+16*low-(low>127)*4096;     
   
      clear data;     
      clear low;      
      for k=1:heasig.nsig,              
         y(:,k)=samples(k:heasig.group(i,:):size(samples,2)).';      
      end;
   elseif heasig.fmt(i)==310,
   end;
   i=i+heasig.group(i);	
end
