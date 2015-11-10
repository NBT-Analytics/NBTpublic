function [W, nonseparablecomponents, Wefica, Wwasobi, ISRwa1, ISRef1, signals]= multicombi(X,AR_order,verbose)


import multicombi.ewasobi;
import multicombi.efica;

if nargin < 3 || isempty(verbose), verbose = true; end
if nargin<2
    AR_order=5;
end

%COMMON PREPROCESSING
Xmean = mean(X,2);
X = X - Xmean*ones(1,length(X));
C = cov(X');
CC = C^(-1/2);
x = CC*X;

%Crate a stack of (un)resolved multidimensional components. In the end, there must
%be d one-dimensional components, stack(i).m==0 signalizes that the i-th
%record is empty
dim=size(x,1);
for i=1:dim 
    stack(i).W=[]; 
    stack(i).m=nan;
end


%This first run of clustering could be included in the cycle below, but we
%want the first outputs of EFICA & WASOBI, especially.
[Wefica, ISRef1]=efica(x,eye(dim),true,verbose);
[Wwasobi,AOL_init,ISRwa1]= ewasobi(Wefica*x,AR_order,0.99);
[ordering dimensions method]=clustering(ISRef1, ISRwa1); %1=EFICA, -1=WASOBI, 0=non-separable
if method==1, W=Wefica; elseif method==-1, W=Wwasobi*Wefica; else W=eye(dimensions); end;
%Store the resulting multi(one)-dim components
for i=1:length(dimensions)
    stack(i).W=W(ordering(1+sum(dimensions(1:i-1)):sum(dimensions(1:i))),:);
    stack(i).m=method;
end

while IsUnresolved(stack) %stop if there are only nonseparable components
    i=FirstUnresolved(stack); %find first separable non-soliton
    y=stack(i).W*x;
    oldW=stack(i).W;
    %separate y into multi-dim components
    [Wef, ISRef] = efica(y,eye(size(y,1)),true,verbose);
    [Wwa,AOL_init, ISRwa] = ewasobi(y,AR_order,0.99);
    [ordering dimensions method]=clustering(ISRef, ISRwa); 
    if method==1, W=Wef; elseif method==-1, W=Wwa; else W=eye(dimensions); end;
    %store the first resulting component to the old record
    stack(i).m=method;
    stack(i).W=W(ordering(1:dimensions(1)),:)*oldW;
    %store the other resulting components (there must be one at least) 
    %to the empty records
    j=FirstEmpty(stack);
    for i=2:length(dimensions)
        stack(j).m=method;
        stack(j).W=W(ordering(1+sum(dimensions(1:i-1)):sum(dimensions(1:i))),:)*oldW;
        j=j+1;
    end
end

W=zeros(0,dim);nonseparablecomponents=[];j=1;k=0;
for i=1:length(stack)
    if ~isnan(stack(i).m)
        if stack(i).m, W(j,:)=stack(i).W; metoda(j)=stack(i).m; j=j+1; 
        else
            k=k+1; 
            nonseparablecomponents(k).W=stack(i).W;
        end
    end
end
for i=1:length(nonseparablecomponents)
    W(j:j+size(nonseparablecomponents(i).W,1)-1,:)=nonseparablecomponents(i).W;
    j=j+size(nonseparablecomponents(i).W,1);
    nonseparablecomponents(i).W=nonseparablecomponents(i).W*CC;
end

W=W*CC;
Wwasobi=Wwasobi*Wefica*CC;
Wefica=Wefica*CC;

signals=W*X+(W*Xmean)*ones(1,length(X));

%%%%%%%%%%%%%%%%%%%%%%%%%%%% Helping functions

function n=IsUnresolved(stack)
%true if there is an unresolved multi-component
n=0;
for i=1:length(stack)
   if isnan(stack(i).m), break, end
   if stack(i).m && (size(stack(i).W,1)>1), n=1; end
end


function n=FirstUnresolved(stack) 
%find the first unresolved multi-component
n=1;
while ~(stack(n).m && (size(stack(n).W,1)>1)), 
    n=n+1; 
end

function n=FirstEmpty(stack)
%find the first empty record of the stack
n=1;
while ~isnan(stack(n).m)
    n=n+1;
end

function ordering=cluster(ISR)
%
% performs spectral clustering
%
ISRmax=max(sum(ISR,2));
M=ISR/(2*ISRmax);
M=M+diag(-sum(M,2)+1);
[V D]=eig(M);
[y is]=sort(-abs(diag(D)));
evec=V(:,is(2));
[y ordering]=sort(real(evec)+imag(evec));

%%%%%%%%%%%%%%%%%%%%%%%%%%%% clustering

function [ordering, dimensions, method]=clustering(ISRef,ISRwa)

d=size(ISRef,1);

[p1 componentsEF]=hcsort(ISRef);
%[p1 componentsEF]=spsort(ISRef);

[p2 componentsWA]=hcsort(ISRwa);
%[p2 componentsWA]=spsort(ISRwa);

%Decide for the better clustering and accept those components that have
%higher ISR than the best component of the declined method
EEE=min(componentsEF(:,3));WWW=min(componentsWA(:,3)); %denoted E and W, in the paper
ISRthreshold=0.05;
if (EEE>ISRthreshold)&&(WWW>ISRthreshold)
    components=[1 d EEE];method=0;ordering=p1;
    naccepted=1;
elseif EEE<WWW
    components=componentsEF;method=1;ordering=p1;
    naccepted=sum(componentsEF(:,3)<WWW);
else
    components=componentsWA;method=-1;ordering=p2;
    naccepted=sum(componentsWA(:,3)<EEE);
end

dimensions=components(1:naccepted,2);
%The rest of the space is one multidim. component
if sum(dimensions)<d
    dimensions(end+1)=d-sum(dimensions);
end

%END of clustering

function [ordering,clusters] = hcsort(ISR)
% Agglomerative hierarchical clustering with single or average
% linkage strategy

d = size(ISR,1);
if d==2
    ordering=[1 2];
    clusters=[1 1 sum(ISR(1,:));2 1 sum(ISR(2,:))];
else
clusters=[0 0 0];
%dist=0.5*(ISR+ISR');
seznam=eye(d);
dseznam=d;
sisr=sum(ISR,2);
% distance matrix
D = -.5*(ISR+ISR');

% initial clusters are the individual components
cluster = 1:d;

% merge clusters until there is no more clusters to merge
for i = 2:d,
    % initialize the clusters
    cluster(i,:) = cluster(i-1,:);
    % find pair of clusters that are closest to each other
    [mval,mrow] = min(D);
    [mval,mcol] = min(mval);
    mrow = mrow(mcol);    
    % merge the clusters
    C1 = find(cluster(i,:)==cluster(i,mrow));
    C2 = find(cluster(i,:)==cluster(i,mcol));
    cindex = min(cluster(i,[C1 C2]));
    cluster(i,[C1 C2]) = cindex;   
    % Make sure that we will not try to merge them again
    D(C1,C2) = Inf; 
    D(C2,C1) = Inf;    
    dseznam=dseznam+1;  %%% create a new item in seznam
    seznam(dseznam,:)=zeros(1,d);
    seznam(dseznam,[C1 C2])=1;
    comp=find(seznam(dseznam,:)>0);
 %   comp2=unique([C1 C2]);
    icomp=setdiff(1:d,comp);
    dlen=length(comp);
    if dlen<d
       sisr(dseznam)=sum(sum(ISR(comp,icomp)))*(d-1)/(dlen*(d-dlen));
    else
       sisr(dseznam)=Inf;
    end
end    
ordering=[]; 
remains=d;
index=0;
while remains>1
 index=index+1;    
 clusters(index,1)=d-remains+1;
 [isrmin icl]=min(sisr);
 clusters(index,3)=isrmin;
 cluster=find(seznam(icl,:)>0);
 clusters(index,2)=length(cluster);
 ordering=[ordering cluster];
 remains=remains-length(cluster);
 leaveout=sum(seznam(:,cluster),2);
 ileaveout=find(leaveout>0);
 seznam(ileaveout,:)=[];
 sisr(ileaveout)=[];
end 
if remains>0  %% last component is a soliton
   index=index+1;
   h2=setdiff(1:d,ordering);
   ordering=[ordering h2];
   clusters(index,1)=d;
   clusters(index,2)=1;
   clusters(index,3)=sum(ISR(h2,:));
end   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ordering clusters]=spsort(ISR)
% Spectral clustering based method
d=size(ISR,1);
maxmultidim=d-1; %ceil(d/2);

ordering=cluster(ISR);
ISR=ISR(ordering,ordering);
mISR=ones(d,d-1)*nan;

%Compute ISR of all diagonal multidim. components (clusters)
for j=1:d, 
    for i=1:min([maxmultidim d-j+1])  
        su=ISR(j:j+i-1,[1:j-1 j+i:end]);
        mISR(j,i)=mean(su(:)); %i/sum(su(:));
    end
end

%Select the best (diagonal) clusters using a Greedy method
k=0;
clusters=[0 0 0];
while sum(clusters(:,2))<d
    [i j]=find(mISR==min(mISR(:)));
    i=i(1); j=j(1);
    k=k+1;
    clusters(k,:)=[i j mISR(i,j)];
    mISR=fliplr(triu(fliplr(mISR),d-i))+[zeros(i+j-1,d-1); mISR(i+j:end,:)];
    mISR(mISR==0)=nan;
end

p=[];
for i=1:size(clusters,1)
    p=[p clusters(i,1):clusters(i,1)+clusters(i,2)-1];
end

ordering=ordering(p);
