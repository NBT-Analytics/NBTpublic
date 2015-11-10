function [data, dataNew] = process(obj, data, varargin)
% PROCESS - Main processing method for parallel_node_array nodes

import mperl.file.spec.abs2rel;
import mperl.file.spec.catfile;

verbose         = is_verbose(obj);
verboseLabel    = get_verbose_label(obj);

nodeList  = get_config(obj, 'NodeList');
aggrFunc  = get_config(obj, 'Aggregator');
copyInput = get_config(obj, 'CopyInput');

dataNew = [];

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);

nodesOutput = cell(1, numel(nodeList));

for nodeItr = 1:numel(nodeList),
    
    if copyInput,
        thisData = copy(data);
    else
        thisData = data;
    end
    
    if isempty(nodeList{nodeItr}),
        nodesOutput{nodeItr} = data;
        print_title(rep, sprintf('Node #%d: Empty node', nodeItr), ...
            get_level(rep)+2);
        print_paragraph(rep, ['This node simply redirects its input ' ...
            'to its output']);
        continue;
    end
    
    if verbose,
        fprintf([verboseLabel 'Going to run node %s ...\n\n'], ...
            get_name(nodeList{nodeItr}));
        
    end
    
    myObjRep = report.object.new(nodeList{nodeItr}, 'Title', ...
        sprintf('Node #%d: %s', nodeItr, get_name(nodeList{nodeItr})));
    embed(myObjRep, rep);
    generate(myObjRep);
    
    
    nodesOutput{nodeItr} = run(nodeList{nodeItr}, thisData);
    
    nodeRep =  get_report(nodeList{nodeItr});
    dirName = abs2rel(get_rootpath(nodeRep), get_rootpath(rep));
    
    nodeName = get_name(nodeList{nodeItr});
    print_paragraph(rep, '[Detailed report for %s][%s]', nodeName, ...
        nodeName);
    print_link(rep, catfile(dirName, 'index.htm'), nodeName);
    
    
end

if ~isempty(aggrFunc),
    data = aggrFunc(nodesOutput);
end


end