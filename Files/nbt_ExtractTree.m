function A=nbt_ExtractTree(startpath, fileext, filetype, A)
error(nargchk(3,4,nargin));

if(nargin < 4)
    A = cell(0,0);
end

d = dir (startpath);
for j=3:length(d)
    if (d(j).isdir )
        A =nbt_ExtractTree([startpath,'/', d(j).name ], fileext, filetype, A);
    else
        b = strfind(d(j).name,fileext);
        cc= strfind(d(j).name,filetype);
        
        if (length(b)~=0  && length(cc)~=0)
            A = [A, [startpath , '/',d(j).name]];
        end
    end
end
end