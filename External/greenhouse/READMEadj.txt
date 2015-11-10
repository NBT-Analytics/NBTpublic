ADJPF Adjustement of the F statistic by Epsilon on Repeated Measures ANOVA.
-------------------------------------------------------------------------------------
Created by A. Trujillo-Ortiz, R. Hernandez-Walls, A. Castro-Perez
           and K. Barba-Rojo. 
           Facultad de Ciencias Marinas
           Universidad Autonoma de Baja California
           Apdo. Postal 453
           Ensenada, Baja California
           Mexico.
           atrujo@uabc.mx

November 02, 2006.

To cite this file, this would be an appropriate format:

Trujillo-Ortiz, A., R. Hernandez-Walls, A. Castro-Perez and K. Barba-Rojo. (2006).
adjPF:Adjustment of the F statistic by Epsilon on Repeated Measures. A MATLAB file.
[WWW document]. URL http://www.mathworks.com/matlabcentral/fileexchange/
loadFile.do?objectId=12871
-------------------------------------------------------------------------------------
Congratulations on deciding to use this MATLAB macro file.  
This program has been developed to help you quickly estimate the
Huynh-Feldt epsilon.
-------------------------------------------------------------------------------------
This zip file is free; you can redistribute it and/or modify at your option.
-------------------------------------------------------------------------------------
This zip file contains....
	List of files you should need

adjPF.m          Adjustement of the F statistic by Epsilon on Repeated Measures ANOVA.  
epsHF.m          Huynh-Feldt epsilon.
epsGG.m          Greenhouse-Geisser epsilon.
epsB.m           Box's conservative epsilon.
READMEep.TXT		
-------------------------------------------------------------------------------------
Usage

1. It is necessary you have defined on Matlab the X - data matrix. Size of matrix (X)
must be n-by-k; n=observations, k-treatments=columns. And the F-Observed (calculated)
F statistic value.

2. For running this file it is necessary to call the adjPF function as adjPF(X,F)
Please see the help adjPF.

3. Immediately it will ask you by directed arguments which is your correction epsilon
of interest.

4. Once you input your choices, it will appears your results.
-------------------------------------------------------------------------------------
We claim no responsibility for the results that are obtained 
from your data using this file.
-------------------------------------------------------------------------------------
Copyright.2006