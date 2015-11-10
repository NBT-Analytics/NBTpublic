classdef patid
    % @PATID 
    % Patient ID class
    %
    % obj = patid;
    % obj = patid('propName', propValue, ...)
    % 
    % Where
    %
    % OBJ is a patid object
    %
    %
    % Accepted arguments:
    %
    % --code <code>
    %       A string with the patient identification code that is used in
    %       the hospital administration. Any space in this code must be
    %       replaced by underscores (or any other character). Any space in
    %       code will be automatically replaced by underscores.
    %
    % --sex <sex>
    %       Either 'F' or 'M'
    %
    % --birthdate <date>
    %       In dd-MM-yyyy format using the English 3-character
    %       abbreviations of the month in capitals, e.g. 02-AUG-1951.
    %
    % --name <name>
    %       Any space in name will be automatically replaced by
    %       underscores.
    %
    %
    % Note:
    % The 'patient ID' field of the EDF+ file will be constructed as
    % '<code> <sex> <birthdate> <name>'. The maximum length of this patient
    % ID is 80 characters. 
    % 
    %
    % More information:
    %
    % [2] http://www.edfplus.info/specs/edfplus.html#additionalspecs
    %
    %
    % See also: edfplus.header, edfplus.recid, EDFPLUS
    
    properties (SetAccess=private)
        Code;
        Sex;
        BirthDate;
        Name;        
    end
    
    % Constructor
    methods
        function obj = patid(varargin)
           import misc.process_arguments;
           
           keySet = {...
               'code', ...
               'sex', ...
               'birthdate', ...
               'name'...
               };
           
           code = 'X';
           sex = 'X';
           birthdate = 'X';
           name = 'X';
           
           eval(process_arguments(keySet, varargin));
           
           obj.Code = code;
           obj.Sex = sex;
           obj.BirthDate = birthdate;
           obj.Name = name;              
        end        
    end
    
    % Set access methods
    methods
        function obj = set.Code(obj, value)
            if ~isempty(value) && ~ischar(value),
                ME = MException('patid:error', ...
                    'The patient ID code must be a string');
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
            obj.Code = value;
        end
        
        function obj = set.Sex(obj, value)
            if (~isempty(value) && ~ischar(value)) || ...
                    ~ismember(upper(value), {'M', 'F', 'X'}),
                ME = MException('patid:error', [...
                    'The patient sex must be either ''M'', ''F'' or' ...
                    '''X'' (unknown)']);
                throw(ME);
            elseif isempty(value),
                value = 'X';
            end
            obj.Sex = upper(value);
            
        end
        
        function obj = set.BirthDate(obj, value)
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
            obj.BirthDate = value;           
        end
        
        function obj = set.Name(obj, value)
            if (~isempty(value) && ~ischar(value)),
                ME = MException('patid:error', ...
                    'The patient birth date must be in the format ''dd.MM.yyy');
                throw(ME);
            elseif isempty(value),
                value = 'X';
            end
            if ~isempty(strfind(value, ' ')),
                newValue = strrep(value, ' ', '_');
                warning('patid:warning', ...
                    [...
                    'Spaces in the name string have been replaced by ' ...
                    'underscores\n'...
                    '(' value ' -> ' newValue ')'...
                    ]);
                value = newValue;
            end
            obj.Name = value;       
            
        end
            
    end
    
    % Public interface
    methods
        function strOut = as_string(obj)
            import edfplus.globals;
            nc = globals.evaluate.NbCharsPatId;
            str = [obj.Code ' ' obj.Sex ' ' obj.BirthDate ' ' obj.Name];            
            if numel(str) > nc,
                str = str(1:nc);
            end
            strOut = repmat(char(0), 1, nc);
            strOut(1:numel(str)) = str;
        end
        
    end    
   
    
   
   
    
    
end