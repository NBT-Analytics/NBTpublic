function generate(obj)


import report.object.object;
import misc.process_arguments;
import report.table.table;
import report.gallery.gallery;
import misc.dimtype_str;
import misc.obj2struct;
import report.struct2xml;
import misc.dimtype_str;
import report.disp2table;
import misc.fid2fname;

generate@report.generic.generic(obj);

fid   = get_fid(obj);

%% Report generation
for i = 1:numel(obj.Objects)
    
    thisObj = obj.Objects{i};    
   
    if isa(thisObj, 'filter.abstract_dfilt'),
        
        fprintf(fid, thisObj, gallery('Level', get_level(obj)+1));
        
     elseif isa(thisObj, 'physioset.physioset')
         
         print_title(obj, 'Summary information', get_level(obj) + 1);
         fprintf(fid, thisObj);
         
         print_title(obj, 'Sensor information', get_level(obj) + 1);
         fprintf(fid, sensors(thisObj));
         
         evArray = get_event(thisObj);
         if ~isempty(evArray)
             print_title(obj, 'Events information', get_level(obj) + 1);
             fprintf(fid, evArray, 'SummaryOnly', true);
         end
         
    elseif isa(thisObj, 'goo.reportable') || ...
            isa(thisObj, 'goo.reportable_handle'),
        
        level = get_level(obj) + 1;        
        
        fprintf(fid, '\n\n');
        
        title = get_title(obj);
        
        if isempty(title), title = 'Object properties'; end
        
        fprintf(fid, '%s %s\n\n', repmat('#', 1, level), title);
        
        [pName, pValue, pDescr] = report_info(thisObj);
        
        if isempty(pValue),
            
            fprintf(fid, ...
                '\n\nNo information on this object\n\n');
            continue;
            
        end
        
        [pValue, refs] = pval2str(obj, pValue, 'propname', pName);                
 
        myTable = add_column(table, 'Property', 'Value', 'Description');
       
        for j = 1:numel(pName),
            myTable = add_row(myTable, pName{j}, pValue{j}, pDescr{j});
        end
        
        myTable = add_ref(myTable, refs(:,1), refs(:,2));        
        
        fprintf(fid, myTable);  
        
    else
        name = dimtype_str(thisObj);
        rootDir = fileparts(fid2fname(fid));
        warning('off', 'MATLAB:structOnObject');
        [ref, refTarget] = struct2xml(rootDir, struct(thisObj)); 
        warning('on', 'MATLAB:structOnObject');
        print_paragraph(obj, '[%s][%s]', name, ref);
        print_link(obj, refTarget, ref);
        myTable = disp2table(thisObj);
        fprintf(fid, myTable);
    end
    
    fprintf(fid, '\n\n');
    
end

%pause(.5);

end




