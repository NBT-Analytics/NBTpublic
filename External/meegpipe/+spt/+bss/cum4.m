function CM = cum4(Y,tauj,tauk,taul)

nbcm 	= (m*(m+1))/2;      % number of cumulant matrices
CM 		= zeros(m,m*nbcm);  % storage for cumulant matrices
R 		= eye(m);  	
Qij 	= zeros(m);         % temp for a cum. matrix
Xim		= zeros(1,m);       % temp
Xjm		= zeros(1,m);       % temp
scale	= ones(m,1)/T ;     % for convenience
range 	= 1:m ;

for im = 1:m
    Xim = X(im,:) ;
    Qij = ((scale* (Xim.*Xim)) .* X ) * X' 	- R - 2 * R(:,im)*R(:,im)' ;
    CM(:,range)	= Qij ;
    range = range + m ;
    for jm = 1:im-1
        Xjm = X(jm,:) ;
        Qij = ((scale * (Xim.*Xjm) ) .*X ) * X' - R(:,im)*R(:,jm)' - R(:,jm)*R(:,im)' ;
        CM(:,range)	= sqrt(2)*Qij ;
        range = range + m ;
    end ;
end;