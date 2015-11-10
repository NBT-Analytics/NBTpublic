classdef nbt_dfa < meegpipe.node.abstract_node
    % NBT_DFA - Detrended Fluctuation Analysis (DFA) biomarker
    %
    % Node nbt_dfa extracts DFA biomarkers using the Neurophysiological
    % Biomarker Toolbox (NBT, [1]). For this node to be functional, the NBT
    % toolbox needs to be installed on your system.
    %
    % ## CONSTRUCTION
    %
    %   myNode = meegpipe.node.nbt_dfa.new('key', value, ...)
    %
    % Where
    %
    % MYNODE is an nbt_dfa node
    %
    %
    % ## KEY/VALUE PAIRS ACCEPTED BY THE CONSTRUCTOR
    %
    %   FreqRange : A 1x2 numeric vector. Default: [8 13]
    %       The edges of the relevant spectral band, in Hz.
    %
    %   FilterOrder : A numeric scalar. Default: 1/FreqRange(1)
    %       The FIR filter order, in seconds.
    %
    %   WindowOverlap : A percentage. Default: 50
    %       The overlap between analysis windows, as a percentage.
    %
    %   NbLogBins : A natural scalar. Default: 10
    %       The number of bins for logarithmic window scale.
    %
    %   FitInterval : A 1x2 numeric vector.
    %       Default: [5 0.1*(size(data,2)/data.SamplingRate)]
    %       Smallest and largest time scale (window size) to include in
    %       power-law fit, in seconds.
    %
    %   CalcInterval : A 1x2 numeric vector.
    %       Default: [0.1 0.1*(size(data,2)/data.SamplingRate)]
    %       Minimum and maximum time-window size computed, in seconds.
    %
    %
    % ## EXAMPLES
    %
    % ### Example 1:
    %
    % Compute DFA biomarker values for the alpha band:
    %
    %   % A simulated dataset with 10 channels of random noise
    %   myData = import(physioset.import.matrix, randn(10, 10000));
    %   myNode = meegpipe.node.nbt_dfa.new('FreqRange', [8 12]);
    %   run(myNode, myData);
    %   % Inspect the extracted features/biomarkers
    %   edit(catfile(get_full_dir(myNode, myData), 'nbt_dfa', 'biomarkers.txt');
    %
    %
    % ## REFERENCES
    %
    % [1] NBT toolbox: http://www.nbtwiki.net/
    %
    %
    % See also: nbt_DFA.nbt_doDFA
    
    
    
    methods
        % abstract_node interface
        [data, dataNew] = process(obj, data);
        
        % constructor
        function obj = nbt_dfa(varargin)
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'nbt_dfa');
            end
        end
        
    end
    
end