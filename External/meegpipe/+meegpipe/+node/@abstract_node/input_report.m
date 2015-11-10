function report = input_report(obj, data)


import report.object.object;
import goo.pkgisa;
import misc.any2str;
import datahash.DataHash;
import mperl.file.spec.*;

report = get_report(obj);

print_title(report, 'Node input', 2);

if ischar(data),
    
    data = strrep(data, '\', '/');
    dataRef = DataHash(data);
    fprintf(report, '%s\n\n', ['[' data '][' dataRef ']']);
    
    base = catdir(get_full_dir(obj, data), 'remark');
    dataRel = abs2rel(rel2abs(data), base);
    print_link(report, dataRel, dataRef);
    
elseif pkgisa(data, 'physioset.physioset'),
    
    % Add a link to the binary output in the report
    set_method_config(data, 'fprintf', 'ParseDisp', true);
    set_method_config(data, 'fprintf', 'SaveBinary', false);
    
    subReport = object(data, 'Title', 'Node input');
    childof(subReport, report);
    generate(subReport);
    
    print_paragraph(report, 'See [input report][input]');
    
    print_ref(report, get_filename(subReport), 'input');
    
elseif iscell(data) && all(cellfun(@(x) ischar(x), data)) && ...
        all(cellfun(@(x) exist(x, 'file') > 0, data))
    % A cell array of file names. This is to accomodate the behavior of
    % node merge
    for i = 1:numel(data)
        data{i} = strrep(data{i}, '\', '/');
        dataRef = DataHash(data{i});
        fprintf(report, '%s\n\n', ['[' data{i} '][' dataRef ']']);
        
        base = catdir(get_full_dir(obj, data{i}), 'remark');
        dataRel = abs2rel(rel2abs(data{i}), base);
        print_link(report, dataRel, dataRef);
    end
    
else
    
    dims = regexprep(num2str(size(data)), '\s+', 'x');
    print_paragraph(report, '[%s %s]', dims, class(data));
   
    
end



end