RandStream.setDefaultStream(RandStream('mt19937ar', 'seed', 100*sum(clock)))

addpath(genpath('svmPipe'));
addpath(genpath('kernels'));
addpath(genpath('libsvm-mat-3.0-1'));
addpath(genpath('utils'));