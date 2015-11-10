function extract_bss_features(obj, bssObj, ics, data, icSel)

import misc.num2strcell;
import misc.eta;

verboseLabel = get_verbose_label(obj);
verbose = is_verbose(obj);

featExtractor   = get_config(obj, 'Feature');
featTarget      = get_config(obj, 'FeatureTarget');

if isempty(featExtractor),
    return;
end

rep = get_report(obj);
print_title(rep, 'BSS feature extraction', get_level(rep)+2);

if do_reporting(obj),
    % A sub-report to hold feature extraction reports
    featRep = report.generic.new('Title', 'BSS feature extraction report');
    featRep = childof(featRep, rep);
    print_link2report(rep, featRep);
end

if strcmpi(featTarget, 'selected'),
    if isempty(icSel), return; end
    select(ics, icSel);
else
    clear_selection(bssObj);
end

for i = 1:numel(featExtractor)
    extractorName = get_name(featExtractor{i});
    fid = get_log(obj, ['features_' extractorName '.txt']);
    if verbose,
        fprintf([verboseLabel 'Writing %s features to %s ...\n\n'], ...
            get_name(featExtractor{i}), fid.FileName);
    end
    fid = get_log(obj, ['features_' extractorName '.txt']);
    
    if do_reporting(obj),
        print_paragraph(rep, ['Extracted ' extractorName ...
            ' BSS features: [features_' extractorName '.txt][feat]']);
        print_link(rep, ['../features_' extractorName '.txt'], 'feat');
        
        print_title(featRep, get_name(featExtractor{i}), get_level(featRep)+1);
        fprintf(featRep, featExtractor{i});
        fprintf(featRep, '\n\n');
    else
        featRep = [];
    end
    [fVal, fName] = ...
        extract_feature(featExtractor{i}, bssObj, ics, data, featRep);
    
    % Ensure the feature matrix has the right dimensions:
    % (numICs,numFeat)
    if size(fVal, 1) ~= bssObj.DimOut,
        fVal = fVal';
    end
    if isempty(fName), fName = num2strcell(1:size(fVal, 2)); end
    hdr = ['feature_extractor,BSS_alg,BSS,', mperl.join(',', fName) '\n'];
    fid.fprintf(hdr);

    fmt = repmat(',%.4f', 1, size(fVal, 2));
    
    if verbose,
        nIterBy100 = floor(size(fVal, 1)/100);
        tinit = tic;
    end
    
    for j = 1:size(fVal, 1)
        fid.fprintf('%s,%s,%d', extractorName, get_name(bssObj), j);
        fid.fprintf([fmt '\n'], fVal(j,:));
        if verbose && ~mod(j, nIterBy100),
            misc.eta(tinit, size(fVal, 1), j);
        end
    end
    if verbose,
        fprintf('\n\n');
        clear +misc/eta;
    end
end

if strcmpi(featTarget, 'selected'),
    restore_selection(ics);
end

if ics.Transposed,
    % The tstat extractor simply returns a transposed version of the ics
    transpose(ics);
end

end