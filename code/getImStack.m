function [im] = getImStack(rootDir,imNum)
    j =1;
    while(1)
        fName = [rootDir,int2str(imNum),'-',int2str(j),'.png'];
        if(~exist(fName,'file'))
           break;
        end
        imTemp = imread(fName);
        
        if(~exist('im','var'))
           im = zeros(size(imTemp,1),size(imTemp,2));
        end
        im(:,:,end+1) = imTemp;
        j=j+1;
    end
end

