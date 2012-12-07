
gabors = gaborBank();
%[partsPos,partNeg] = extractExampleParts(2);

posFeat = getSimpleResponses(gabors,partsPos);