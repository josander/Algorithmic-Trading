function [trans, emis] = getModel(seq, states)
% Given an observation sequence and a hidden sequence, the parameters for a
% hidden Markov model is found.

% Get estimate of transition and emision matrix
[trans_est, emis_est] = hmmestimate(seq, states);

% Specify maximal number of iterations. Default is 500
maxiter = 500;
tol = 1e-4;

% Train the model to get the right parameters
[trans, emis] = hmmtrain(seq, trans_est, emis_est,'maxiterations',maxiter,'Tolerance',tol);

end