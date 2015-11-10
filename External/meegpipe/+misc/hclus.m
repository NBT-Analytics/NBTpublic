function [order,clus_out,qof] = hclus(ISR,dd)
% Agglomerative hierarchical clustering with single linkage strategy

if nargin < 2 || isempty(dd), dd = 2; end

d = size(ISR,1);

% distance matrix
D = 1-ISR;
D = D+eye(size(D));
%D = -ISR;
% initial clusters are the individual components
cluster = 1:d;

% merge clusters until there is no more clusters to merge
for i = 2:d,
    % initialize the clusters
    cluster(i,:) = cluster(i-1,:);
    % find pair of clusters that are closest to each other
    [mval,mrow] = min(D);
    [~,mcol] = min(mval);
    mrow = mrow(mcol);
    % merge the clusters
    C1 = find(cluster(i,:)==cluster(i,mrow));
    C2 = find(cluster(i,:)==cluster(i,mcol));
    cindex = min(cluster(i,[C1 C2]));
    cluster(i,[C1 C2]) = cindex;
    % Make sure that we will not try to merge them again
    D(C1,C2) = Inf;
    D(C2,C1) = Inf;
end

% select the best partition level (THIS IS THE CRUCIAL STEP!)
% Note: This is a bit based on heuristics. Furthermore, two thresholds need
% to be settled in order to detect the situation where there is only 1
% cluster and the situation where all clusters are 1-dimensional.
D = 1-ISR;
qof = zeros(1,d);
for i = 2:d-1,
    cindex = unique(cluster(i,:));
    numt = 0;    
    nintra = 0;    
    for j = 1:length(cindex)
        Cin = find(cluster(i,:)==cindex(j));
        nin = length(Cin);        
        if length(Cin) == 1,
            num = 0;                
        else            
            num = sum(sum(D(Cin,Cin)));                        
            nintra = nintra+nin.^2-nin;
        end
        numt = numt + num;        
    end
    % the QOF is a ratio between the average distance within clusters and
    % the average clusters between clusters. A high QOF means a good fit.
    qof(i) = (numt/nintra)/(((sum(D(:))-numt)/(d^2-nintra-d)));    
end
% find local maxima of the QOF function
qofdiff = diff(qof(2:end-1));
v1 = qofdiff>0;
v1 = [0 0 v1(2:end)-v1(1:end-1)];
maxloc = find(v1<0);
[~,index] = sort(qof(maxloc),'descend');
maxloc = maxloc(index);
% simple way of discarding spurious local maxima
maxdiff = zeros(1,length(maxloc));
for i = 1:length(maxloc),
    maxdiff(i) = .5*(-qof(maxloc(i)-1)+2*qof(maxloc(i))-qof(maxloc(i)+1));
end
if ~isempty(maxloc),
    maxloc(maxdiff<.75*max(maxdiff))=[];
    % select the maximum from the local maxima
    plevel = maxloc(1);
    qof = qof(plevel);
else
    [qof,plevel] = max(qof);
end
% % check wether we have 1-dimensional clusters (perfect separation)
% if qof < .1,
%     plevel = 1;
%     qof = -.1/(Dmin);
% end
% % check wether we have just 1 cluster (all sources are still mixed)
% % A reasonable value of dd would be in the range: 10-20
% if qof < dd,
%     plevel = d;
%     qof = dd;
% end

% ordering of components and setting up the output format in the same way
% as in function hcsort
[cluster,order] = sort(cluster(plevel,:));
cindex = unique(cluster);
D = D(order,order);
clus_out = zeros(length(cindex),5);
for i = 1:length(cindex)
    tmp = find(cluster==cindex(i));
    clus_out(i,1) = tmp(1);
    clus_out(i,2) = tmp(end)-tmp(1)+1;
    Cin = find(cluster==cindex(i));
    Cout = setdiff(1:d,Cin);
    if length(Cin) == 1,
        num = -1;
        den = min(min(D(Cin,Cout)));
        dlen = 1;
        clus_out(i,3) = sum(sum(ISR(order(Cin),order(Cout))))*(d-1)/(dlen*(d-dlen));
    elseif isempty(Cout),
        den = -1;
        num = max(max(D(Cin,Cin)));
        clus_out(i,3) = NaN;
    else
        num = max(max(D(Cin,Cin)));
        den = min(min(D(Cin,Cout)));
        dlen = length(Cin);
        clus_out(i,3) = sum(sum(ISR(order(Cin),order(Cout))))*(d-1)/(dlen*(d-dlen));
    end
    clus_out(i,4) = num/den;
    tmp = ISR(Cin,Cin);
    clus_out(i,5) = mean(tmp(:));
end