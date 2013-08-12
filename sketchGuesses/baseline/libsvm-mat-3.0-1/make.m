% This make.m is used under Windows

% add -largeArrayDims on 64-bit machines

% mex -O -c -largeArrayDims svmL2.cpp
% mex -O -c -largeArrayDims svm_model_matlab.c
% mex -O -largeArrayDims svmtrainL2.c svmL2.o svm_model_matlab.o
% mex -O -largeArrayDims svmpredictL2.c svmL2.o svm_model_matlab.o
% mex -O -largeArrayDims libsvmread.c
% mex -O -largeArrayDims libsvmwrite.c

mex -O -c -largeArrayDims svm.cpp
mex -O -c -largeArrayDims svm_model_matlab.c
mex -O -largeArrayDims svmtrain.c svm.obj svm_model_matlab.obj
mex -O -largeArrayDims svmpredict.c svm.obj svm_model_matlab.obj
mex -O -largeArrayDims libsvmread.c
mex -O -largeArrayDims libsvmwrite.c
