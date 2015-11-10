function argin = prepend_varargin(argin, varargin)

pos = 0;
while (numel(argin) > pos && ~ischar(argin{pos+1})),
    pos = pos+1;
end

argin = [argin(1:pos) varargin argin(pos+1:end)];

end