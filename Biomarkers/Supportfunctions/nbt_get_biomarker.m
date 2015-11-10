function [A,U]=nbt_get_biomarker(file_name,biomarker,A,ObjectSwitch)
error(nargchk(3,4,nargin))
ind=findstr(biomarker,'.');
S =load(file_name,biomarker(1:ind(1)-1));
if(exist('ObjectSwitch','var'))
    A = S.(biomarker(1:ind(1)-1));
    U = A.BiomarkerUnits;
else
if isfield(S,biomarker(1:ind(1)-1))
    tmp = eval(['S.',biomarker]);
    tmp = tmp(:);
    A=[A tmp];
    try
        t = strtok(biomarker,'.');
        U=eval(['S.',t,'.BiomarkerUnits']);
    catch ME
        U = '';
    end
else
    U = '';
    name = findstr(file_name,'/');
    file_name = file_name(name(end)+1:end);
    display(['The file ' file_name ' does not contain the biomarker ' biomarker])
end
end
end