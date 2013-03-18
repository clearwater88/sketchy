function [sh2, ph2] = shapebm_sample_h2(params, sh1)

    n = size(sh1, 1);
            
    raw = sh1 * params.W2' + repmat_fast(params.b2', n);

    ph2 = sigmoid(raw);
    sh2 = draw_bernoulli(ph2);

end