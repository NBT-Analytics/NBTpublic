% pop_prop_ADJ() - overloaded pop_prop() for ADJUST plugin.
%              plot the properties of a channel or of an independent component. 
%              ADJUST feature values are also shown (normalized wrt threshold).
%              
%
% Usage:
%   >> com = pop_prop_ADJ(EEG, typecomp, numcompo, winhandle, is_H, is_V, is_B, is_D,...
%           soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED,...
%           soglia_SAD, SAD, soglia_TDR, topog_DR, soglia_V, maxvar, soglia_D, maxdin);
%
% Inputs:
%   EEG        - current dataset structure or structure array 
%   typecomp   - [0|1] compute electrode property (1) or component 
%                property (0). Default is 1.
%   numcompo   - channel or component number
%   winhandle  - if this parameter is present or non-NaN, buttons for the
%                rejection of the component are drawn. If 
%                non-zero, this parameter is used to backpropagate
%                the color of the rejection button.
%   is_H       - (bool) true if plotted IC is HEM
%   is_V       - (bool) true if plotted IC is VEM
%   is_B       - (bool) true if plotted IC is EB
%   is_D       - (bool) true if plotted IC is GD
%   soglia_DV  - feature1 (SVD) threshold
%   diff_var   - feature1 (SVD) vector
%   soglia_K   - feature2 (TK) threshold
%   meanK      - feature2 (TK) vector 
%   soglia_SED - feature3 (SED) threshold
%   SED        - feature3 (SED) vector
%   soglia_SAD - feature4 (SAD) threshold
%   SAD        - feature4 (SAD) vector 
%   soglia_TDR - feature5 (SDR) threshold
%   topog_DR   - feature5 (SDR) vector
%   soglia_V   - feature6 (MEV) threshold
%   maxvar     - feature6 (MEV) vector 
%   soglia_D   - feature7 (MEDR) threshold
%   maxdin     - feature7 (MEDR) vector 
%

% ORIGINAL HELP:
% pop_prop() - plot the properties of a channel or of an independent
%              component. 
% Usage:
%   >> pop_prop( EEG, typecomp); % pops up a query window 
%   >> pop_prop( EEG, typecomp, chan, winhandle);
%
% Inputs:
%   EEG        - dataset structure (see EEGGLOBAL)
%   typecomp   - [0|1] compute electrode property (1) or component 
%                property (0). Default is 1.
%   chan       - channel or component number
%   winhandle  - if this parameter is present or non-NaN, buttons for the
%                rejection of the component are drawn. If 
%                non-zero, this parameter is used to backpropagate
%                the color of the rejection button.
%   spectral_options - [cell array] cell arry of options for the spectopo()
%                      function.
% 

% Copyright (C) 2009 Andrea Mognon and Marco Buiatti, 
% Center for Mind/Brain Sciences, University of Trento, Italy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


function com = pop_prop_ADJ(EEG, typecomp, numcompo, winhandle, is_H, is_V, is_B, is_D,...
    soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED,...
            soglia_SAD, SAD, soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin) %,spec_opt)


com = '';
if nargin < 1
	help pop_prop_ADJ;
	return;   
end;

if nargin == 1
	typecomp = 1;
end;
if typecomp == 0 & isempty(EEG.icaweights)
   error('No ICA weights recorded for this set, first run ICA');
