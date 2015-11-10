function res = case_tolerant()
% CASE_TOLERANT - Indicates whether file names are case tolerant
%
%
% res = filespec.case_tolerant;
%
% Where
%
% RES is true (resp. false) if alphabetic case is no (resp. is) 
% significant when comparing file specifications.
%
%
% See also: filespec

% (c) German Gomez-Herrero, german.gomezherrero@kasku.org

% Documentation: pkg_filespec.txt
% Description: Indicates whether file names are case tolerant


res = eval(perl('+mperl/+file/+spec/case_tolerant.pl'));


end