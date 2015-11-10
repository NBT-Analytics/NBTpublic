function x = est12_coalees(PP,HR,onset,tSA,Ps,Pd)

Ts  = tSA - onset(1:end-1);
Td = onset(2:end) - tSA;

Td(Td==0) = nan;
Ps(Ps==0) = nan;

x = (1+(Pd./Ps).*(Ts./Td)) .* PP .* HR;