function x = est04_SAwarner(SA,HR,onset,tSA)
% EST04_SAwarner  CO estimator 4: Warner's systolic area with time correction
%
%   In:   SA    <nx1>     vector  --- beat-to-beat systolic pressure area
%         HR    <nx1>     vector  --- beat-to-beat heart rate
%         ONSET <(n+1)x1> vector  --- beat-to-beat onset time in samples
%         TSA   <(n+1)x1> vector  --- beat-to-beat end-of-systole time in samples
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.


if length(onset)~=(length(tSA)+1)
    error('need 1 more onset pt');
end

Tsys  = tSA - onset(1:end-1);
Tdias = onset(2:end) - tSA;

Tdias(Tdias==0) = nan;

x = (1+Tsys./Tdias) .* SA .* HR;