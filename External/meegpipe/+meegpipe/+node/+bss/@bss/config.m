function fileName = get_output_filename(obj, data)


rej = get_config(obj, 'Reject');


fileName = get_output_filename@meegpipe.node.abstract_node(obj, data);
if ~isempty(rej),
    return;
end

BSSName = get_name(myBSS);
BSSName = regexprep(BSSName, '.+\.([^.]+$)', '$1');

fileName = regexprep(fileName, ['_' get_name(node) '\.pset$'], ...
    ['_' BSSName '-activations_' get_name(node) '.pset']);



end