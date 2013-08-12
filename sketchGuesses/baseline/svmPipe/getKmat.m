function [res] = getKmat(params, features1, features2)
    switch(params.svmKernType)
        case 'dot'
            res = dotKer(features1, features2);
        case 'KL'
            res = KL(features1, features2);
        case 'spm'
            res = spm(features1, ...
                      features2, ...
                      params.C, ...
                      params);
        case 'intersect'
            res = histInter(features1, features2);
        otherwise
            error(['Unknown svm kernel type: ', params.svmKernType]);
    end
end

