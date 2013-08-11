function [ features ] = readBOWFeat( filename )
%This function reads the resulting binary files obtained after running the c++ code (convert2matlab\main.cpp) on the histvw file. 
%The histvw is obtained by running the compute_histvw command in the imdb
%framework. It contains the BOW feature vectors for the images.
%

%Obtain file handle
fid = fopen(filename);

%Read the number of images for which the BOW features have been obtained.
n = fread(fid, 1, 'uint32');

%Read the BOW feature vector size (set to 500 as suggested in the paper)
m = fread(fid, 1, 'uint32');

%Read the BOW feature vector for each image. 
features = zeros(n,m);
for i=1:n
    if (feof(fid))
        error('readBOWFeat:EarlyEOF','End of file reached before the data is completely read. Something is wrong')
    end
    features(i,:) = fread(fid, m, 'float');
end

%Check if data read is successful. 
%Note that EOF flag is set to 1 only when an fread fails. So, we have to 
%read beyond the file to signal EOF. Hence we have to do one more read 
%operation. 
temp = fread(fid, 1, 'float');
if (feof(fid))
    disp('Data read successfully')
else
    error('readBOWFeat:LateEOF', 'End of file not reached even after data is read completely. Something is wrong')
end


fclose(fid);

end
