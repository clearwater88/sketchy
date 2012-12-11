function genData(tStart,tStop,classUse,nIm)
    for (t=tStart:tStop)
        display(['On trial: ', int2str(t)]);
        extractExampleParts(classUse,nIm,t);
    end
end