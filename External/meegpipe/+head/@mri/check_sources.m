function check_sources(obj)

InconsistentSources = MException('head:mri:check_sources', ...
    'Inconsistent sources. Do their temporal activations have the same length?');

nbSamples = [];
for i = 1:obj.NbSources
    if isempty(nbSamples), 
        nbSamples = size(obj.Source(i).activation,2);
    end
    if nbSamples ~= size(obj.Source(i).activation,2),
        throw(InconsistentSources);
    end
end

end