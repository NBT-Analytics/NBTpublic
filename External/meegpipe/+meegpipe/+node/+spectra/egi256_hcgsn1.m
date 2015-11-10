function obj = egi256_hcgsn1(varargin)

import meegpipe.node.*;

obj = spectra.new(...
    'Channels2Plot', ...
    { ...
    '^EEG 69$', '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$', '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+', ...
    });

end