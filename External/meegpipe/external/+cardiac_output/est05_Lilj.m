function x = est05_Lilj(PP,HR,Psys,Pdias)
% EST05_Lilj  CO estimator 5: Liljestrand and Zander's PP/(Psys+Pdias)
%
%   In:   PP    <nx1> vector  --- beat-to-beat pulse pressure
%         HR    <nx1> vector  --- beat-to-beat heart rate
%         Psys  <nx1> vector  --- beat-to-beat systolic pressure
%         Pdias <nx1> vector  --- beat-to-beat diastolic pressure
%
%   Out:  X    <nx1> vector  --- estimated CO (uncalibrated)
% 
%   Written by James Sun (xinsun@mit.edu) on Nov 19, 2005.

x = (PP./(Psys+Pdias)) .* HR;