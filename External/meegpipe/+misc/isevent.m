function y = isevent(obj)
% isevent - Returns true for event objects

y = isa(obj, 'physioset.event.event');