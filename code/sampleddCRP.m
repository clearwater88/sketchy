function clusters = sampleddCRP(n,alpha,decay,SAMPLES)
    
    sp = (1:n)';
    clusters = cell(SAMPLES,1);
    
    for(j=1:SAMPLES)
        % sample each guy in turn
        % sequential CRP
        for (i=2:n)
            dist = abs(i-(1:i-1));
            fDist = exp(-dist/decay);
            fDist(end+1) = alpha;
            sampProbs = fDist/sum(fDist);
            sp(i) = sampMulti(sampProbs,1);
        end
        clusters{j} = getClusters(sp);
    end
end

function sp = collapseSP(sp)
    for (i=1:numel(sp))
        while(sp(sp(i)) ~= sp(i))
            sp(i) = sp(sp(i));
        end
    end;
end

function res = getClusters(sp)
    sp = collapseSP(sp);
    spUnique = unique(sp);
    res = cell(numel(unique(sp)),1);
    for (i=1:numel(spUnique))
        res{i} = find(sp==spUnique(i));
    end
end

