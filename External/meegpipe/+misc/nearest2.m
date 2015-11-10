function [A,M]=nearest2(Wnew,Wold)
% NEAREST - Find nearest matrix in terms of Frobenius norm with same rows
%
%Nearest(Wnew, Wold) finds the nearest matrix (in sense of the Frobenius norm)
%from Wold, which has the same rows (up to the signs, scales (depends on 
%criterion), and order) like the matrix Wnew. The function utilizes the 
%function "maxmatching". Returns the permutation matrix, also.

%
Wnew=Wnew'; Wold=Wold'; %% performs transposition to make calling easier
%
n=size(Wnew,2);
Sign=zeros(n,n);
for i=1:n
    for j=1:n
        %[W(i,j) Sign(i,j)]=min([sum((Wnew(:,i)-Wold(:,j)).^2) sum((Wnew(:,i)+Wold(:,j)).^2)]);
        %different criterion of "similarity"
        W(i,j)=abs((Wnew(:,i)'*Wold(:,j))/norm(Wnew(:,i))/norm(Wold(:,j)));
        Sign(i,j)=sign(Wnew(:,i)'*Wold(:,j));
    end
end
%Sign=-sign(Sign-1.5);
%W=max(max(W))-W;
M=maxmatching(W);
M=M.*Sign;
A=Wnew*M;
A=A'; M = M';%M=abs(M');

function S=augmentingpath(x,y,Gl,M)
n=size(Gl,2);
cesty=zeros(n,2*n);
cesty(1,1)=x;
uroven=1;
pocetcest=1;

while (ismember(y,cesty(:,2:2:2*n))==0)
    if (mod(uroven,2))
    pom=Gl-M;
    k=2;
    else
    pom=M';
    k=1;
    end
    novypocetcest=pocetcest;
    i=1;
    while (i<=pocetcest)
    sousedi=find(pom(cesty(i,uroven),:)==1);
    pridano=0;
    for j=1:length(sousedi)
        if (ismember(sousedi(j),cesty(:,k:2:2*n))==0)
        if (pridano==0)
            cesty(i,uroven+1)=sousedi(j);
        else
            novypocetcest=novypocetcest+1;
            cesty(novypocetcest,1:uroven+1)=[cesty(i,1:uroven) sousedi(j)];
        end
        pridano=pridano+1;
        end
    end
    if (pridano==0)
        novypocetcest=novypocetcest-1;
        cesty=[cesty([1:i-1, i+1:n],:);zeros(1,2*n)];
        i=i-1;
        pocetcest=pocetcest-1;
    end
    i=i+1;
    end
    pocetcest=novypocetcest;
    uroven=uroven+1;
end
pom=find(cesty(:,uroven)==y);
S=cesty(pom(1),1:uroven);


function M=maxmatching(W);
n=size(W,2);
M=zeros(n,n);
lx=max(W');
ly=zeros(1,n);
Gl=double((lx'*ones(1,n)+ones(n,1)*ly)==W);
M=diag(sum(Gl')==1)*Gl*diag(sum(Gl)==1);
if (sum(sum(M))==0)
    pom=find(Gl==1);
    M(pom(1))=1;
end
while(sum(sum(M))~=n)
%1  
    pom=find(sum(M')==0);
    x=pom(1);
    S=[x];
    T=[];
%2
    run=1;
    y=1;
    while ((sum(M(:,y))==1)|run)
        run=0;
        if (isempty(setdiff(find(sum(Gl(S,:),1)>0),T)))
            pom=lx'*ones(1,n)+ones(n,1)*ly-W;
            alfa=min(min(pom(S,setdiff(1:n,T))));
            lx(S)=lx(S)-alfa;
            ly(T)=ly(T)+alfa;
            Gl=abs((lx'*ones(1,n)+ones(n,1)*ly)-W)<0.0000001;
        end
%3
        pom=setdiff(find(sum(Gl(S,:),1)>0),T);
        y=pom(1);
        if (sum(M(:,y))==1)
            z=find(M(:,y)==1);
            S(length(S)+1)=z;
            T(length(T)+1)=y;
        end
    end
    if (sum(sum(M.*Gl==M))~=19^2)
        Gl;
    end
    S=augmentingpath(x,y,Gl,M);
    M(S(1),S(2))=1;
    for i=4:2:length(S)
        M(S(i-1),S(i-2))=0;
        M(S(i-1),S(i))=1;
    end
end
