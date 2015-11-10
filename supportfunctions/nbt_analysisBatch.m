%make sure only files in directory are analysis and signal files, and that
%they have the same names..

dirList = ls;

for i = 3:size(dirList,1)
    x = strfind(dirList(i,:),'analysis');
    if size(x,1) == 1
        disp([dirList(i,:),'   Ignore']);
    else
        disp([dirList(i,:),' Analysing']);
        try 
        plot_amplitudes_all_channels_Sig(deblank(dirList(i,:)),0);
        catch
            disp([dirList(i,:),' ERROR:skipping file']);
        end
    end
    close all
    
end
    
    