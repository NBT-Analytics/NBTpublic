
% pop_selectcomps_ADJ() - Display components with button to vizualize their
%                  properties and feature values and label them for
%                  rejection. ADJUST detected ICs are highlighter in red
%                  color. Based on pop_selectcomps.
%
% Usage:
%   >> [EEG, com] = pop_selectcomps_ADJ( EEG, compnum, art, horiz, vert, blink, disc,...
%       soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
%       soglia_TDR, topog_DR, soglia_V, maxvar, soglia_D, maxdin, fig );
%
% Inputs:
%   EEG        - current dataset structure or structure array 
%   compnum    - vector of component numbers 
%   art        - vector of artifact components numbers
%   horiz      - vector of HEM components numbers
%   vert       - vector of VEM components numbers
%   blink      - vector of EB components numbers
%   disc       - vector of GD components numbers
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
% Outputs:
%   EEG        - Output dataset with updated rejected components 
%
%
%
% ORIGINAL FUNCTION HELP:
% pop_selectcomps() - Display components with button to vizualize their
%                  properties and label them for rejection.
% Usage:
%       >> OUTEEG = pop_selectcomps( INEEG, compnum, art );
%
% Inputs:
%   INEEG    - Input dataset
%   compnum  - vector of component numbers
%
% Output:
%   OUTEEG - Output dataset with updated rejected components
%
%
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


function [EEG,com] = pop_selectcomps_ADJ( EEG, compnum, art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin, fig )

COLREJ = '[1 0.6 0.6]';
COLACC = '[0.75 1 0.75]';
COLART = '[1 0 0]';
PLOTPERFIG = 35;

com = '';
if nargin < 1
	help pop_selectcomps_ADJ;
	return;
end;	

if nargin < 2
    promptstr = { 'Components to plot:' };
    initstr   = { [ '1:' int2str(size(EEG.icaweights,1)) ] };
    
    result = inputdlg2(promptstr, 'Reject comp. by map -- pop_selectcomps',1, initstr);
    if isempty(result), return; end;
    compnum = eval( [ '[' result{1} ']' ]);

    if length(compnum) > PLOTPERFIG
        ButtonName=questdlg2(strvcat(['More than ' int2str(PLOTPERFIG) ' components so'],'this function will pop-up several windows'), ...
                             'Confirmation', 'Cancel', 'OK','OK');
        if ~isempty( strmatch(lower(ButtonName), 'cancel')), return; end;
    end;

end;
fprintf('Drawing figure...\n');
currentfigtag = ['selcomp' num2str(rand)]; % generate a random figure tag

if length(compnum) > PLOTPERFIG
    for index = 1:PLOTPERFIG:length(compnum)
        EEG = pop_selectcomps_ADJ(EEG, compnum([index:min(length(compnum),index+PLOTPERFIG-1)]), art, horiz, vert, blink, disc,...
        soglia_DV, diff_var, soglia_K, meanK, soglia_SED, SED, soglia_SAD, SAD, ...
        soglia_GDSF, GDSF, soglia_V, maxvar, soglia_D, maxdin);
    end;

    com = [ 'pop_selectcomps(' inputname(1) ', ' vararg2str(compnum) ');' ];
    return;
end;

if isempty(EEG.reject.gcompreject)
	EEG.reject.gcompreject = zeros( size(EEG.icawinv,2));
end;
try, icadefs; 
catch, 
	BACKCOLOR = [0.8 0.8 0.8];
	GUIBUTTONCOLOR   = [0.8 0.8 0.8]; 
end;

% set up the figure
% -----------------
column =ceil(sqrt( length(compnum) ))+1;
rows = ceil(length(compnum)/column);
if ~exist('fig')
	figure('name', [ 'Reject components by map - pop_selectcomps_ADJ() (dataset: ' EEG.setname ')'], 'tag', currentfigtag, ...
		   'numbertitle', 'off', 'color', BACKCOLOR);
	set(gcf,'MenuBar', 'none');
	pos = get(gcf,'Position');
	set(gcf,'Position', [pos(1) 20 800/7*column 600/5*rows]);
    incx = 120;
    incy = 110;
    sizewx = 100/column;
    if rows > 2
        sizewy = 90/rows;
	else 
        sizewy = 80/rows;
    end;
    pos = get(gca,'position'); % plot relative to current axes
	hh = gca;
	q = [pos(1) pos(2) 0 0];
	s = [pos(3) pos(4) pos(3) pos(4)]./100;
	axis off;
end;

% figure rows and columns
% -----------------------  
if EEG.nbchan > 64
    disp('More than 64 electrodes: electrode locations not shown');
    plotelec = 0;
