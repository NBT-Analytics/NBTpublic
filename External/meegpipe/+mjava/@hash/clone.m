function newObj = clone(obj)

newObj = mjava.hash;

newObj.Hashtable  = obj.Hashtable.clone();
newObj.Class      = obj.Class.clone();
newObj.FieldNames = obj.FieldNames.clone();
newObj.Dimensions = obj.Dimensions.clone();



end