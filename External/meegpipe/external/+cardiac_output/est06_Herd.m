function x = est06_Herd(MAP,Pdias,HR)
% EST06_Herd  CO estimator 6: Herd's method
%
%   In:   MAP   <nx1> vector  --- beat-to-beat mean arterial pressure
%         Pdias <nx1> vector  --- beat-to-beat diastolic pressure
%         HR    <nx1> vector  --- beat-to-beat heart rate
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = (MAP - Pdias) .* HR;