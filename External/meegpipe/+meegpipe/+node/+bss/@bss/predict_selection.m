function y = predict_selection(obj, featVal)


model = get_training_model(obj);

if isempty(model), 
    y = [];
    return;
end

y = predict(model, featVal);

end