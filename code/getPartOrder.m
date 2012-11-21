function getPartOrder(n)

    useDuplicates = 1;

    [~,objType,rootDir, iStart, saveFile] = getClassData(n);
    display(['Outputing file: ', saveFile]);
    
    SIZE_THRESH = 60;
                
    stAll = [];
    i=iStart;
    while(1)
        ord = [];
        clear bbAll;
        clear partTypes;
        
        loadFile = ['data/', objType,int2str(i),'-Parts.mat'];
        if (~exist(loadFile,'file'))
            display(['File does not exist: ', loadFile, '. Quiting.']);
           break; 
        end
        display(['On image: ', int2str(i)]);
        load(loadFile,'bbAll','partTypes','lab');
        
        ims = getImStack(rootDir,i);
        
        %imWithRect(ims(:,:,end),bbAll);
        %pause;
        
        for (j=2:size(ims,3))
 
            % Check if stroke valid
            stroke = ims(:,:,j)-ims(:,:,j-1);            
            if(sum(stroke(:)) < SIZE_THRESH)
                continue;
            end
            blur = (ims(:,:,end) - stroke)==1;
            blur = bwmorph(blur,'dilate',8);

            intersect = blur & stroke;
            if (sum(intersect(:)) == sum(stroke(:)))
                continue;
            end
            
            objMask = partOfObj(stroke,bbAll);
            objMask = cleanUpObjMask(objMask,bbAll);
            objMask = find(objMask==1);
            
            for (k=1:numel(objMask))
                if(~exist('ord','var'))
                    ord = objMask(k);
                else
                    if(isempty(find(objMask(k)==ord,1)))
                        partUse = objMask(k);
                        if (~any(ord == partUse))
                            ord(end+1,1) = partUse;
                        end
                    end
                end
            end
        end
        res = partTypes(ord);
        
        % remove duplicates
        if (~useDuplicates)
            [~,id] = unique(res);
            res = res(sort(id));
        end
        
        % 0 is start symbol
        st = '0';
        for (ii=1:numel(res))
            st = [st, ',', int2str(res(ii))];
        end
        stAll{i-iStart+1} = st;
        i=i+1;
    end
    
    fid=fopen(saveFile,'w');
    for (i=1:numel(stAll))
        fprintf(fid,[stAll{i}, '\n']);
    end;
    fclose(fid);
end

function res = cleanUpObjMask(objMask,bbAll)

    res = objMask;
    objMask = find(objMask == 1);
    bbAllMask = bbAll(objMask,:);
    
    sz = (bbAllMask(:,3)-bbAllMask(:,1)+1).*(bbAllMask(:,4)-bbAllMask(:,2)+1);
    
    for (i=1:numel(objMask))
        
        szUse = sz(i);
        szOther = sz;
        szOther(i) = [];
        
        if(any(szUse > szOther))
            res(objMask(i)) = 0;
        end                
    end

end

function res = partOfObj(stroke,bbAll)

    st = find(stroke == 1);
    
    [y,x] = ind2sub(size(stroke),st);
    
    yStart = min(y);
    yStop = max(y);
    
    xStart = min(x);
    xStop = max(x);
    
    res = zeros(size(bbAll,1),1);
    for (i=1:size(bbAll,1))
       res(i) = (yStart >= bbAll(i,1)) & (xStart >= bbAll(i,2)) & ...
                (yStop <= bbAll(i,3)) & (xStop <= bbAll(i,4));
    end
end