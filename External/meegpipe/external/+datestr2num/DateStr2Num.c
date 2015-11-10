// DateStr2Num.c
// DATESTR2NUM - Fast conversion of DATESTR to DATENUM
// The builtin DATENUM command is very powerful, but if you know the input
// format exactly, a specific MEX can be much faster: e.g. for single strings
// DateStr2Num takes 0.96% of the processing time of DATENUM (with specified
// date format), for a {1 x 10000} cell string, DateStr2Num needs 1.8% to 4.2%
// of the DATENUM time. (Matlab 2009a, MSVC 2008 using SSE2 optimization).
//
// D = DateStr2Num(S, F)
// INPUT:
//   S: String or cell string in DATESTR(F) format.
//      In opposite to DATENUM the validity of the input string is not checked
//      (e.g. 1 <= month <= 12).
//   F: Integer number defining the input format. Accepted:
//          0:  'dd-mmm-yyyy HH:MM:SS'   01-Mar-2000 15:45:17
//          1:  'dd-mmm-yyyy'            01-Mar-2000
//         29:  'yyyy-mm-dd'             2000-03-01
//         30:  'yyyymmddTHHMMSS'        20000301T154517
//         31:  'yyyy-mm-dd HH:MM:SS'    2000-03-01 15:45:17
//      Including the milliseconds (not a DATEFORM number e.g. in DATESTR):
//        300:  'yyyymmddTHHMMSS.FFF'    20000301T154517.123
//      Optional, default: 0.
//
// OUTPUT:
//   D: Serial date number. If S is a cell, D has is same size.
//
// EXAMPLES:
//   C = {'2010-06-29 21:59:13', '2010-06-29 21:59:13'};
//   D = DateStr2Num(C, 31)
//   >> [734318.916122685, 734318.916122685]
//   Equivalent Matlab command (but a column vector is replied ever):
//   D = datenum(C, 'yyyy-mm-dd HH:MM:SS')
//
// NOTES: The parsing of the strings works for clean ASCII characters only:
//   '0' must have the key code 48!
//   Month names must be English with the 2nd and 3rd charatcer in lower case.
//
// COMPILATION:
//   Windows: mex -O DateStr2Num.c
//   Linux:   mex -O CFLAGS="\$CFLAGS -std=c99" DateStr2Num.c
//   Precompiled Mex: http://www.n-simon.de/mex
//
// Tested: Matlab 6.5, 7.7, 7.8, WinXP, 32bit
//         Compiler: LCC2.4/3.8, BCC5.5, OWC1.8, MSVC2008
// Assumed Compatibility: higher Matlab versions, Mac, Linux, 64bit
// Author: Jan Simon, Heidelberg, (C) 2010-2011 matlab.THISYEAR(a)nMINUSsimon.de
//
// See also DATESTR, DATENUM, DATEVEC.
// FEX: DateConvert 25594 (Jan Simon)

/*
% $JRev: R-e V:005 Sum:aQdfBVMPknp8 Date:25-Mar-2011 14:32:42 $
% $License: BSD (use/copy/change/redistribute on own risk, mention the author) $
% $File: Published\DateStr2Num\DateStr2Num.c $
% History:
% 001: 29-Jun-2010 22:12, First version, for format 31 only.
% 002: 30-Jun-2010 16:08, Accept formats 0, 1, 29, 30, 31.
% 005: 23-Mar-2011 22:39, yyyymmddTHHMMSS.FFF format, called "300".
%      Using int32_T instead of uint16_T is about 50% faster: The conversion of
%      signed integers to a double is implemented in hardware.
*/

#include "mex.h"
#include <math.h>
#include "tmwtypes.h"

// 32 bit addressing for Matlab 6.5:
// See MEX option "compatibleArrayDims" for MEX in Matlab >= 7.7.
#ifndef MWSIZE_MAX
#define mwSize  int32_T           // Defined in tmwtypes.h
#define mwIndex int32_T
#endif

// Headers for error messages:
#define ERR_ID   "JSimon:DateStr2Num:"
#define ERR_HEAD "DateStr2Num[mex]: "

// Prototypes:
double Str0Num(const mxArray *S);
double Str1Num(const mxArray *S);
double Str29Num(const mxArray *S);
double Str30Num(const mxArray *S);
double Str31Num(const mxArray *S);
double Str300Num(const mxArray *S);

// Type: Pointer to core function:
typedef double (*CoreFcn_T) (const mxArray *S);

// Cummulated number of days before the first of each month:
// Leading 0 for 1 base indexing!
static int32_T cumdays[] = {0, 0,31,59,90,120,151,181,212,243,273,304,334};