else
    plotelec = 1;
end;
count = 1;
for ri = compnum
	if exist('fig')
		button = findobj('parent', fig, 'tag', ['comp' num2str(ri)]);
		if isempty(button) 
			error( 'pop_selectcomps_ADJ(): figure does not contain the component button');
		end;	
	else
		button = [];
	end;		
		 
	if isempty( button )
		% compute coordinates
		% -------------------
		X = mod(count-1, column)/column * incx-10;  
        Y = (rows-floor((count-1)/column))/rows * incy - sizewy*1.3;  

		% plot the head
		% -------------
		if ~strcmp(get(gcf, 'tag'), currentfigtag);
			disp('Aborting plot');
			return;
		end;
		ha = axes('Units','Normalized', 'Position',[X Y sizewx sizewy].*s+q);
        if plotelec
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                      'off', 'style' , 'fill', 'chaninfo', EEG.chaninfo);
        else
            topoplot( EEG.icawinv(:,ri), EEG.chanlocs, 'verbose', ...
                      'off', 'style' , 'fill','electrodes','off', 'chaninfo', EEG.chaninfo);
        end;
		axis square;

		% plot the button
		% ---------------
		button = uicontrol(gcf, 'Style', 'pushbutton', 'Units','Normalized', 'Position',...
                           [X Y+sizewy sizewx sizewy*0.25].*s+q, 'tag', ['comp' num2str(ri)]);
		command = sprintf('pop_prop_ADJ( %s, 0, %d, %3.15f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f);', ...
            inputname(1), ri, button, ...
            ~isempty(intersect(horiz,ri)), ~isempty(intersect(vert,ri)), ~isempty(intersect(blink,ri)), ~isempty(intersect(disc,ri)),...
            soglia_DV, diff_var(ri), soglia_K, meanK(ri), soglia_SED, SED(ri),...
            soglia_SAD, SAD(ri), soglia_GDSF, GDSF, soglia_V, maxvar(ri), soglia_D, maxdin);
		set( button, 'callback', command );
	end;
    
    % MODIFY BUTTON COLOR: ARTIFACT IC?
    if isempty( intersect(art,ri)) % NON ARTIFACT
        set( button, 'backgroundcolor', eval(fastif(EEG.reject.gcompreject(ri), COLREJ,COLACC)), 'string', int2str(ri)); 
    else set( button, 'backgroundcolor', eval(fastif(EEG.reject.gcompreject(ri), COLREJ,COLART)), 'string', int2str(ri)); 
    end

	drawnow;
	count = count +1;
end;

% draw the bottom button
% ----------------------
if ~exist('fig')
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Cancel', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[-10 -10  15 sizewy*0.25].*s+q, 'callback', 'close(gcf); fprintf(''Operation cancelled\n'')' );
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Set threhsolds', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[10 -10  15 sizewy*0.25].*s+q, 'callback', 'pop_icathresh(EEG); pop_selectcomps( EEG, gcbf);' );
	if isempty( EEG.stats.compenta	), set(hh, 'enable', 'off'); end;	
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See comp. stats', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[30 -10  15 sizewy*0.25].*s+q, 'callback',  ' ' );
	if isempty( EEG.stats.compenta	), set(hh, 'enable', 'off'); end;	
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'See projection', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[50 -10  15 sizewy*0.25].*s+q, 'callback', ' ', 'enable', 'off'  );
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'Help', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[70 -10  15 sizewy*0.25].*s+q, 'callback', 'pophelp(''pop_selectcomps'');' );
	command = '[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET); eegh(''[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);''); close(gcf)';
%     str1='R';
%     str2='rej';
%     command='rej=EEG.reject;[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);rej=EEG.reject;save(str1,str2);close(gcf)';
	hh = uicontrol(gcf, 'Style', 'pushbutton', 'string', 'OK', 'Units','Normalized', 'backgroundcolor', GUIBUTTONCOLOR, ...
			'Position',[90 -10  15 sizewy*0.25].*s+q, 'callback',  command);
			% sprintf(['eeg_global; if %d pop_rejepoch(%d, %d, find(EEG.reject.sigreject > 0), EEG.reject.elecreject, 0, 1);' ...
		    %		' end; pop_compproj(%d,%d,1); close(gcf); eeg_retrieve(%d); eeg_updatemenu; '], rejtrials, set_in, set_out, fastif(rejtrials, set_out, set_in), set_out, set_in));
end;

com = [ 'pop_selectcomps(' inputname(1) ', ' vararg2str(compnum) ');' ];
return;		
