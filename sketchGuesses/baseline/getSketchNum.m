function [sketchNum,strokeNum] = getSketchNum(filename)

    k = strfind(filename,'-');
    if(isempty(k))
        k = strfind(filename,'.');
    end
    sketchNum = filename(1:k-1);
    k= strfind(filename,'-');
    if (~isempty(k))
        strokeNum = str2double(filename(k+numel('-'):end-4));
    else
        strokeNum = -1;
    end
    
end