// Main function: --------------------------------------------------------------
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray*prhs[])
{
   mwSize    iC, nC, ndim;
   double    *Out;
   int       Format;
   CoreFcn_T CoreFcn;
   const mwSize *dim;
   const mxArray *aC, *C;
           
   // Get 2nd input or use the default, check number of inputs:
   if (nrhs == 1) {
      CoreFcn = Str0Num;
   } else if (nrhs == 2) {
      if (mxGetNumberOfElements(prhs[1]) != 1 || !mxIsNumeric(prhs[1])) {
         mexErrMsgIdAndTxt(ERR_ID   "BadFormatType",
                        ERR_HEAD "2nd input [Format] must be a scalar number.");
      }
      Format = (int) mxGetScalar(prhs[1]);
      switch (Format) {
         case  0:   CoreFcn = Str0Num;    break;
         case  1:   CoreFcn = Str1Num;    break;
         case  29:  CoreFcn = Str29Num;   break;
         case  30:  CoreFcn = Str30Num;   break;
         case  31:  CoreFcn = Str31Num;   break;
         case 300:  CoreFcn = Str300Num;  break;
         default:
           mexErrMsgIdAndTxt(ERR_ID   "BadFormat",
                             ERR_HEAD "Format not supported.");
      }
   } else {
      mexErrMsgIdAndTxt(ERR_ID   "BadNInput",
                        ERR_HEAD "1 or 2 inputs required.");
   }
   
   // Get 1st input:
   C  = prhs[0];
   if (mxIsChar(C)) {         // Input is a string:
      plhs[0] = mxCreateDoubleScalar(CoreFcn(C));

   } else if (mxIsCell(C)) {  // Input is a cell:
      ndim    = mxGetNumberOfDimensions(C);
      dim     = mxGetDimensions(C);
      plhs[0] = mxCreateNumericArray(ndim, dim, mxDOUBLE_CLASS, mxREAL);
      Out     = mxGetPr(plhs[0]);
      nC      = mxGetNumberOfElements(C);
   
      for (iC = 0; iC < nC; iC++) {
         // Get cell element and check, if it is a string:
         if ((aC = mxGetCell(C, iC)) == NULL) {  // Not initialized:
            mexErrMsgIdAndTxt(ERR_ID   "BadInputType",
                              ERR_HEAD "Cell element is not a string.");
         }
         if (!mxIsChar(aC)) {                    // Not a string:
            mexErrMsgIdAndTxt(ERR_ID   "BadInputType",
                              ERR_HEAD "Cell element is not a string.");
         }
         
         *Out++ = CoreFcn(aC);
      }
      
   } else {
      mexErrMsgIdAndTxt(ERR_ID   "BadInputType",
                        ERR_HEAD "Input must be a string or a cell.");
   }

   return;
}

// -----------------------------------------------------------------------------
double Str0Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "dd-mmm-yyyy HH:MM:SS"   "01-Mar-2000 15:45:17"
  
  uint16_T *d16, mIndex;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) != 20) {
     mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                       ERR_HEAD "String not in [dd-mmm-yyyy HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[7] - 48) * 1000 + (d16[8] - 48) * 100 +
          d16[9] * 10 + d16[10] - 528;
  day  =  d16[0] * 10 + d16[1]  - 528;
  
  // Identify the month by the sum of the 2nd and 3rd character. This avoids
  // the time-consuming upper/lower case conversion:
  mIndex = d16[4] * 256 + d16[5];
  if (mIndex <= 25955) {  // Split the test in 2 halfs for speed
     switch (mIndex) {
        case 24942:  mon = 1;   break;  // 'jan'
        case 24946:  mon = 3;   break;  // 'mar'
        case 24953:  mon = 5;   break;  // 'may'
        case 25460:  mon = 10;  break;  // 'oct'
        case 25954:  mon = 2;   break;  // 'feb'
        case 25955:  mon = 12;  break;  // 'dec'
        default:
          mexErrMsgIdAndTxt(ERR_ID "BadDateString",
                       ERR_HEAD "String not in [dd-mmm-yyyy HH:MM:SS] format.");
     }
  } else {
     switch (mIndex) {
        case 25968:  mon = 9;   break;  // 'sep'
        case 28534:  mon = 11;  break;  // 'nov'
        case 28786:  mon = 4;   break;  // 'apr'
        case 30055:  mon = 8;   break;  // 'aug'
        case 30060:  mon = 7;   break;  // 'jul'
        case 30062:  mon = 6;   break;  // 'jun'
        default:
           mexErrMsgIdAndTxt(ERR_ID "BadDateString",
                       ERR_HEAD "String not in [dd-mmm-yyyy HH:MM:SS] format.");
     }
  }
  
  hour = d16[12] * 10 + d16[13] - 528;
  min  = d16[15] * 10 + d16[16] - 528;
  sec  = d16[18] * 10 + d16[19] - 528;
  
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0)) +
         (hour * 3600 + min * 60 + sec) / 86400.0;
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }
  
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str1Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "dd-mmm-yyyy"   "01-Mar-2000"
  
  uint16_T *d16;
  int32_T  year, mon, mIndex, day;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) != 11) {
     mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                       ERR_HEAD "String not in [dd-mmm-yyyy] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[7] - 48) * 1000 + (d16[8] - 48) * 100 +
          d16[9] * 10 + d16[10] - 528;
  day  =  d16[0] * 10 + d16[1]  - 528;
  
  // Identify the month by the sum of the 2nd and 3rd character. This avoids
  // the time-consuming upper/lower case conversion:
  // jan; feb; mar; apr; may; jun; jul; aug; sep; oct; nov; dec
  // 207; 199; 211; 226; 218; 227; 225; 220; 213; 215; 229; 200
  mIndex = d16[4] * 256 + d16[5];
  if (mIndex <= 25955) {  // Split the test in 2 halfs for speed
     switch (mIndex) {
        case 24942:  mon = 1;   break;  // 'jan'
        case 24946:  mon = 3;   break;  // 'mar'
        case 24953:  mon = 5;   break;  // 'may'
        case 25460:  mon = 10;  break;  // 'oct'
        case 25954:  mon = 2;   break;  // 'feb'
        case 25955:  mon = 12;  break;  // 'dec'
        default:
          mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                            ERR_HEAD "String not in [dd-mmm-yyyy] format.");
     }
  } else {
     switch (mIndex) {
        case 25968:  mon = 9;   break;  // 'sep'
        case 28534:  mon = 11;  break;  // 'nov'
        case 28786:  mon = 4;   break;  // 'apr'
        case 30055:  mon = 8;   break;  // 'aug'
        case 30060:  mon = 7;   break;  // 'jul'
        case 30062:  mon = 6;   break;  // 'jun'
        default:
           mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                             ERR_HEAD "String not in [dd-mmm-yyyy] format.");
     }
  }
  
  // Calculate the serial date number:
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0));
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str29Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "yyyy-mm-dd"  "2000-03-01"
  
  uint16_T *d16;
  int32_T  year, mon, day;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) != 10) {
      mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                        ERR_HEAD "String not in [yyyy-mm-dd] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3] - 528;
  mon  = d16[5]  * 10 + d16[6] - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[8]  * 10 + d16[9] - 528;
  
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0));
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }
  return (dNum);
}

