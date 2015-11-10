function methodConfig = default_method_config(varargin)

import misc.process_arguments;

defaults = ...
    {...
    'fprintf' , {'ParseDisp', true, 'SaveBinary', false} ...
    };

methodConfig = goo.method_config(defaults{:});


end