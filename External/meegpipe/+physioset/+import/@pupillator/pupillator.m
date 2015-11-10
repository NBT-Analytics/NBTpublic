classdef pupillator < physioset.import.abstract_physioset_import
    % PUPILLATOR - Imports Wisse&Joris pupillator files
    
    % physioset.import.import interface
    methods
        physiosetObj = import(obj, filename, varargin);
    end
    
    methods (Static, Access=private)
       evArray = generate_block_events(prot, protHrd, time, status); 
    end
    
    methods (Static)     
        evArray = block_events(transitionSampl, transitionTime, seq, ...
            isPVTBlock)
    end
    
    
    % Constructor
    methods
        
        function obj = pupillator(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
        end
        
    end
    
    
end