function make_pca_report(obj, myPCA)

rep = get_report(obj);
print_title(rep, 'Data processing report', get_level(rep) + 1);
print_title(rep, 'Principal Component Analysis', get_level(rep) + 2);

myPCA = set_method_config(myPCA, 'fprintf', 'ParseDisp', true, 'SaveBinary', true);
fprintf(rep, myPCA, [], do_reporting(obj));

print_paragraph(rep, 'Selected __%d principal components__.', ...
    nb_component(myPCA));

end