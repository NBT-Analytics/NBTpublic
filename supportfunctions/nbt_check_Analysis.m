function nbt_check_Analysis(filepath)
%make sure only analysis files are in the directory
cd (filepath);
x = ls;
for i = 3:size(x,1)
    %check whether signal files contain ICA
%    disp(['Checking ', deblank(x(i,:))]);
    %check whether signal files contain ICA
    try
    load(deblank(x(i,:)));
    catch me
        disp(me.message)
    end
    if exist('amplitude_13_30_Hz') == 0
        disp(['Error in file: ',x(i,:),' . Missing amplitude data']);
    end

  
    clear all
    close all    
    x = ls;
end
