function [Wefica, ISRef, Wsymm, ISRsymm, status, icasig]=efica(X, ini, SaddleTest,verbose)
%EFICA: [Wefica, ISRef, Wsymm, ISRsymm, status, icasig]=efica(X, ini, SaddleTest)
% 
% version: 2.12  release: 11.6.2009
%
% copyright: Zbynek Koldovsky, Petr Tichavsky
%
%
%Input data:
% X ... mixed data dim x N, where dim is number of signals and N is number of
%       samples
% ini ... starting point of the iterations
% SaddleTest ... if true (default) the test of saddle points on the demixed signals is done
% 
%
%Output data:
% Wefica - demixing matrix produced by EFICA 
% ISRef - ISR matrix estimator of EFICA components
% Wsymm - demixing matrix produced by symmetric Fast-ICA
% ISRsymm - ISR matrix estimator of Fast-ICA components
% status - one if test of saddle points was positive, zero otherwise
% icasig - estimated independent components (normalized to unit variance)
%
% References
% [1] Z. Koldovsky, P. Tichavsky and E. Oja, "Efficient Variant of Algorithm 
% FastICA for Independent Component Analysis Attaining the Cramer-Rao Lower 
% Bound", IEEE Trans. on Neural Networks, Vol. 17, No. 5, Sept 2006.
%
% [2] P. Tichavsky, Z. Koldovsky and E. Oja, "Speed and Accuracy Enhancement 
% of Linear ICA Techniques Using Rational Nonlinear Functions", Proceedings 
% of 7th International Conference on Independent Component Analysis 
% (ICA2007), pp. 285-292, Sept. 2007.  


[dim N]=size(X);

%Default values of parameters
if nargin < 4 || isempty(verbose), verbose = true; end
if nargin<3
    SaddleTest=true;
end
if nargin<2
    ini=randn(dim);
end

g='rat1';
epsilon=0.0001; %Stop criterion
fineepsilon=1e-5; %Stop criterion for post-estimation
repeat=1;
MaxIt=100; %% Maximum number of FastICA iterations 
MaxItAfterSaddleTest=30; %%Maximum number of iterations after a saddle point was indicated
FinetuneMaxIt=50; %%Maximum number of improving iterations
SupergaussianNL='rat3';  %Nonlinearity used for supergaussian signals 'gaus'-'ggda'-'npnl'-'rat3'
status=0;
min_correlation=0.9; %additive noise...0.75, noise free... 0.95, turn off (unstable)...0
test_of_saddle_points_nonln='rat2';

%removing mean
Xmean = mean(X,2);
X = X - Xmean*ones(1,N);


