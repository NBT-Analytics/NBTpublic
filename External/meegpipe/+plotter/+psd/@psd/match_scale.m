function obj = match_scale(obj, band)
% MATCH_SCALE - Matches the scales of the plotted PSDs
%
% match_scale(h)
% match_scale(h, band)
%
% Where
%
% H is a plotter.psd handle
%
% BAND is a Kx2 matrix with K band specifications. If this argument is
% provided, the scales of the PSDs will be matched only within the
% specified bands.
%
% ## Examples:
%
% % Create a sample PSD plot
% Fs = 1000;   t = 0:1/Fs:.296;
% x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
% h     = spectrum.welch;
% hpsd  = psd(h, x, 'Fs', Fs, 'ConfLevel', 0.95);
% hp    = plot(plotter.psd, hpsd);
% hpsd2 = psd(h, 0.4*x+randn(size(x)), 'Fs', Fs, 'ConfLevel', 0.9);
% plot(hp, hpsd2, 'r'); % Plot second PSD in red
%
% % Make the plot transparent
% hp.Transparent = true;
%
% % Match the PSDs scales, accross all frequencies
% match_scale(hp);
%
% % Match the PSDs scales around 200 Hz
% match_scale(hp, [195 205])
%
% % Go back to the original scaling
% orig_scale(hp);
%
%
% See also: orig_scale, plotter.psd

% Description: Match scales of PSDs
% Documentation: class_plotter_psd.txt

if nargin < 2 || isempty(band), 
    band = get_config(obj, 'MatchScale');
    
end

if isempty(band),
    return;
end

set_config(obj, 'MatchScale', band);


end