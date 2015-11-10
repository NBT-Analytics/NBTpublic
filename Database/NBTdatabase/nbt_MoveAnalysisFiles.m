function nbt_MoveAnalysisFiles(startpath)
d= dir (startpath);
for j=3:length(d)
    if (d(j).isdir )
        nbt_MoveAnalysisFiles([startpath,'/', d(j).name ]);
    else
        b = strfind(d(j).name,'mat');
        cc= strfind(d(j).name,'analysisAutoClean');
        
        if (length(b)~=0  && length(cc)~=0)
            movefile([startpath , '/', d(j).name ],[startpath , '/', d(j).name(1:(cc-1)) 'AutoClean.mat' ]);
        end
    end
end
end