%preprocessing
C = cov(X');
CC = C^(-1/2);
Z = CC*X;

if verbose,
fprintf('Starting EFICA v2.1, dim=%d, N=%d, ',dim,N);
end

mu=zeros(1,dim);nu=zeros(1,dim);beta=zeros(1,dim);
W=ini;
W_before_decor=W;
W = symdecor(W);
NumIt=0;
TotalIt=0;
crit=zeros(1,dim);
while repeat
 while (1-min(crit)>epsilon && NumIt<MaxIt)
   NumIt=NumIt+1;  
   Wold=W;
   switch g
    case 'tanh'
     hypTan = tanh(Z'*W);
     W=Z*hypTan/N-ones(dim,1)*sum(1-hypTan.^2).*W/N;
    case 'pow3'
     W=(Z*((Z'*W).^ 3))/N-3*W;
    case 'rat1'
     U=Z'*W;
     Usquared=U.^2;
     RR=4./(4+Usquared);
     Rati=U.*RR;
     Rati2=Rati.^2;
     dRati=RR-Rati2/2;  
     nu=mean(dRati);
     hlp=Z*Rati/N;
     W=hlp-ones(dim,1)*nu.*W;
    case 'rat2'
     U=Z'*W;
     Ua=1+sign(U).*U;
     r1=U./Ua;
     r2=r1.*sign(r1);
     Rati=r1.*(2-r2);
     dRati=(2./Ua).*(1-r2.*(2-r2));  
     nu=mean(dRati);
     hlp=Z*Rati/N;
     W=hlp-ones(dim,1)*nu.*W;
    case 'gaus'
     U=Z'*W;
     Usquared=U.^2;
     ex=exp(-Usquared/2);
     gauss=U.*ex;
     dGauss=(1-Usquared).*ex;
     W=Z*gauss/N-ones(dim,1)*sum(dGauss).*W/N;
   end
  TotalIt=TotalIt+dim;

  W_before_decor=W;
  W=symdecor(W);
  crit=abs(sum(W.*Wold));
 end %while iteration
 
 if verbose && repeat==1     
     fprintf('Iterations: %d\n',NumIt);
 elseif verbose && repeat==2
     fprintf('   Test of saddle points positive: %d iterations\n',NumIt);
 end
 repeat=0;

%%%The SaddleTest of the separated components
 if SaddleTest
  SaddleTest=false; %%The SaddleTest may be done only one times
  u=Z'*W;
  switch test_of_saddle_points_nonln
        case 'tanh'
            table1=(mean(log(cosh(u)))-0.37456).^2;
        case 'gaus'
            table1=(mean(ex)-1/sqrt(2)).^2;
        case 'rat1'
            table1=(mean(2*log(4+u.^2))-3.1601).^2;
        case 'rat2'
            table1=(mean(u.^2./(1+sign(u).*u))-0.4125).^2;
        case 'pow3'
            table1=(mean((pwr(u,4)))-3).^2;
  end
     %  applying the round-Robin tournament scheme for parallel processing 
  dimhalf=floor((dim+1)/2); dim2=2*dimhalf; 
  da=[1:dim2 2:dim2];      %%% auxiliary array    
  for delay = 0:dim2-2
      ii=[1 da(dim2-delay+1:3*dimhalf-delay-1)];
      jj=da(4*dimhalf-delay-1:-1:3*dimhalf-delay);
      if dim2>dim
         i0=dimhalf-abs(delay-dimhalf+1/2)+1/2;
         ii(i0)=[]; jj(i0)=[];  % the pair containing index dim2 must be deleted
      end 
     ctrl0=table1(ii)+table1(jj);
     z1=(u(:,ii)+u(:,jj))/sqrt(2);
     z2=(u(:,ii)-u(:,jj))/sqrt(2);
     switch test_of_saddle_points_nonln
            case 'tanh'
                 ctrl=(mean(log(cosh(z1)))-0.37456).^2 ...
                      +(mean(log(cosh(z2)))-0.37456).^2;
            case 'gaus'
                 ctrl=(mean(exp(-z1.^2/2)-1/sqrt(2))).^2 ...
                      +(mean(exp(-z2.^2/2)-1/sqrt(2))).^2;
            case 'rat1'
                 ctrl=(mean(2*log(4+z1.^2))-3.1601).^2 ...  
                      +(mean(2*log(4+z2.^2))-3.1601).^2;  
            case 'rat2'
                 ctrl=(mean(z1.^2./(1+sign(z1).*z1))-0.4125).^2 ...
                      +(mean(z2.^2./(1+sign(z2).*z2))-0.4125).^2;
            case 'pow3'
                 ctrl=(mean((pwr(z1,4)))-3).^2 ...
                      +(mean((pwr(z2,4)))-3).^2;
     end
     indexes=find(ctrl>ctrl0);
     if length(indexes)>0
        irot=ii(indexes); jrot=jj(indexes);
          %bad extrems indicated
       % fprintf('  EFICA: rotating components: %d\n', [irot jrot]);
        u(:,irot)=z1(:,indexes); 
        u(:,jrot)=z2(:,indexes); 
        Waux=W(:,irot);
        W(:,irot)=(W(:,irot)+W(:,jrot))/sqrt(2);
        W(:,jrot)=(Waux-W(:,jrot))/sqrt(2);
        NumIt=0;MaxIt=MaxItAfterSaddleTest;status=1;
        repeat=2; %continue in iterating - the test of saddle points is positive
     end %if length(indeces)>0
  end% for delay
 end %if SaddleTest
 crit=zeros(1,dim);
end %while repeat

Wsymm=W;

%estimated signals
s=W'*Z;

%estimate SIRs of the symmetric approach
switch g
    case 'tanh'
        mu=mean(s.*tanh(s),2);
        nu=mean(1./cosh(s).^2,2);
        beta=mean(tanh(s).^2,2);
    case 'rat1'
        ssquare=s.^2;
        mu=mean(ssquare./(1+ssquare/4),2);
        nu=mean((1-ssquare/4)./(ssquare/4+1).^2,2);
        beta=mean(ssquare./(1+ssquare/4).^2,2);
    case 'rat2'
        r1=s./(1+s.*sign(s));
        r2=r1.*sign(r1);
        Rati=r1.*(2-r2);
        dRati=(2./(1+s.*sign(s))).*(1-r2.*(2-r2));  
        mu=mean(s.*Rati,2);
        nu=mean(dRati,2);
        beta=mean(Rati.^2,2);
    case 'gaus'
        aexp=exp(-s.^2/2);
        mu=mean(s.^2.*aexp,2); 
        nu=mean((1-s.^2).*aexp,2); 
        beta=mean((s.*aexp).^2,2);
    case 'pow3'
        mu=mean(s.^4,2); 
        nu=3*ones(dim,1); 
        beta=mean(s.^6,2);
end
J=ones(1,dim); gam=(nu-mu)'; jm=(beta-mu.^2)';
Werr=(jm'*J+J'*jm+J'*gam.^2)./(abs(gam)'*J+J'*abs(gam)).^2;
Werr=Werr-diag(diag(Werr));
ISRsymm=Werr/N;
%SIRsymm=-10*log10(sum(Werr,2)'/N);

ekurt=mean(pwr(s,4),2); %%% estimate fourth moment


%EFICA - finetuning


for j=1:dim
       w=W(:,j);
       if ekurt(j)<2.4184   %%% sub-Gaussian -> try "GGD score function" alpha=>3
            if ekurt(j)<1.7  %%% the distribution seems to be extremly subgaussian
                %alpha=50; % bimodal-gaussian distribution will be
                %considered - good for noisy BPSK mixtures
                alpha=15;               
            else %%% estimate shape parameter alpha from the fourth moment 
                if ekurt(j)>1.8
                    alpha=1/(sqrt((5*ekurt(j)-9)/6/pi^2)+(1.202)*3*(5*ekurt(j)-9)/pi^4);
                else
                    alpha=15; %the distribution is likely uniform
                end
            end            
            if alpha<3 %%% the distribution is rather gaussian -> keep the original result
                w=W_before_decor(:,j);
            elseif alpha<=15 %%% try score function sign(x)*|x|^(alpha-1)                
                wold=zeros(dim,1);
                nit=0;
                alpha=ceil(min([alpha 15]));
                while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation))
                    w=w/norm(w);
                    wold=w;
                    u=Z'*w;
                    ualpha=pwr(u.*sign(u),alpha-2);
                    w=Z*(u.*ualpha)/N-(alpha-1)*mean(ualpha)*w;
                    nit=nit+1;  
                    TotalIt=TotalIt+1;
                end 
                 sest=(w/norm(w))'*Z; 
                 if abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation,
                     mu(j)=mean(pwr(sest.*sign(sest),alpha)); 
                     nu(j)=(alpha-1)*mean(pwr(sest.*sign(sest),alpha-2)); 
                     beta(j)=mean(pwr(sest.*sign(sest),2*alpha-2));
                     %fprintf('  Num of finetuning iter (subgauss): %d\n',nit);
                 end
            else  %trying bimodal distribution
                wold=zeros(dim,1);
                nit=0;
                while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation)) 
                    w=w/norm(w);
                    wold=w;
                    u=Z'*w;
                    m=mean(abs(u)); %estimate the distance of distribution's maximas
                    e=sqrt(1-m^2); %then their variance is..., because the overall variance is 1
                    if e<=0.05, e=0.05; m=sqrt(1-e^2); end %due to stability
                    uplus=u+m; uminus=u-m;
                    expplus=exp(-uplus.^2/2/e^2);
                    expminus=exp(-uminus.^2/2/e^2);
                    expb=exp(-(u.^2+m^2)/e^2);
                    g=-(uminus.*expminus + uplus.*expplus)./(expplus+expminus)/e^2;
                    gprime=-(e^2*(expplus.^2+expminus.^2)+(2*e^2-4*m^2)*expb)./(expplus+expminus).^2/e^4;
                    w=Z*g/N-mean(gprime)*w;              
                    nit=nit+1;  
                    TotalIt=TotalIt+1;
                end 
                u=(w/norm(w))'*Z; 
                if abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation,
                    m=mean(abs(u)); e=sqrt(1-m^2);
                    uplus=u+m; uminus=u-m;
                    expplus=exp(-uplus.^2/2/e^2); expminus=exp(-uminus.^2/2/e^2); expb=exp(-(u.^2+m^2)/e^2);
                    g=-(uminus.*expminus + uplus.*expplus)./(expplus+expminus)/e^2;
                    gprime=-(e^2*(expplus.^2+expminus.^2)+(2*e^2-4*m^2)*expb)./(expplus+expminus).^2/e^4;
                    mu(j)=mean(u.*g); 
                    nu(j)=mean(gprime); 
                    beta(j)=mean(g.^2);
                end
            end %bi-modal variant
       elseif ekurt(j)>3.762      %%% supergaussian (alpha<1.5)
           switch SupergaussianNL
               case 'npnl' %nonparametric density model; the same as in NPICA algorithm; very slow
                   wold=zeros(dim,1);
                   nit=0;
                   while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation)) 
                       w=w/norm(w);
                       [G GP]=nonln(w'*Z);
                       wold=w;
                       w=Z*G'/N-mean(GP)*w;
                       nit=nit+1;
                       TotalIt=TotalIt+1;
                   end
                   [G GP]=nonln((w/norm(w))'*Z); 
                   mu(j)=mean(((w/norm(w))'*Z).*G);nu(j)=mean(GP);beta(j)=mean(G.^2);
               case 'gaus'
                   wold=zeros(dim,1);
                   nit=0;
                   while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation)) 
                       w=w/norm(w);
                       aexp=exp(-(w'*Z).^2/2);
                       wold=w;
                       w=Z*((w'*Z).*aexp)'/N-w*mean((1-(w'*Z).^2).*aexp);
                       nit=nit+1;
                       TotalIt=TotalIt+1;
                   end
                   sest=(w/norm(w))'*Z; aexp=exp(-sest.^2/2);
                   mu(j)=mean(sest.^2.*aexp);
                   nu(j)=mean((1-sest.^2).*aexp);
                   beta(j)=mean((sest.*aexp).^2);
                   %fprintf('  Num of finetuning iter(supergauss): %d\n',nit);
               case 'rat3'
                   if mean(1./(1+s(j,:).^2))>0.7149
                       b=6;
                   else
                       b=4;
                   end
                   wold=zeros(dim,1);
                   nit=0;
                   while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation)) 
                       w=w/norm(w);
                       u=w'*Z;
                       r1=1./(1+b*u.*sign(u));
                       r2=r1.^2;
                       Rati=u.*r2;
                       dRati=r2-2*b*abs(Rati).*r1;
                       wold=w;
                       w=Z*Rati'/N-w*mean(dRati);
                       nit=nit+1;
                       TotalIt=TotalIt+1;
                   end
                   if abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation,
                       u=(w/norm(w))'*Z;
                       r1=1./(1+b*u.*sign(u));
                       r2=r1.^2;
                       Rati=u.*r2;
                       dRati=r2-2*b*abs(Rati).*r1;
                       mu(j)=mean(u.*Rati);
                       nu(j)=mean(dRati);
                       beta(j)=mean(Rati.^2);
                    %   fprintf('  Num of finetuning iter(supergauss): %d\n',nit);
                   end
               case 'ggda' %our proposal
                   gam=3.3476;                   
                   wold=zeros(dim,1);
                   nit=0;
                   while ((1-abs(w'*wold/norm(w))>fineepsilon) && (nit<FinetuneMaxIt) &&...
                          (abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation)) 
                       w=w/norm(w);
                       u=w'*Z;
                       ualpha=u.*sign(u);
                       aexp=exp(-gam*ualpha);
                       wold=w;
                       w=Z*(u.*aexp)'/N-w*mean((1-gam*ualpha).*aexp);
                       nit=nit+1;
                       TotalIt=TotalIt+1;
                   end
                   if abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))>min_correlation,
                       sest=(w/norm(w))'*Z; ualpha=abs(sest); aexp=exp(-gam*ualpha);
                       mu(j)=mean(sest.^2.*aexp);
                       nu(j)=mean((1-gam*ualpha).*aexp);
                       beta(j)=mean((sest.*aexp).^2);
                   end
           end
       else  % alpha \in (1.5, 3) ; keep the original nonlinearity
           w=W_before_decor(:,j);
       end
       if abs((W(:,j)/norm(W(:,j)))'*(w/norm(w)))<min_correlation  
           %%%%  the signal changed too much, thus, 
           %%%%  seems to be rather gaussian -> keep the original
           %%%%  nonlinearity and result due to global convergence
           W(:,j)=W_before_decor(:,j);
       else
           W(:,j)=w;
       end
end

if verbose,
fprintf('Total number of iterations/component: %.1f\n',TotalIt/dim);
end

%Refinement
J=abs(mu-nu)';
B=(beta-mu.^2)';
Werr=zeros(dim); 
for k=1:dim
    ccc=(J*B(k)/J(k))./(B+J.^2);ccc(k)=1;
    WW=W*diag(ccc);
    sloupce=setdiff(1:dim,find(sum(WW.^2)/max(sum(WW.^2))<1e-7)); % removing almost zero rows
    M=WW(:,sloupce);
    M=symdecor(M);
    if sum(sloupce==k)==1
        Wefica(:,k)=M(:,sloupce==k);
    else
        w=null(M');
        if size(w,2)==1
            Wefica(:,k)=w(:,1);
        else % there are probably more than two gaussian components => use the old result to get a regular matrix
            Wefica(:,k)=Wsymm(:,k);
        end
    end
    %Estimate variance of elements of the gain matrix
    Werr(k,:)=B(k)*(B+J.^2)./(J.^2*B(k)+J(k)^2*(B+J.^2));
end
Werr=Werr-diag(diag(Werr));

ISRef=Werr/N;
Wefica=Wefica'*CC;
Wsymm=Wsymm'*CC;
icasig=Wefica*X + (Wefica*Xmean)*ones(1,N);

function [g,gprime]=nonln(X)
[d N]=size(X);
g=zeros(d,N);
gprime=zeros(d,N);
h=1.06*N^(-1/5);
for i=1:d
    for k=1:N
        Z=(X(i,k)-X(i,:))/h;
        Zsquare=Z.^2;
        Phi=exp(-Zsquare/2)/sqrt(2*pi);
        f=mean(Phi,2)'/h;
        fprime=-mean(Z.*Phi,2)'/h^2;
        fprime2=mean((Zsquare-1).*Phi,2)'/h^3;
        g(i,k)=-fprime./f;
        gprime(i,k)=-fprime2./f+g(i,k)^2;
    end
end

function x=pwr(a,n)
x=a;
for i=2:n
    x=x.*a;
end


function W=symdecor(M)
%fast symmetric orthogonalization
[V D]=eig(M'*M);
W=M*(V.*(ones(size(M,2),1)*(1./sqrt(diag(D)'))))*V';
