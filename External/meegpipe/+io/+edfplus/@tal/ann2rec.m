function annOut = ann2rec(annIn, annOnset, annDur, recOnset, nBytes)
% ANN2REC
% Breaks a raw array of TALs into multiple data records
%
% annOut = ann2rec(annIn, annOnset, annDur, recOnset, nBytes)
%
%
% Where
%
% ANNOUT is a 1xN cell array with N sets of TALs, which are to be stored in
% K data records.
%
% ANNIN is a 1xM cell array with M annotation texts
%
% ANNONSET is a 1xM numeric array with annotation onset times (in seconds)
%
% ANNDUR is a 1xM numeric array with annotation durations (in seconds)
%
% NBYTES is the maximum number of bytes per record that can be allocated
% for TALs.
%
% RECONSET is a 1xK numeric array with records onset times. 
%
%
%
% See also: edfplus.tal, EDFPLUS

char21 = '&';%char(21);
char20 = '|';%char(20);
char0 = '_';

nRec = numel(recOnset);

% Initialize the output record-organized annotations
annOut = repmat({repmat(char0, 1, nBytes)}, 1, nRec);

annCount = 1;
nAnn = numel(annIn);
for recIter = 1:nRec
    if annCount > nAnn, break; end
    onset = ['+' num2str(recOnset(recIter))];
    annOut{recIter}(1:numel(onset)) = onset;
    byteCount = numel(onset);
    annOut{recIter}(byteCount+1:byteCount+3) = ...
        [char20 char20 char0];
    byteCount = byteCount + 3;
    
    % The first actual annotation in this record
    if annOnset(annCount) > 0,
        onsetStr = ['+' num2str(annOnset(annCount))];
    else
        onsetStr = num2str(annOnset(annCount));
    end
    durStr   = num2str(annDur(annCount));
    newAnn = [onsetStr char21 durStr char20 annIn{annCount} char20 char0];
    
    % Insert annotations until recordis full
    while ((byteCount + numel(newAnn)) <= nBytes)
        annOut{recIter}(byteCount+1:byteCount+numel(newAnn)) = newAnn;
        byteCount = byteCount + numel(newAnn);
        annCount = annCount + 1;
    end    
end

if annCount < (nAnn+1),
    warning('EDFPLUS:tal:ann2rec:Overflow', ...
        '%d annotations were left out', nAnn-annCount+1);
end


end