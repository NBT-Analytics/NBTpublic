function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Processes an EEG dataset using a pipeline
%
%
%
% See also: pipeline, node, abstract_node


import goo.globals;
import misc.get_username;
import misc.get_hostname;

dataNew = [];

nodes = get_config(obj, 'NodeList');
verboseLabel = get_verbose_label(obj);

if is_verbose(obj)
    fprintf([verboseLabel 'Running MATLAB %s under account %s on %s ...\n\n'], ...
        version, get_username, get_hostname);        
end

for i = 1:numel(nodes)
    
    if isempty(nodes{i}),
        continue;
    end
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Going to run node %s ...\n\n'], ...
            get_name(nodes{i}));
     
    end
    
    [data, dataNew] = run(nodes{i}, data);
    
    if is_verbose(obj),
        fprintf([verboseLabel 'Finished running node %s from %s ...\n\n'], ...          
            get_name(nodes{i}), ...
            get_name(obj));
       
    end
    
end



end
