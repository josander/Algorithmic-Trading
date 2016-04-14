%% Testing HMM-functions
% For a given transition and emission matrix

% Transition matrix
trans = [0.9 0.1; 0.5 0.95];

% Emission matrix
emis = [1/6 1/6 1/6 1/6 1/6 1/6; 7/12 1/12 1/12 1/12 1/12 1/12];

% Generate a random sequence of states and emissions from the model
[seq, states] = hmmgenerate(1000, trans, emis);

% Use Viterbi to estimate most probable state sequence
likelystates = hmmviterbi(seq, trans, emis);

% Get accuracy of the sequency
accuracy = sum(states == likelystates)/1000;
disp(accuracy)

%% For a given emission sequence (requires a known state sequence as well)

% Get estimate of transition and emision matrix
[trans_est, emis_est] = hmmestimate(seq, states);

% See how they differ from previous matrices
trans_diff = trans - trans_est;
disp(trans_diff)

emis_diff = emis - emis_est;
disp(emis_diff)

%% For a given emission sequence (and unknown state sequence)

% Guess of the two matrices
trans_guess = [0.85 0.15; 0.1 0.9];

emis_guess = [.17 .16 .17 .16 .17 .17;.6 .08 .08 .08 .08 .08];

% Specify maximal number of iterations. Default is 500
maxiter = 1000;

% Estimate the two matrices
[trans_est2, emis_est2] = hmmtrain(seq, trans_guess, emis_guess,'maxiterations',maxiter);

