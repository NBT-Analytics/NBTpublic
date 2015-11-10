function pos = get_local_maxima_above_threshold(data,TH)
% GET_LOCAL_MAXIMA_ABOVE_THRESHOLD is used to identify the events derived from the trigger trace. 
% Its functionality resamples a function implemented in FBrain, but without looking that source code. 
%
% pos = get_local_maxima_above_threshold(data,TH)
%
% Input:
%   data: sample vector of detection trace
%   TH: threshold 
% Output: 
%   pos: time points of local maxima above threshold 
%
% see also: signal_deconvolution
%
% Reference(s): 
%  [1] A. Pernía-Andrade, S.P. Goswami, Y. Stickler, U. Fröbe, A. Schlögl, and P. Jonas (2012)
%     A deconvolution-based method with high sensitivity and temporal resolution for 
%     detection of spontaneous synaptic currents in vitro and in vivo.
%     Biophysical Journal Volume 103 October 2012 1–11.

% $Id$
% Copyright 2011,2012 Alois Schloegl, IST Austria <alois.schloegl@ist.ac.at>
% This is part of the BIOSIG-toolbox http://biosig.sf.net/ 


if numel(TH)==1,
	%%% InVitro Data from Sarit
	data = [data;+inf];
	pos = (data(1:end-1) >= TH) & (data(1:end-1) >  data(2:end) ) & (data(1:end-1) > [+inf;data(1:end-2)]);		%% local maxima above threshold

	ix  = (data(1:end-1) >= TH) & (data(1:end-1) == data(2:end) ) & (data(1:end-1) > [+inf;data(1:end-2)]);		%% local maxima above threshold

elseif numel(TH)==2,
	%%% InVivo data from Alejo
	th = repmat(NaN,size(data));
	th(1:end/2) = TH(1);
	th(end/2+1:end) = TH(2);

	data = [data;+inf];
	pos = (data(1:end-1) >= th) & (data(1:end-1) >  data(2:end) ) & (data(1:end-1) > [+inf;data(1:end-2)]);		%% local maxima above threshold

	ix  = (data(1:end-1) >= th) & (data(1:end-1) == data(2:end) ) & (data(1:end-1) > [+inf;data(1:end-2)]);		%% local maxima above threshold
end 

k   = 0; 
ix  = find(ix);
while (1) 
	k   = k+1;
	ix2 = ix + k;
	ix  = ix(data(ix2) <= data(ix));
	ix2 = ix + k;
	if (isempty(ix) || ~any(data(ix)==data(ix2))) break; end; 
end
pos = sort([find(pos); ix]);
return

%!assert(get_local_maxima_above_threshold([0,0,0,1,0]',0),4)
%!assert(get_local_maxima_above_threshold([0,0,0,1,1,0]',0),4)
%!assert(get_local_maxima_above_threshold([0,0,0,1,1,2,0]',0),6)
%!assert(get_local_maxima_above_threshold([0,0,0,3,1,1,0]',0),4)
%!assert(get_local_maxima_above_threshold([0,0,0,3,1,1,2,0]',0),[4;7])
%!assert(get_local_maxima_above_threshold([0,0,0,1,1,1,0]',0),4)

