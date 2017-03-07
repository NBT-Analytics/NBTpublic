% eegplugin_aar() - EEGLAB plugin for automatic artifact removal using AAR
% Matlab toolbox. More information and latest version at:
% http://www.cs.tut.fi/~gomezher/software.htm 
%
% Usage:
%   >> eegplugin_aar(fig, trystrs, catchstrs)
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks. 
%
% Create a plugin:
%   For more information on how to create an EEGLAB plugin see the
%   help message of eegplugin_besa() or visit http://www.sccn.ucsd.edu/eeglab/contrib.html
%
% Author:  German Gomez-Herrero (german.gomezherrero@gmail.com, ISP/TUT, 
%          Tampere, Finland, 2006) 

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) <2007>  German Gomez-Herrero, http://germangh.com

function vers = eegplugin_aar(fig, trystrs, catchstrs)

vers = 'aar1.3 (R060409)';
if nargin < 3
    error('eegplugin_aar requires 3 arguments');
end;


% add plugin folder to path
% -----------------------
if exist('pop_autobsseog.m','file')
    p = which('eegplugin_aar');
    p = p(1:findstr(p,'eegplugin_aar.m')-1);
    addpath(p);    
end;

% find tools menu
% ---------------------
menu = findobj(fig, 'tag', 'tools');


% menu callbacks
% --------------
eeglabel_cback = [ trystrs.no_check '[LASTCOM] = pop_eeglabel(EEG);' catchstrs.add_to_hist ];
autobsseog_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_autobsseog(EEG);' catchstrs.new_and_hist ];
autobssemg_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_autobssemg(EEG);' catchstrs.new_and_hist ];
lms_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_lms_regression(EEG);' catchstrs.new_and_hist ];
crls_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_crls_regression(EEG);' catchstrs.new_and_hist ];
scrls_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_scrls_regression(EEG);' catchstrs.new_and_hist ];
hinftv_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_hinftv_regression(EEG);' catchstrs.new_and_hist ];
hinfew_cback = [ trystrs.no_check '[EEG LASTCOM] = pop_hinfew_regression(EEG);' catchstrs.new_and_hist ];

% create menus if necessary
% -------------------------
submenu = uimenu( menu, 'Label', 'Artifact removal using AAR 1.3');
uimenu( submenu, 'Label', 'Label EEG epochs', 'CallBack', eeglabel_cback);
submenu21 = uimenu(submenu,'Label','EOG removal');
uimenu( submenu, 'Label', 'EMG removal using BSS',  'CallBack', autobssemg_cback);
uimenu( submenu21, 'Label', 'Using BSS',  'CallBack', autobsseog_cback);
uimenu( submenu21, 'Label', 'Using LMS regression',  'CallBack', lms_cback);
uimenu( submenu21, 'Label', 'Using RLS regression',  'CallBack', crls_cback);
uimenu( submenu21, 'Label', 'Using stable RLS regression',  'CallBack', scrls_cback);
uimenu( submenu21, 'Label', 'Using Hinf EW regression',  'CallBack', hinfew_cback);
uimenu( submenu21, 'Label', 'Using Hinf TV regression',  'CallBack', hinftv_cback);

