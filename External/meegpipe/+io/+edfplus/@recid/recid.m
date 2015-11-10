classdef recid
    % @RECID
    % Record ID class
    %
    % obj = recid;
    % obj = recid('propName', 'propValue');
    %
    % Where
    %
    % OBJ is a recid object
    %
    %
    % Accepted arguments:
    %
    % --startdate <date>
    %        The start date of the recording in dd-MMM-yyy format.
    %
    % --code <code>
    %        The hospital administration code of the investigation, i.e. EEG
    %        number or PSG number.
    %
    % --investigator <code>
    %        A code specifying the responsible investigator or technician
    %
    % --equipment <code>
    %        A code specifying the used equipment
    %
    %
    %
    % Notes:
    % The 'recording ID' field of the EDF+ file will be constructed as
    % 'Startdate <startdate> <code> <investigator> <equipment>'. The maximum
    % length of this recording ID is 80 characters.
    %
    % Any space inside the hospital, investigator or equipment codes must be
    % replaced by a different character. Blank spaces are otherwise
    % automatically replaced by underscores.
    %
    % More information:
    %
    % [2] http://www.edfplus.info/specs/edfplus.html#additionalspecs
    %
    %
    % See also: edfplus.header, edfplus.patid, EDFPLUS
    
    properties
        StartDate;
        Code;
        Investigator;
        Equipment;
    end
    
    % Constructor
    methods
        function obj = recid(varargin)
            import misc.process_arguments;
            
            keySet = {...
                'startdate', ...
                'code', ...
                'investigator', ...
                'equipment'...
                };
            
            startdate = 'X';
            code = 'X';
            investigator = 'X';
            equipment = 'X';
            
            eval(process_arguments(keySet, varargin));
            
            obj.StartDate = startdate;
            obj.Code = code;
            obj.Investigator = investigator;
            obj.Equipment = equipment;
           
        end
        
    end
    
    
    % Set access methods
    methods
        function obj = set.StartDate(obj, value)
             if (~isempty(value) && ~ischar(value)) || ...
                    (~strcmpi(value, 'X') && isempty(regexp(value, ...
                    '\d\d-[A-Z][A-Z][A-Z]-\d\d\d\d', 'once'))),
                ME = MException('patid:error', ...
                    'The patient birth date must be in the format ''dd.MM.yyy');
                throw(ME);
            elseif isempty(value),
                value = 'X';
            end
            if strcmpi(value, 'X'), value = upper(value); end
            obj.StartDate = value;           
        end
        
        function obj = set.Code(obj, value)
            import edfplus.recid;
            obj.Code = recid.code_generate(value);
            
        end
        
        function obj = set.Investigator(obj, value)
            import edfplus.recid;
            obj.Investigator = recid.code_generate(value);
            
        end
        
        function obj = set.Equipment(obj, value)
            
            import edfplus.recid;
            obj.Equipment = recid.code_generate(value);
            
        end
    end
    
    % Public interface
    methods
        function strOut = as_string(obj)
           import edfplus.globals;
           nc = globals.evaluate.NbCharsRecId;
           str = ['StartDate ' obj.StartDate ' ' obj.Code ' ' ...
               obj.Investigator ' ' obj.Equipment]; 
           
           if numel(str) > nc,
               str = str(1:nc);
           end
           strOut = repmat(char(0), 1, nc);
           strOut(1:numel(str))=str;
        end
        
    end
    
    % Static methods
    methods (Static)
        function value = code_generate(value)
            if ~isempty(value) && ~ischar(value),
                ME = MException('patid:error', ...
                    'Code must be a string');
                throw(ME);
            elseif isempty(value),
                value = 'X';
            end
            if ~isempty(strfind(value, ' ')),
                newValue = strrep(value, ' ', '_');
                warning('patid:warning', ...
                    [...
                    'Spaces in the code string have been replaced by ' ...
                    'underscores\n'...
                    '(' value ' -> ' newValue ')'...
                    ]);
                value = newValue;
            end
            
        end
    end    
    
    
    
end