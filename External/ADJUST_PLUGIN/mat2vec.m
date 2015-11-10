% mat2vec() - reshape a matrix in a vector 
% (Warning: you better use reshape...)
%
% Usage:
%   >> vett=mat2vec(mat);
%
% Input:
%   mat        - 2D or 3D matrix
%   
% Output:
%   vett       - vector
%
% Copyright (C) 2009 Andrea Mognon and Marco Buiatti, 
% Center for Mind/Brain Sciences, University of Trento, Italy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function vett=mat2vec(mat)

if ndims(mat)==2
    M=size(mat,1);
    N=size(mat,2);
    vett=zeros(1,M*N);
    for i=1:M
        for j=1:N
            vett(1,(i-1)*N+j)=mat(i,j);
        end
    end
end

if ndims(mat)==3
    I=size(mat,1);
    M=size(mat,2);
    N=size(mat,3);
    vett=zeros(1,I*M*N);
    inter=zeros(I,M*N);
%     for i=1:I
%         
%         for k=1:M
%             for l=1:N
%                 inter(i,(k-1)*N+l)=mat(i,k,l);
%             end
%         end
%         
%     end
%     
%     for i=1:I
%         for j=1:M*N
%             vett(1,(i-1)*M*N+j)=inter(i,j);
%         end
%     end  


%%% for epoch-divided EEG data:
    for i=1:I
        
        for l=1:N
            for k=1:M
                inter(i,(l-1)*M+k)=mat(i,k,l);
            end
        end
        
    end
    
    for i=1:I
        for j=1:M*N
            vett(1,(i-1)*M*N+j)=inter(i,j);
        end
    end  
    
end


        