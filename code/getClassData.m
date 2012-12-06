function [lab,d, rootDir, iStart, saveFile] = getClassData(n)

    switch (n)
        case 0
            lab{1} = 'window';
            lab{2} = 'left wing';
            lab{3} = 'right wing';
            lab{4} = 'tail';
            lab{5} = 'cockpit';
            lab{6} = 'body';
            lab{7} = 'exhaust';
            lab{8} = 'engine';
            lab{9} = 'gears';
            lab{10} = 'propeller';
            lab{11} = 'doors';
            
            d = 'airplane/';
            saveFile = 'airplane.txt';
            rootDir = '../data/airplane-stroke/';
            iStart = 1;
        case 1
            lab{1} = 'head';
            lab{2} = 'right arm';
            lab{3} = 'left arm';
            lab{4} = 'right leg';
            lab{5} = 'left leg';
            lab{6} = 'right hand';
            lab{7} = 'left hand';
            lab{8} = 'right foot';
            lab{9} = 'left foot';
            lab{10} = 'body';
            lab{11} = 'hair';
            lab{12} = 'neck';
            
            d = 'person-walking/';
            saveFile = 'person-walking.txt';
            rootDir = '../data/person-walking-stroke/';            
            iStart = 12161;
        case 2
            lab{1} = 'body';
            lab{2} = 'stem';
            lab{3} = 'leaf';
            lab{4} = 'body reflection';
            lab{5} = 'roots';
            
            d = 'apple/';
            saveFile = 'apple.txt';
            rootDir = '../data/apple-stroke/';
            iStart = 321;
        case 3
            lab{1} = 'right eye';
            lab{2} = 'left eye';
            lab{3} = 'right eyebrow';
            lab{4} = 'left eyebrow';
            lab{5} = 'nose';
            lab{6} = 'mouth';
            lab{7} = 'right ear';
            lab{8} = 'left ear';
            lab{9} = 'head';
            lab{10} = 'hair';
            
            d = 'face/';
            saveFile = 'face.txt';
            rootDir = '../data/face-stroke/';
            iStart = 6241;
        case 4
            lab{1} = 'body';
            lab{2} = 'fingerboard';
            lab{3} = 'scroll';
            lab{4} = 'strings';
            lab{5} = 'f-hole';
            lab{6} = 'bow';
            lab{7} = 'bridge';
            lab{8} = 'centre hole'; % not actual violin part
            lab{9} = 'tailpiece';
            lab{10} = 'chin rest';
            lab{11} = 'string endpiece';
            lab{12} = 'button';
            
            d = 'violin/';
            saveFile = 'violin.txt';
            rootDir = '../data/violin-stroke/';
            iStart = 19281;
        otherwise
            error('Bad class num: %d', n);
    end