`aggregate`
===

Aggregate features from file-level processing jobs


## Usage synopsis

````matlab
[fName, aggrFiles] = aggregate(fileList, regex, fName);
[fName, aggrFiles] = aggregate(fileList, regex, fName, fNameTrans);
````

Where

`fileList` is a cell array with the full path names of the files that
were processed with the relevant pipeline.

`regex` is a regular expression matching the feature file(s).

`fName` is the name of the text file that will contain the aggregated
results. This is an optional argument.

`fNameTrans` is a regular expression that translate file names into a
series of tokens. 


## Example

````matlab
fileList = somsds.link2rec('bcgg', 'condition', 'in-rs-eo-ec',
      'file_ext', '.mff');
run(myPipe, fileList);
% Extract recording, subject, modality and condition IDs from file name
fNameTrans = '(?<recid>.+?)_(?<subjid>.+?)_(?<modid>.+?)_(?<condid>[^\._]+)';
fName = aggregate(fileList, 'features.txt$', '', fNameTrans);
````

