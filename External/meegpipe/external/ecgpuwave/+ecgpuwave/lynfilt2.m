function [Xpa,Xpb,D,F,Der]=lynfilt2(index,X,Fs,ns);

ns=length(X);
% ---- Derivative ----
Bd=[1,2,0,-2,-1]; Bd=(Fs/8)*Bd;
Ad=1;
Der=filter(Bd,Ad,X);
Der(3)=Fs*(X(2)-X(1));
Der(4)=(Fs/4)*(2*X(3)-2*X(1));
Td=2;

% ---- Delay compensation ----
T=Td;
Der(1:ns-(T))=Der(T+1:ns);
Der(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(Der)>=2*Fs
	rmax=max(abs(Der(1:2*Fs)));
else 
	rmax=max(abs(Der));
end
if rmax==0 rmax=1; end
Der=10*Der./rmax;

% ---- High pass filtering: All pass - Low pass ----
Fpa=1;
mpa=round(Fs/Fpa);
Bpa=zeros(1,2*mpa+1); Bpa(1)=1; Bpa(mpa+1)=-2; Bpa(2*mpa+1)=1;
Apa=[1,-2,1];
Xpa=filter(Bpa,Apa,X);
Tpa=(mpa-1);
T=Tpa;
Xpa(1:ns-(T))=(mpa^2)*X(1:ns-T)-Xpa(T+1:ns);
Xpa(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(Xpa)>=2*Fs
	rmax=max(abs(Xpa(1:2*Fs)));
else
	rmax=max(abs(Xpa));
end
if rmax==0 rmax=1; end
Xpa=10*Xpa./rmax;

% ---- Low pass filtering ----
%Fpb=60;
Fpb=45;  % JGM
mpb=round(Fs/Fpb);
Bpb=zeros(1,2*mpb+1); Bpb(1)=1; Bpb(mpb+1)=-2; Bpb(2*mpb+1)=1;
Apb=[1,-2,1];
Xpb=filter(Bpb,Apb,Xpa);
Tpb=(mpb-1);
T=Tpb+1;                       %antes Tpb.
Xpb(1:ns-(T))=Xpb(T+1:ns);
Xpb(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(Xpb)>=2*Fs
	rmax=max(abs(Xpb(1:2*Fs)));
else
	rmax=max(abs(Xpb));
end
if rmax==0 rmax=1; end
Xpb=10*Xpb./rmax;

% ---- Derivative ----
Bd=[1,2,0,-2,-1]; Bd=(Fs/8)*Bd;
Ad=1;
D=filter(Bd,Ad,Xpb);
D(3)=Fs*(Xpb(2)-Xpb(1));
D(4)=(Fs/4)*(2*Xpb(3)-2*Xpb(1));
Td=2;

% ---- Delay compensation ----
T=Td;
D(1:ns-(T))=D(T+1:ns);
D(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(D)>=2*Fs
	rmax=max(abs(D(1:2*Fs)));
else
	rmax=max(abs(D));
end
if rmax==0 rmax=1; end
D=10*D./rmax;

% ---- Low pass filtering for Q and T waves ----
Fpf=40;
mpf=round(Fs/Fpf);
Bpf=zeros(1,2*mpf+1); Bpf(1)=1; Bpf(mpf+1)=-2; Bpf(2*mpf+1)=1;
Apf=[1,-2,1];
Xpf=filter(Bpf,Apf,Xpb);
Tpf=mpf-1;
T=Tpf+1;                     %antes Tpf
Xpf(1:ns-(T))=Xpf(T+1:ns);
Xpf(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(Xpf)>=2*Fs
	rmax=max(abs(Xpf(1:2*Fs)));
else
	rmax=max(abs(Xpf));
end
if rmax==0 rmax=1; end
Xpf=10*Xpf./rmax;

% ---- Derivative ----
F=filter(Bd,Ad,Xpf);
F(3)=Fs*(Xpf(2)-Xpf(1));
F(4)=(Fs/4)*(2*Xpf(3)-2*Xpf(1));
Td=2;

% ---- Delay Compensation ----
T=Td;
F(1:ns-(T))=F(T+1:ns);
F(ns-(T-1):ns)=zeros(T,1);

% ---- Normalization ----
if length(F)>=2*Fs
	rmax=max(abs(F(1:2*Fs)));
else
	rmax=max(abs(F));
end
if rmax==0 rmax=1; end
F=2*F./rmax;



