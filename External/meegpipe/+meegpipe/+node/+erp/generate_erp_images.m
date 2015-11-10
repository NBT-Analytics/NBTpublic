function generate_erp_images(rep, sens, erp, time, vert, amp) 
% GENERATE_ERP_IMAGES - Plot ERP images to report
%
% generate_erp_images(rep, sens, erp, time)
%
% See also: meegpipe.node.erp.erp, erpimage

import meegpipe.node.globals;
import report.gallery.gallery;
import mperl.file.spec.catfile;
import misc.unique_filename;
import plot2svg.plot2svg;
import mperl.join;
import datahash.DataHash;


verbose = goo.globals.get.Verbose;
verboseLabel = goo.globals.get.VerboseLabel;

if size(vert,1) == 1,
    vert = repmat(vert, numel(sens, 1));
end

myGallery = gallery;

for i = 1:numel(sens)    
    
    title = sprintf('set %d (t=%dms ; A =%2.2f)', i, vert(i), amp(i)); %#ok<NASGU>
    
    % EEGLAB really wants the sort variable to be provided (thanks Johan)
    sort = ones(1,size(erp{i},2))*time(end); %#ok<NASGU>
    
    evalc(['erpimage(erp{i}, sort, time, title, 1, 1, ''erp'',' ...
        '''cbar'', ''vert'', vert(i,:))']);
    set(gcf, 'Visible', 'off');    
  
    thisName    = DataHash(rand(1,100));
    thisName    = thisName(1:8);
    fileName    = print_image(rep, ['erp-image-' thisName]);  
    sensList    = join(', ', sens{i});
    caption     = sprintf('ERP image for sensor set %d (%s)', i, sensList);  
    if verbose,
        fprintf([verboseLabel caption '...\n\n']);
    end
    myGallery   = add_figure(myGallery, fileName, caption);   
    close;

end

fprintf(rep, myGallery);

end