end;   
if nargin == 2
	promptstr    = { fastif(typecomp,'Channel number to plot:','Component number to plot:') ...
                     'Spectral options (see spectopo help):' };
	inistr       = { '1' '''freqrange'', [2 50]' };
	result       = inputdlg2( promptstr, 'Component properties - pop_prop_ADJ()', 1,  inistr, 'pop_prop_ADJ');
	if size( result, 1 ) == 0 return; end;
   
	numcompo   = eval( [ '[' result{1} ']' ] );
    spec_opt   = eval( [ '{' result{2} '}' ] );
end;

% plotting several component properties - STILL TO CHANGE
% -------------------------------------
if length(numcompo) > 1
    for index = numcompo
        pop_prop(EEG, typecomp, index);
    end;
	com = sprintf('pop_prop( %s, %d, [%s]);', inputname(1), typecomp, int2str(numcompo));
    return;
end;

if numcompo < 1 | numcompo > EEG.nbchan
   error('Component index out of range');
end;   

% assumed input is numcompo
% -------------------------
try, icadefs; 
catch, 
	BACKCOLOR = [0.8 0.8 0.8];
	GUIBUTTONCOLOR   = [0.8 0.8 0.8]; 
end;
basename = [fastif(typecomp,'Channel ', 'Component ') int2str(numcompo) ];

fh = figure('name', ['pop_prop_ADJ() - ' basename ' properties'], 'color', BACKCOLOR, 'numbertitle', 'off', 'visible', 'off');
pos = get(gcf,'Position');
set(gcf,'Position', [pos(1) pos(2)-500+pos(4) 500 500], 'visible', 'on');
pos = get(gca,'position'); % plot relative to current axes
hh = gca;
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;
axis off;

% plotting topoplot
% -----------------
h = axes('Units','Normalized', 'Position',[-10 65 40 35].*s+q); 

%topoplot( EEG.icawinv(:,numcompo), EEG.chanlocs); axis square; 

if typecomp == 1 % plot single channel locations
	topoplot( numcompo, EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
             'electrodes','off', 'style', 'blank', 'emarkersize1chan', 12); axis square;
else             % plot component map
	topoplot( EEG.icawinv(:,numcompo), EEG.chanlocs, 'chaninfo', EEG.chaninfo, ...
             'shading', 'interp', 'numcontour', 3); axis square;
end;
basename = [fastif(typecomp,'Channel ', 'IC') int2str(numcompo) ];
% title([ basename fastif(typecomp, ' location', ' map')], 'fontsize', 14); 
title(basename, 'fontsize', 12); 

% plotting erpimage
% -----------------
hhh = axes('Units','Normalized', 'Position',[45 67 48 33].*s+q); %era height 38
eeglab_options; 
if EEG.trials > 1
    % put title at top of erpimage
    axis off
    hh = axes('Units','Normalized', 'Position',[45 67 48 33].*s+q);
    EEG.times = linspace(EEG.xmin, EEG.xmax, EEG.pnts);
    if EEG.trials < 6
      ei_smooth = 1;
    else
      ei_smooth = 3;
    end
    if typecomp == 1 % plot component
         offset = nan_mean(EEG.data(numcompo,:));
         erpimage( EEG.data(numcompo,:)-offset, ones(1,EEG.trials)*10000, EEG.times , ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp');   
    else % plot channel
          if option_computeica  
                  offset = nan_mean(EEG.icaact(numcompo,:));
                  erpimage( EEG.icaact(numcompo,:)-offset, ones(1,EEG.trials)*10000, EEG.times , ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '');   
          else
                
              icaacttmp = (EEG.icaweights(numcompo,:) * EEG.icasphere) ...
                                   * reshape(EEG.data(1:size(EEG.icaweights,1),:,:), EEG.nbchan, EEG.trials*EEG.pnts);
%                     icaacttmp = (EEG.icaweights(numcompo,:) * EEG.icasphere) ...
%                                    * EEG.data(EEG.nbchan, EEG.trials*EEG.pnts);
                  offset = nan_mean(icaacttmp);
                  erpimage( icaacttmp-offset, ones(1,EEG.trials)*10000, EEG.times, ...
                       '', ei_smooth, 1, 'caxis', 2/3, 'cbar','erp', 'yerplabel', '');   
          end;
    end;
    axes(hhh);
    title(sprintf('%s activity \\fontsize{10}(global offset %3.3f)', basename, offset), 'fontsize', 12);
else

    % put title at top of erpimage
    EI_TITLE = 'Continous data';
    axis off
    hh = axes('Units','Normalized', 'Position',[45 62 48 38].*s+q);
    ERPIMAGELINES = 200; % show 200-line erpimage
    while size(EEG.data,2) < ERPIMAGELINES*EEG.srate
       ERPIMAGELINES = round(0.9 * ERPIMAGELINES);
    end
    if ERPIMAGELINES > 2   % give up if data too small
      if ERPIMAGELINES < 10
         ei_smooth == 1;
      else
        ei_smooth = 3;
      end
      erpimageframes = floor(size(EEG.data,2)/ERPIMAGELINES);
      erpimageframestot = erpimageframes*ERPIMAGELINES;
      eegtimes = linspace(0, erpimageframes-1, EEG.srate/1000);
      if typecomp == 1 % plot component
           offset = nan_mean(EEG.data(numcompo,:));
           erpimage( reshape(EEG.data(numcompo,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                         EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar');   
      else % plot channel
            if option_computeica  
                    offset = nan_mean(EEG.icaact(numcompo,:));
                    erpimage( ...
              reshape(EEG.icaact(numcompo,1:erpimageframestot),erpimageframes,ERPIMAGELINES)-offset, ...
                   ones(1,ERPIMAGELINES)*10000, eegtimes , ...
                         EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar','yerplabel', '');   
            else
%                     icaacttmp = reshape(EEG.icaweights(numcompo,:) * EEG.icasphere) ...
%                                      * reshape(EEG.data, erpimageframes, ERPIMAGELINES);
                        
                        icaacttmp = EEG.icaweights(numcompo,:) * EEG.icasphere ...
                                     *EEG.data(:,1:erpimageframes*ERPIMAGELINES);

                    offset = nan_mean(icaacttmp);
                    erpimage( icaacttmp-offset, ones(1,ERPIMAGELINES)*10000, eegtimes, ...
                         EI_TITLE, ei_smooth, 1, 'caxis', 2/3, 'cbar', 'yerplabel', '');   
            end;
      end
    else
            axis off;
            text(0.1, 0.3, [ 'No erpimage plotted' 10 'for small continuous data']);
    end;
    axes(hhh);
end;	

% plotting spectrum
% -----------------
if ~exist('winhandle')
    winhandle = NaN;
end;
if ~isnan(winhandle)
	h = axes('units','normalized', 'position',[10 25 85 25].*s+q);
    %h = axes('units','normalized', 'position',[5 10 95 35].*s+q); %%%
    %CHANGE!
else
	h = axes('units','normalized', 'position',[10 15 85 30].*s+q);
    %h = axes('units','normalized', 'position',[5 0 95 40].*s+q); %%%
    %CHANGE!
end;
%h = axes('units','normalized', 'position',[45 5 60 40].*s+q);
try
	eeglab_options;
    %next instr added for correct function! Andrea
    option_computeica=1;
	if typecomp == 1
		%[spectra freqs] = spectopo( EEG.data(numcompo,:), EEG.pnts, EEG.srate, spec_opt{:},'freqrange', [0 45] );
        [spectra freqs] = spectopo( EEG.data(numcompo,:), EEG.pnts, EEG.srate, 'freqrange', [0 45] );
	else 
		if option_computeica  
            
			%[spectra freqs] = spectopo( EEG.icaact(numcompo,:), EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,numcompo), spec_opt{:}, 'freqrange', [0 45]);
            % CONTROL ADDED FOR CONTINUOUS DATA
            if size(EEG.data,3)==1 
                % exclude bad channels
                chans_index = 1:size(EEG.data,1);
                bad_chans = find(EEG.NBTinfo.BadChannels);
                if ~isempty(bad_chans)
                    for nc = 1:length(bad_chans)
                        chans_index = chans_index(chans_index~=bad_chans(nc));
                    end
                    
                EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data(chans_index,:);
                else
                EEG.icaact = EEG.icaweights*EEG.icasphere*EEG.data;
                end
            end
            [spectra freqs] = spectopo( EEG.icaact(numcompo,:), EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,numcompo),  'freqrange', [0 45]);
		else
			if exist('icaacttmp')~=1, 
                
				icaacttmp = (EEG.icaweights(numcompo,:)*EEG.icasphere)*reshape(EEG.data, EEG.nbchan, EEG.trials*EEG.pnts); 
			end;
            
			%[spectra freqs] = spectopo( icaacttmp, EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,numcompo), spec_opt{:} ,'freqrange', [0 45]);
            [spectra freqs] = spectopo( icaacttmp, EEG.pnts, EEG.srate, 'mapnorm', EEG.icawinv(:,numcompo), 'freqrange', [0 45]);
		end;
	end;
    set(gca,'fontsize',8);
    % set up new limits
    % -----------------
    %freqslim = 50;
	%set(gca, 'xlim', [0 min(freqslim, EEG.srate/2)]);
    %spectra = spectra(find(freqs <= freqslim));
	%set(gca, 'ylim', [min(spectra) max(spectra)]);
    
	%tmpy = get(gca, 'ylim');
    %set(gca, 'ylim', [max(tmpy(1),-1) tmpy(2)]);
	set( get(gca, 'ylabel'), 'string', 'Power 10*log_{10}(\muV^{2}/Hz)', 'fontsize', 8); 
	set( get(gca, 'xlabel'), 'string', 'Frequency (Hz)', 'fontsize', 8); 
	title('Activity power spectrum', 'fontsize', 12); 
catch
	axis off;
	text(0.1, 0.3, [ 'Error: no spectrum plotted' 10 ' make sure you have the ' 10 'signal processing toolbox']);
end;	

% ----------------------------------------------------------------
% plotting IC properties
% -----------------
if ~exist('winhandle')
    winhandle = NaN;
end;
if ~isnan(winhandle)
	h = axes('units','normalized', 'position',[3 2 95 10].*s+q);
else
	h = axes('units','normalized', 'position',[3 0 95 10].*s+q);
end;

axis off
str='ADJUST - Detected as ';
if is_H
    str=[str 'Horizontal eye movements '];
end
    if is_V
        str=[str 'Vertival eye movements '];
    end
        if is_B
            str=[str 'Eye Blink '];
        end
            if is_D
                str=[str 'Generic Discontinuities'];
            end
      
if (is_H || is_V || is_B || is_D)==0
    str='ADJUST - Not detected';
end
% text(0,0,[str 10 'TK ' num2str(meanK) '(' num2str(soglia_K) '); SAD ' num2str(SAD) '(' num2str(soglia_SAD) ...
%     '); SVD ' num2str(diff_var) '(' num2str(soglia_DV) '); SED ' num2str(SED) '(' num2str(soglia_SED) ...
%     ')' 10 'MEDR ' num2str(maxdin) '(' num2str(soglia_D) '); MEV ' num2str(maxvar) '(' num2str(soglia_V) ...
%     '); SDR ' num2str(topog_DR) '(' num2str(soglia_TDR) ')'],'FontSize',8);

% compute bar graph entries
E=[ SAD/soglia_SAD SED/soglia_SED GDSF/soglia_GDSF meanK/soglia_K];
% set bar colors
C={[1 0 0],[.6 0 .2],[1 1 0], [0 1 1]};
% horizontal line
l=ones([1, length(E)+2]);
% plot
plot(0:length(E)+1 , l , 'Linewidth',2,'Color','k');
hold on
for i=1:length(E)
    v=zeros(1,length(E));
    v(i)=E(i);
    bar(v,'facecolor',C{i});
    title(str);
    set(gca,'XTickLabel',{'';'SAD';'SED';'GDSF';'MEV';'TK';''},'YTickLabel',{'0';'Threshold';'2*Threshold'},'YLim',[0 2])
end




% -----------------------------------------------------------------


% display buttons
% ---------------

if ~isnan(winhandle)
	COLREJ = '[1 0.6 0.6]';
	COLACC = '[0.75 1 0.75]';
	% CANCEL button
	% -------------
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Cancel', 'Units','Normalized','Position',[-10 -10 15 6].*s+q, 'callback', 'close(gcf);');

	% VALUE button
	% -------------
	hval  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'Values', 'Units','Normalized', 'Position', [15 -10 15 6].*s+q);

	% REJECT button
	% -------------
	status = EEG.reject.gcompreject(numcompo);
	hr = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', eval(fastif(status,COLREJ,COLACC)), ...
				'string', fastif(status, 'REJECT', 'ACCEPT'), 'Units','Normalized', 'Position', [40 -10 15 6].*s+q, 'userdata', status, 'tag', 'rejstatus');
	command = [ 'set(gcbo, ''userdata'', ~get(gcbo, ''userdata''));' ...
				'if get(gcbo, ''userdata''),' ...
				'     set( gcbo, ''backgroundcolor'',' COLREJ ', ''string'', ''REJECT'');' ...
				'else ' ...
				'     set( gcbo, ''backgroundcolor'',' COLACC ', ''string'', ''ACCEPT'');' ...
				'end;' ];					
	set( hr, 'callback', command); 

	% HELP button
	% -------------
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'backgroundcolor', GUIBUTTONCOLOR, 'string', 'HELP', 'Units','Normalized', 'Position', [65 -10 15 6].*s+q, 'callback', 'pophelp(''pop_prop_ADJ'');');

	% OK button
	% ---------
 	command = [ 'global EEG;' ...
 				'tmpstatus = get( findobj(''parent'', gcbf, ''tag'', ''rejstatus''), ''userdata'');' ...
 				'EEG.reject.gcompreject(' num2str(numcompo) ') = tmpstatus;' ]; 
	if winhandle ~= 0
	 	command = [ command ...
	 				sprintf('if tmpstatus set(%3.15f, ''backgroundcolor'', %s); else set(%3.15f, ''backgroundcolor'', %s); end;', ...
					winhandle, COLREJ, winhandle, COLACC)];
	end;				
	command = [ command 'close(gcf); clear tmpstatus' ];
	h  = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'backgroundcolor', GUIBUTTONCOLOR, 'Units','Normalized', 'Position',[90 -10 15 6].*s+q, 'callback', command);

	% draw the figure for statistical values
	% --------------------------------------
	index = num2str( numcompo );
	command = [ ...
		'figure(''MenuBar'', ''none'', ''name'', ''Statistics of the component'', ''numbertitle'', ''off'');' ...
		'' ...
		'pos = get(gcf,''Position'');' ...
		'set(gcf,''Position'', [pos(1) pos(2) 340 340]);' ...
		'pos = get(gca,''position'');' ...
		'q = [pos(1) pos(2) 0 0];' ...
		's = [pos(3) pos(4) pos(3) pos(4)]./100;' ...
		'axis off;' ...
		''  ...
		'txt1 = sprintf(''(\n' ...
						'Entropy of component activity\t\t%2.2f\n' ...
					    '> Rejection threshold \t\t%2.2f\n\n' ...
					    ' AND                 \t\t\t----\n\n' ...
					    'Kurtosis of component activity\t\t%2.2f\n' ...
					    '> Rejection threshold \t\t%2.2f\n\n' ...
					    ') OR                  \t\t\t----\n\n' ...
					    'Kurtosis distibution \t\t\t%2.2f\n' ...
					    '> Rejection threhold\t\t\t%2.2f\n\n' ...
					    '\n' ...
					    'Current thesholds sujest to %s the component\n\n' ...
					    '(after manually accepting/rejecting the component, you may recalibrate thresholds for future automatic rejection on other datasets)'',' ...
						'EEG.stats.compenta(' index '), EEG.reject.threshentropy, EEG.stats.compkurta(' index '), ' ...
						'EEG.reject.threshkurtact, EEG.stats.compkurtdist(' index '), EEG.reject.threshkurtdist, fastif(EEG.reject.gcompreject(' index '), ''REJECT'', ''ACCEPT''));' ...
		'' ...				
		'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-11 4 117 100].*s+q, ''Style'', ''frame'' );' ...
		'uicontrol(gcf, ''Units'',''Normalized'', ''Position'',[-5 5 100 95].*s+q, ''String'', txt1, ''Style'',''text'', ''HorizontalAlignment'', ''left'' );' ...
		'h = uicontrol(gcf, ''Style'', ''pushbutton'', ''string'', ''Close'', ''Units'',''Normalized'', ''Position'', [35 -10 25 10].*s+q, ''callback'', ''close(gcf);'');' ...
		'clear txt1 q s h pos;' ];
	set( hval, 'callback', command); 
	if isempty( EEG.stats.compenta )
		set(hval, 'enable', 'off');
	end;
	
    % MODIFICA
	%com = sprintf('pop_prop( %s, %d, %d, 0, %s);', inputname(1), typecomp, numcompo, vararg2str( { spec_opt } ) );
    	com = sprintf('pop_prop_ADJ( %s, %d, %d, 0, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f);',...
            inputname(1), typecomp, numcompo, is_H, is_V, is_B, is_D,...
            soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED,...
            soglia_SAD, SAD, soglia_GDSF, GDSF);

else
	%com = sprintf('pop_prop( %s, %d, %d, NaN, %s);', inputname(1), typecomp, numcompo, vararg2str( { spec_opt } ) );
    	com = sprintf('pop_prop_ADJ( %s, %d, %d, NaN, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f);',...
            inputname(1), typecomp, numcompo, is_H, is_V, is_B, is_D,...
            soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED,...
            soglia_SAD, SAD, soglia_GDSF, GDSF);

end;

return;

function out = nan_mean(in)

    nans = find(isnan(in));
    in(nans) = 0;
    sums = sum(in);
    nonnans = ones(size(in));
    nonnans(nans) = 0;
    nonnans = sum(nonnans);
    nononnans = find(nonnans==0);
    nonnans(nononnans) = 1;
    out = sum(in)./nonnans;
    out(nononnans) = NaN;


