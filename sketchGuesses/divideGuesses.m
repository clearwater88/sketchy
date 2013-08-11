function divideGuesses()

    load('equivClasses.mat');
    nExPerClass = 4;

    classNames = getClassNames;
    strokesFolder = '../data/';
    exampleIds = getExamples();
    folder = 'data/';

    for (i=1:numel(classNames))
       [~,~,~] = mkdir(classNames{i}); 
    end

    for (i=1:numel(classNames))
        display(['class: ', int2str(i)]);
        ids = exampleIds{i};
        className = classNames{i};
        for (n=1:nExPerClass)
            f = [folder,classNames{i},'_',int2str(n)];
            load(f,'Guesses');

            [cleanedGuesses] = getLabels(Guesses,equivLin,labels);
            nStrokes = numel(Guesses);

            file = [strokesFolder, className, '-stroke/', int2str(ids(n))];
            for (j=1:nStrokes)
                strokeFile = [file,'-',int2str(j), '.png'];
                % need to invert for Mathias' pipeline
                % black on white background
                x=logical(1-imread(strokeFile));
                if(j==1) temp = x; 
                else temp = temp & x;
                end

                if(~isempty(cleanedGuesses{j}))
                    guessedClasses = cleanedGuesses{j};
                    for (k=1:numel(guessedClasses))
                        resFolder = classNames{guessedClasses(k)};
                        saveFile = [resFolder,'/',int2str(ids(n)),'-stroke', int2str(j),'.png'];

    %                     if(guessedClasses(k)==4)
    %                         
    %                     end

                        imwrite(temp,saveFile);
                    end
                end

            end
        end
    end
end