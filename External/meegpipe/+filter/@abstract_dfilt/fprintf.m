function count = fprintf(fid, obj, gallery)
% FPRINTF - Print a Remark report using an open file handle
%
% count = fprintf(fid, obj, gallery)
%
% Where
%
% FID is an open file handle (or an open io.safefid object)
%
% OBJ is filter.dfilt object
%
% GALLERY is a gallery object, that especifies the formatting of the
% generated Remark gallery
%
% See also: report.gallery.gallery


import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import misc.unique_filename;
import misc.fid2fname;
import plotter.fvtool2.fvtool2;

if nargin < 3 || isempty(gallery),
    gallery = report.gallery.gallery;
end

analysis = mjava.hash;

% Plot freq. resp. magnitude
analysis('Frequency response magnitude') = {};
analysis('Frequency response phase') = ...
    {'Analysis', 'phase', 'PhaseDisplay', 'Continuous Phase'};

analysisKeys = keys(analysis);
for aIter = 1:numel(analysisKeys),
    
    %% Plot using fvtool2
    thisAnalysis = analysisKeys{aIter};
    thisAnalysisSpecs = analysis(thisAnalysis);
    
    h = fvtool2(mdfilt(obj), 'Visible', false, thisAnalysisSpecs{:});
  
    set_line(   h, [],  'LineWidth', 2, 'Color', 'Black');
    set_xlabel( h,      'FontSize', 12);
    set_ylabel( h,      'FontSize', 12);
    set_title(  h,      'FontSize', 14);
    set_axes(   h,      'FontSize', 14);
    
    filePath = fileparts(fid2fname(fid));
    
    %% Save .png figure
    set_title(gallery, get_name(obj));
    
    filtName        = regexprep(get_name(obj), '[^\w]+', '-');
    imgFileName     = [filtName '-freqresp'];
    imgFullFileName = catfile(filePath, imgFileName);
    imgFullFileName = unique_filename(imgFullFileName, true);
    [~, imgFileName] = fileparts(imgFullFileName);
    
    print(gcf, '-dpng', imgFullFileName);
    
    add_figure(gallery, ...
        ...
        [imgFileName '.png'], ...               % File name
        thisAnalysis, ...                       % Fig caption
        false, ...                               % Thumbnail?
        false ...                               % Link?
        );
    
    
    %% Save also a .svg version
    evalc('plot2svg([imgFullFileName ''.svg'']);');
    
    add_figure(gallery, ...
        ...
        [imgFileName '.svg'], ...               % File name
        thisAnalysis, ...                       % Fig caption
        true, ...                               % Thumbnail?
        false ...                               % Link?
        );
    
    %% Print also a .pdf version
    print('-dpdf', imgFullFileName);
    
    add_figure(gallery, ...
        ...
        [imgFileName '.pdf'], ...               % File name
        [thisAnalysis ' (.pdf)'], ...           % Fig caption
        true, ...                               % Thumbnail?
        true ...                                % Link?
        );
    
    %% An a .pdf version on a black background
    blackbg(h);
    print('-dpdf', [imgFullFileName '-black']);
    
    add_figure(gallery, ...
        ...
        [imgFileName '-black.pdf'], ...               % File name
        [thisAnalysis ' (black, .pdf)'], ...    % Fig caption
        true, ...                               % Thumbnail?
        true ...                                % Link?
        );
    
    clear h; % We are done with this analysis
    
    
end

%% Print the gallery

count = fprintf(fid, gallery);


end