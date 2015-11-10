function make_bss_object_report(obj, myBSS, ics, rep, verbose, verboseLabel)

if get_config(obj, 'SaveActivations'),
    if verbose,
        fprintf([verboseLabel 'Saving SPCs activations ...']);
    end
    print_title(rep, 'Spatial components'' activations', get_level(rep) + 1);
    set_method_config(ics, 'fprintf', ...
        'ParseDisp',    false, ...
        'SaveBinary',   true);
    fprintf(rep, ics);
    if verbose, fprintf('[done]\n\n'); end
end

% The BSS object
print_title(rep, 'BSS decomposition', get_level(rep) + 1);

objRep = report.object.new(myBSS);
objRep = childof(objRep, rep);
generate(objRep);
[~, repName] = fileparts(get_filename(objRep));
fprintf(rep, 'BSS performed using algorithm [%s](%s)\n\n', class(myBSS), ...
    [repName '.htm']);

set_method_config(myBSS, 'fprintf', 'ParseDisp', false, 'SaveBinary', true);
fprintf(rep, myBSS);

end