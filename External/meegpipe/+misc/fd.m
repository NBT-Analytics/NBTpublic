function [D] = fd(wave, opt)
% FD - Fractal dimension of a waveform
%
% Usage:
%   >> D = fd(X,OPT)
%
% Inputs:
%   X   - (double vector) waveform
%   OPT - (struct) options structure. The following fields are required:
%         .method : 'katz','sevcik','katz_mean','sevcik_mean'
%         .wl     : window length (required for '_mean' methods)
%         .ws     : window shift (required for '_mean' methods)
%
% Outputs:
%   D   - (double) computed fractal dimension
%
%
% References:
%   [1] Katz, M.J., Fractals and the analysis of waveforms, 
%       Comput.Biol.Med. 18: 145, 1988
%   [2] Sevcik, C., A procedure to Estimate the Fractal Dimension of
%       Waveforms, Complexity International, volume 5, 1998, Available online:
%       http://journal-ci.csse.monash.edu.au/ci/vol05/sevcik/
%
%
% Author: German Gomez-Herrero <http://www.cs.tut.fi/~gomezher/index.htm>
%         Institute of Signal Processing
%         Tampere University of Technology, 2009


% Copyright (C) <2009>  <German Gomez-Herrero>
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

import misc.fd;

TOL = 1e-6;

if nargin < 1, help fd; return; end

if ~exist('opt','var'),
    opt = def_fd;
else
    opt = def_fd(opt);
end

if size(wave,2) > size(wave,1),
    wave = wave';
end

if size(wave,2)>1,
    D = zeros(1, size(wave,2));
    for i = 1:size(wave,2)
        D(i) = fd(wave(:,i), opt);
    end
    return;
end

method = opt.method;
wl = opt.wl;
ws = opt.ws;

switch(lower(method)),
    case 'katz'
        n = length(wave);
        x = (1:n)';
        y = wave;
        % Calculate the diameter
        d = sqrt((x-x(1)).^2+(y-y(1)).^2);
        d = max(d);
        % Calculate the length of the wave
        x = ones((n-1),1);
        y = wave(2:n)-wave(1:(n-1));
        L = sum(sqrt(x.^2+y.^2));
        D = log10(n)/(log10(d/L)+log10(n));

    case 'sevcik',
        n = length(wave);
        %x = 1:n;
        y = wave;
        % Map the wave to the unit square throught a double linear
        % transformation   
        span = (max(y)-min(y));
        if span < TOL,
            D = 1;
            return; 
        end
        y = (y-max(y))./span;         

        % calculate the length of the wave
        x = (1/(n-1))*ones((n-1),1);
        y = y(2:n)-y(1:(n-1));
        L = sum(sqrt(x.^2+y.^2));
        D = 1+log(L)/log(2*(n-1));
        
    case 'sevcik_var',
        N = length(wave);        
        %ovlength = wl-ws;
        init = 1:ws:length(wave);
        final = init+wl-1;
        ne = length(init);
        D = zeros(ne,1);
        tmpopt = struct;
        tmpopt.method = 'sevcik';
        for i = 1:ne
           D(i) = fd(wave(init(i):min(final(i),N)),tmpopt); 
        end
        D = var(D);
        
    case 'katz_var',
        N = length(wave);        
        %ovlength = wl-ws;
        init = 1:ws:length(wave);
        final = init+wl-1;
        ne = length(init);
        D = zeros(ne,1);
        tmpopt = struct;
        tmpopt.method = 'katz';
        for i = 1:ne
            D(i) = fd(wave(init(i):min(final(i),N)),tmpopt);
        end
        D = var(D);
        
        
    case {'sevcik_mean', 'sevcik_10'},
        N = length(wave);        
        %ovlength = wl-ws;
        init = 1:ws:length(wave);
        final = init+wl-1;
        ne = length(init);
        D = zeros(ne,1);
        tmpopt = struct;
        tmpopt.method = 'sevcik';
        for i = 1:ne
            D(i) = fd(wave(init(i):min(final(i),N)),tmpopt);
        end
        if strcmpi(method, 'sevcik_10'),
            D = prctile(D, 10);
        else
            D = mean(D);
        end
     case 'sevcik_window',
        N = length(wave);        
        %ovlength = wl-ws;
        init = 1:ws:length(wave);
        final = init+wl-1;
        ne = length(init);
        D = zeros(ne,1);
        thisopt.method = 'sevcik';
        for i = 1:ne
            D(i) = fd(wave(init(i):min(final(i),N)),thisopt);
        end
        
        
    case 'katz_mean',
        N = length(wave);        
        %ovlength = wl-ws;
        init = 1:ws:length(wave);
        final = init+wl-1;
        ne = length(init);
        D = zeros(ne,1);
        for i = 1:ne
            D(i) = fd(wave(init(i):min(final(i),N)),'katz');
        end
        D = mean(D);


    otherwise
        error('(fd) unknown method %s',method);


end

% subfunction to define the default parameters
% --------------------------------------------
function opt = def_fd(opt)
if nargin < 1 || isempty(opt) || ~isfield(opt,'method'),
    opt.method = 'sevcik';
end
if ~isfield(opt,'wl'),
    opt.wl = [];
end
if ~isfield(opt,'ws'),
    opt.ws = [];
end
