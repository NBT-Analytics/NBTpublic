function newObj = clone(obj)

newObj = feval(class(obj), obj);


end