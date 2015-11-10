function obj = clone(obj)

obj = feval(class(obj), obj);

end