function obj = dummy_default(varargin)
% DUMMY_DEFAULT - A default constructor for the dummy node
%
% An illustration of a default constructor for a data processing node. This
% function is provided for illustration purposes only as dummy nodes do 
% not perform any actual data processing.
%
% See also: dummy


import misc.process_arguments;
import meegpipe.*;

opt.HigherLevelOpt1 = 2;
opt.HigherLevelOpt2 = 'something';

[~, opt] = process_arguments(opt, varargin);


obj = node.dummy.dummy(...
    'ConfigOpt1', opt.HigherLevelOpt1^2, ...
    'ConfigOpt2', [opt.HigherLevelOpt2, num2str(opt.HigherLevelOpt1)], ...
    'Save', true ...
    );




end