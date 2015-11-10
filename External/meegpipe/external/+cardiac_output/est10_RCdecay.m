function x = est10_RCdecay(Period,Ps,Pd,MAP)
% EST10_RCdecay  CO estimator 10: Windkessel RC decay
%

T = Period/125;

Ps(Ps==0) = nan;
Pd(Pd==0) = nan;

tau = T./log(Ps./Pd);
tau(tau==0)=nan;


x = MAP./tau;