function count = fprintf(fid, obj, gallery, makeFig, varargin)
% FPRINTF - Print pca object to remark report
%
% count = fprintf(fid, obj)
%
% Where
%
% FID is an open file handle or a io.safefid object.
%
% OBJ is an already trained spt.pca.pca object.
%
% GALLERY is a gallery object, that especifies the formatting of the
% generated Remark gallery
%
% See also: learn, pca, report.report, io.safefid


import meegpipe.node.globals;
import misc.unique_filename;
import misc.fid2fname;
import mperl.file.spec.catfile;
import plot2svg.plot2svg;
import report.object.object;
import inkscape.svg2png;

if nargin < 4 || isempty(makeFig),
    makeFig = true;
end

if nargin < 3 || isempty(gallery),
    gallery = report.gallery.gallery;
end

count = 0;

% Information about the pca parameters
count = count + fprintf@spt.abstract_spt(fid, obj, varargin{:});

if ~makeFig, return; end

visible = globals.get.VisibleFigures;

if visible,
    visibleStr = 'on';
else
    visibleStr = 'off';
end

figure('Visible', visibleStr);

% We plot only the relevant eigenvalues and a bit more
eigenValues = obj.Eigenvalues(:);
eigenValues(nb_component(obj)+5:end) = [];
if ~strcmpi(obj.Criterion, 'none'),
    critVals = obj.(upper(obj.Criterion));
    critVals(nb_component(obj)+2:end) = [];
else
    critVals = [];
end

eigenValues = eigenValues-min(eigenValues);
eigenValues = eigenValues/max(eigenValues);

plot(eigenValues, 'k', 'LineWidth', 1.5*globals.get.LineWidth);
hold on;
xlabel('Principal component index');
if ~isempty(critVals)
    critVals = critVals - min(critVals);
    critVals = critVals/max(critVals);
    critVals = flipud(critVals(:));
    critVals(nb_component(obj) + 2:end) = [];
    plot(critVals, 'g', 'LineWidth', 1.5*globals.get.LineWidth);
    ylabel('Normalized value');
    critName = obj.Criterion;
    legend('Eigenvalues', [upper(critName) ' criterion']);
else
    ylabel('Normalized eigenvalue');
end

grid on;
yLim = get(gca, 'YLim');
axis([1 numel(eigenValues)+0.25 yLim(1) yLim(2)]);
plot(nb_component(obj), eigenValues(nb_component(obj)), 'ro', 'MarkerFaceColor', 'Red');
line([nb_component(obj) nb_component(obj)], [yLim(1) yLim(2)], ...
    'LineStyle', ':', 'Color', 'Red');


if obj.CovRank < numel(eigenValues),
    str = sprintf('rank = %d', obj.CovRank);
    hT = text(obj.CovRank-0.15, yLim(1)+0.1*diff(yLim), str);
    set(hT, ...
        'FontWeight',       'bold',  ...
        'Rotation',         90, ...
        'BackgroundColor', 'white' ...
        );
end

str = sprintf('#comp = %d ', obj.DimOut);
hT = text(obj.DimOut-0.15, yLim(1)+0.5*diff(yLim), str);
set(hT, ...
    'FontWeight',   'bold',  ...
    'Rotation',     90, ...
    'BackgroundColor', 'white' ...
    );

% Print to .svg and .png format
rootPath = fileparts(fid2fname(fid));

fileName = unique_filename(catfile(rootPath, 'pca.svg'));

caption = sprintf(['Eigenvalues of the PCA decomposition. The red line' ...
    ' marks the boundary between selected and unselected principal ' ...
    'components ']);

evalc('plot2svg(fileName, gcf);');

svg2png(fileName);

close;

gallery = add_figure(gallery, fileName, caption);

%% Print a gallery
count = count + fprintf(fid, gallery);



end