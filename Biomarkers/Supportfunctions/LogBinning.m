function [x_log,y_log]=LogBinning(x,y,res_logbin);
% 
% Modified k.linkenkaer@nih.knaw.nl, 031212.
% Modified poil@get2net.dk, 25.october 2006
%
%******************************************************************************************************************
% Purpose:
%
% A function for transforming the two vectors 'x' and 'y', which are functions of each other, 
% to be functions of each other on a logarithmically equidistant scale.
%
%******************************************************************************************************************
% Input parameters:
% 
% x		: x-axis data to be binned.
% y		: corresponding y-axis data to be binned.
% res_logbin	: number of bins pr decade, i.e., the spacing of the logarithmic scale.
%
%******************************************************************************************************************
% Output parameters:
%
% x_log:    the values in 'x' have been binned on a logarithmically equidistant scale
% y_log	:   gives the mean value fo 'y' in each of the bins given in 'x_log'
%
% NOTE! log10 has not been taken of the output
%******************************************************************************************************************
% Default parameter settings...

if size(x,1) > 2;  x = x'; end
if size(y,1) > 2;  y = y'; end


%******************************************************************************************************************
% Defining window sizes to be log-linearly increasing.

d1 = floor(log10(min(x(x>0))));
d2 = ceil(log10(max(x)));
x_log_t = logspace(d1,d2,(d2-d1)*res_logbin);			% Create vector from 10^d1 to 10^d2 with N log-equidistant points.
x_log = x_log_t(find(min(x) <= x_log_t & x_log_t <= max(x)));	% Weed out bins that wont catch any data.
y_log = zeros(1,size(x_log,2));					% Initialize y-log.


%******************************************************************************************************************
% Log-bin the values of y:

% Note: the initial 4 values cannot be binned properly because of the finite sampling frequency (would give empty bins, which are now defined as zero!).
for i=5:size(x_log,2);
  if round(x_log(i)/(x(2)-x(1))) == round(x_log(i-1)/(x(2)-x(1))) 
  else  
    LogSample_s = round(x_log(i-1)/(x(2)-x(1)))+1;
    LogSample_e = round(x_log(i)/(x(2)-x(1)));
    y_t = y(LogSample_s:LogSample_e);
    y_log(i)=10^(mean(log10(y_t(y_t>0))));
  end
end
