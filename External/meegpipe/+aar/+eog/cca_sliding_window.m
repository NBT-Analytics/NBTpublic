function myNode = cca_sliding_window(varargin)
% CCA_SLIDING_WINDOW - Reject EOG-like CCA components in sliding windows
%
% ## Usage synopsis
% 
% myNode = aar.eog.cca_sliding_window('key', value, ...)
%
% 
% ## Accepted key/value configuration pairs:
%
% WindowLength      :  The length of the sliding window in seconds    
%                      Default: 10
%
% WindowOverlap     :  The overlap (in percentage) between correlative
%                      CCA windows. Increasing this value generally leads
%                      to better correction but increases computation time. 
%                      Default: 75
% 
% CorrectionTh      :  A correction threshold in percentage. Increasing
%                      Correction will lead to a harsher correction.
%                      Default: 25
%
% VarTh             :  Variance threshold in percentage. This parameter is
%                      used to control the number of CCA components. 
%                      Default: 99.99
%
%
% See also: filter.cca, bss.node.filter, filter.sliding_window

import misc.process_arguments;
import misc.split_arguments;


error('UnderConstruction');

end