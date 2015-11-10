function check_Signal(filepath)
%make sure only Signal files are in the directory
%makes sure all Signal files contain ICA and ICAinfo

cd (filepath);
%clear all
%close all
x = ls;
for i = 3:size(x,1)
    disp(['Checking ', deblank(x(i,:))]);
    %check whether signal files contain ICA
    try
    load(deblank(x(i,:)));
    catch me
        disp(me.message)
    end
    if exist('ICA') == 0
        disp(['Error in file: ',x(i,:),' . Missing ICA']);
    end

    if exist('ICAInfo') == 0
                disp(['Error in file: ',x(i,:),' . Missing ICAInfo']);
    end
    clear all
    close all    
    x = ls;
end
