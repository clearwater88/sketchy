function processGuesses()
    
    fileListFolder = 'sketchFileLists/';
    classes = getClassNames();
    
    fileLists = getFileList(fileListFolder,classes);

    guessesFolder = '../sketchGuesses/';
    strokesFolder = '../../data/';
    resFolder = 'guesses/';

    for (i=1:numel(classes))
        [~,~,~] = mkdir([resFolder, classes{i}]);
    end
    
    for (i=1:numel(classes))
       fileListClass = fileLists{i};
       
       ex = 1;
       while(1)
           file = [guessesFolder, classes{i}, '_', int2str(ex), '.mat'];
           if(~exist(file,'file')) break; end
           display(['Analyzing file: ', file]);
           load(file,'Guesses');
           
           strokeEx = fileListClass{ex}(1:end-4);
           save([resFolder,classes{i},'/',strokeEx, '-Guesses'], 'Guesses');
           for (j=1:numel(Guesses))
               
               strokeFile = [strokesFolder, classes{i}, '-stroke/', strokeEx,'-',int2str(j), '.png'];
               % need to invert for Mathias' pipeline
               % black on white background
               x=logical(1-imread(strokeFile));
               if(j==1) temp = x;
               else temp = temp & x;
               end
               
               if(~isempty(Guesses{j}))
                   saveImFile = [resFolder,classes{i},'/',strokeEx,'-stroke', int2str(j),'.png'];
                   imwrite(temp,saveImFile);
               end

            end
           
           ex=ex+1;
       end   
    end
end


function res = getFileList(fileListFolder,classes)
    res = cell(numel(classes),1);

    for (i=1:numel(classes))
       file = [fileListFolder,classes{i}, '_files.txt'];
       display(['Loading file: ', file]);
       %res{i} = textread(file);
       fid = fopen(file);
       temp = textscan(fid, '%s');
       res{i} = temp{1};
       fclose(fid);
    end
end