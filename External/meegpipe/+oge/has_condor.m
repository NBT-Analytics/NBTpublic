function bool = has_condor
% has_condor - Returns true if HTC Condor is available in this system
%
% bool = has_condor
%
% BOOL is true if Condor is available, and is false otherwise
%
% See also: has_oge, oge

[~, res] = system('condor_status');

bool = false;
if ~isempty(res) && ~isempty(regexp(res, 'slot\d\@', 'once')),
    bool = true;
    return;
end

if isunix,
    [~, res] = system('source ~/.bashrc;condor_status');
    if ~isempty(res) && ~isempty(regexp(res, 'slot\d\@', 'once')),
        bool = true;  
    end
end

end


