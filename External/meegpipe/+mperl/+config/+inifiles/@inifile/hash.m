function obj = hash(cfg, evaluate)
% HASH - Conversion to a hash object
%
% obj = hash(cfg)
%
% Where
%
% CFG is a inifile object
%
% OBJ is an equivalent mjava.hash object
%
%
% See also: mjava.hash


import misc.process_arguments;

if nargin < 2 || isempty(evaluate), evaluate = false; end

obj = mjava.hash;

secList = sections(cfg);
if isempty(secList),
    return;
else
    if ischar(secList), secList = {secList}; end
    
    for i = 1:numel(secList)
        paramList = parameters(cfg, secList{i});
        
        if ischar(paramList), paramList = {paramList}; end
        
        if isempty(paramList),
            thisHash = [];
        else
            thisHash = mjava.hash;
        end
        for j = 1:numel(paramList)
            value =  val(cfg, secList{i}, paramList{j});
            
            if evaluate,
                try
                    value = eval(value); %#ok<*AGROW>
                catch
                    % Do nothing
                    
                end
                thisHash(paramList{j}) = value;
                
            end
            obj(secList{i}) = thisHash;
        end
    end
    
end


end