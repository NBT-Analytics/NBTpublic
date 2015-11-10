function [pName, pVal, pDescr] = report_info(obj)

pName = fieldnames(obj);

pVal = cell(size(pName));

for i = 1:numel(pName)
   pVal{i} = obj.(pName{i}); 
end

% Add also configuration information
[pNameCfg, pValCfg] = report_info(get_config(obj));

pName  = [pName(:); pNameCfg(:)];
pVal   = [pVal(:); pValCfg(:)];
pDescr = repmat({''}, size(pVal));


end