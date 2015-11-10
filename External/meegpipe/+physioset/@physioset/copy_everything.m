function copy_everything(x, y)

y.EqWeights         = x.EqWeights;
y.EqWeightsOrig     = x.EqWeightsOrig;
y.PhysDimPrefixOrig = x.PhysDimPrefixOrig;
y.BadChan           = x.BadChan;
y.BadSample         = x.BadSample;
y.ProcHistory       = x.ProcHistory;
y.SensorsHistory    = x.SensorsHistory;
y.RerefMatrix       = x.RerefMatrix;
y.EventMapper       = x.EventMapper;

set_name(y, get_full_name(x));

if ~isempty(x.PntSelection) || ~isempty(x.DimSelection),
    select(y, x.DimSelection, x.PntSelection);
end

set_meta(y, get_meta(x));

end