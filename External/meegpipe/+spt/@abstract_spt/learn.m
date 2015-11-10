function obj = learn(obj, data, varargin)
% LEARN - Learn spatial tranformation basis functions

import goo.globals;
import misc.dimtype_str;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerbose = globals.get.Verbose;
globals.set('Verbose', false);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

if verbose,
    fprintf([verboseLabel ...
        'Learning from %s data\n\n'], dimtype_str(data));
    fprintf(...
        [verboseLabel 'Learning %d spatial basis functions with %s...\n\n'], ...
        size(data,1), class(obj));
end

if ~isempty(obj.LearningFilter),
   if isa(data, 'pset.mmappset'),
       data = copy(data);      
   end
   if isa(obj.LearningFilter, 'function_handle'),
       myFilter = obj.LearningFilter(data.SamplingRate);
   else
       myFilter = obj.LearningFilter;
   end
   data = filter(myFilter, data);    
end

obj = learn_basis(obj, data, varargin{:});

if verbose,
     fprintf([verboseLabel 'Learned %d %s basis\n\n'], nb_component(obj), class(obj));
end

globals.set('VerboseLabel', origVerboseLabel);
globals.set('Verbose', origVerbose);

end



