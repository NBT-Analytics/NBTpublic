classdef fileio < physioset.import.abstract_physioset_import
    % FILEIO - Imports data from a disk file using Fieldtrip's fileio module
    %
    % In theory, this physioset importer should be able to import data from
    % any file format supported by Fieldtrip's fileio module. However, if a
    % specialized data importer is available (e.g. the mff importer for
    % .mff files), it is typically preferable to use such a specialized
    % importer over the fileio importer.
    %
    %
    % ## CONSTRUCTION
    %
    %
    %   myImporter = physioset.import.fileio('key', value, ...);
    %
    %
    % ## KEY/VALUE PAIRS ACCEPTED BY CONSTRUCTOR
    %
    %
    % * All key/values accepted by abstract_physioset_import constructor
    %   are also accepted by the fileio constructor.
    %
    %       TriggerRegex : A regular expression. Default: '^STI\d+'
    %           A regular expression that matches the labels of the
    %           relevant trigger channels. Only trigger channels that match
    %           this regex will be consider when generating the physioset
    %           events.
    %
    %
    % See also: physioset.import.abstract_physioset_import
    
    methods (Static, Access = 'private')
        grad = grad_reorder(grad, idx);
        grad = grad_change_unit(grad, newUnit);
        isGrad = is_gradiometer(unit);
    end
    
    methods (Static)
        class = default_label2class(labelArray, className, classRegex);
    end
    
    properties
        TriggerRegex    = '^STI\d+';
        Label2Class     = @(labelArray) ...
            physioset.import.fileio.default_label2class(labelArray);
    end
    
    methods
        % Needed by import() method of parent class
        [ev, meta] = read_events(obj, fileName, pObj, verb, verbLabl);
        [sens, sr, hdr, ev, startDate, startTime, meta] = ...
            read_file(obj, fileName, psetFileName, verb, verbLabl);
        
        % Constructor
        function obj = fileio(varargin)
            obj = obj@physioset.import.abstract_physioset_import(varargin{:});
        end
    end
    
end