// -----------------------------------------------------------------------------
double Str30Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "yyyymmddTHHMMSS"   "20000301T154517"

  int16_T *d16;
  int32_T year, mon, day, hour, min, sec;
  double  dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) != 15) {
      mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                        ERR_HEAD "String not in [yyyymmddTHHMMSS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3]  - 528;
  mon  = d16[4]  * 10 + d16[5]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[6]  * 10 + d16[7]  - 528;
  hour = d16[9]  * 10 + d16[10] - 528;
  min  = d16[11] * 10 + d16[12] - 528;
  sec  = d16[13] * 10 + d16[14] - 528;
  
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0)) +
         (hour * 3600 + min * 60 + sec) / 86400.0;
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }

  return (dNum);
}

// -----------------------------------------------------------------------------
double Str31Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "yyyy-mm-dd HH:MM:SS"  "2000-03-01 15:45:17"
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec;
  double   dNum;
  
  // Check number of characters:
  if (mxGetNumberOfElements(S) != 19) {
      mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                        ERR_HEAD "String not in [yyyy-mm-dd HH:MM:SS] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (int32_T) ((d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3]  - 528);
  mon  = d16[5]  * 10 + d16[6]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[8]  * 10 + d16[9]  - 528;
  hour = d16[11] * 10 + d16[12] - 528;
  min  = d16[14] * 10 + d16[15] - 528;
  sec  = d16[17] * 10 + d16[18] - 528;
  
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0)) +
         (hour * 3600 + min * 60 + sec) / 86400.0;
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }

  return (dNum);
}

// -----------------------------------------------------------------------------
double Str300Num(const mxArray *S)
{
  // Subfunction to convert a single string to a serial date number.
  // "yyyymmddTHHMMSS.FFF"   "20000301T154517.123"
  
  uint16_T *d16;
  int32_T  year, mon, day, hour, min, sec, mil;
  double   dNum;

  // Check number of characters:
  if (mxGetNumberOfElements(S) != 19) {
      mexErrMsgIdAndTxt(ERR_ID   "BadDateString",
                        ERR_HEAD "String not in [yyyymmddTHHMMSS.FFF] format.");
  }
  
  // Extract the date and time:
  d16  = (uint16_T *) mxGetData(S);     // mxChar is UINT16!
  year = (d16[0] - 48) * 1000 + (d16[1] - 48) * 100 +
          d16[2] * 10 + d16[3]  - 528;
  mon  = d16[4]  * 10 + d16[5]  - 528;  // (d16[5]-48) * 10 + d16[6]-48
  day  = d16[6]  * 10 + d16[7]  - 528;
  hour = d16[9]  * 10 + d16[10] - 528;
  min  = d16[11] * 10 + d16[12] - 528;
  sec  = d16[13] * 10 + d16[14] - 528;
  mil  = (d16[16] - 48) * 100 + (d16[17] - 48) * 10 + (d16[18] - 48);
  
  // Calculate the serial date number:
  dNum = (double) (365 * year  + cumdays[mon] + day +
         year / 4 - year / 100 + year / 400 +
         (year % 4 != 0) - (year % 100 != 0) + (year % 400 != 0)) +
         (hour * 3600000 + min * 60000 + sec * 1000 + mil) / 86400000.0;
  if (mon > 2) {
     if ((year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0)) {
        dNum += 1.0;
     }
  }

  return (dNum);
}
