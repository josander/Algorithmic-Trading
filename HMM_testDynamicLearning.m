%% Test HMM functions of real data
clc
clear all
clf

data = xlsread('WIKI-FLWS.xls');

% Size of learningData
lengthLearningData = 20;

% Stop iterating
endLearning = 20;%size(data,1)-(lengthLearningData+1);

% Specify maximal number of iterations. Default is 500
maxiter = 1000;

% Memory allocation
days = zeros(1,endLearning-1);
plotStates = zeros(1,endLearning-1);
plotLikelyStates = zeros(1,endLearning-1);
plotClose = zeros(1,endLearning-1);
plotCloseProg = zeros(1,endLearning-1);

for startLearning = 2:endLearning
    
    disp(startLearning)

    % Get opening price
    open = data(startLearning:startLearning+lengthLearningData-1,2)';

    % Get closing price
    close = data(2:2+lengthLearningData-1,5)';

    % Get intraday movement
    movement = open - close;

    % Create 3 observable states: [Rise, Constant, Drop]
    seq = zeros(size(movement));
    seq(movement<0) = 1;
    seq(movement==0) = 2;
    seq(movement>0) = 3;

    % Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
    biggestChange = max(movement) - min(movement);
    delta = biggestChange/30;
    a = -delta;
    b = delta;

    % Create state-matrix [5x5]
    states = zeros(size(movement));
    states(movement < 3*a) = 1;
    states(movement >= 3*a & movement < a) = 2;
    states(movement >= a & movement < b) = 3;
    states(movement >= b & movement < 3*b) = 4;
    states(movement >= 3*b ) = 5;

    % ESTIMATE MATRICES
    % Get estimate of transition and emision matrix
    [trans_est, emis_est] = hmmestimate(seq, states);


    % TRAIN THE HMM

    % Estimate the two matrices
    [trans_train, emis_train] = hmmtrain(seq, trans_est, emis_est,'maxiterations',maxiter);

    % PROGNOSIS

    nextDay = startLearning + lengthLearningData + 1;

    % Get opening price
    openNew = data(nextDay,2)';

    % Get closing price
    closeNew = data(nextDay,5)';

    % Get past movement
    movementNew = openNew - closeNew;

    % Create 3 observable states: [Rise, Constant, Drop]
    seqNew = zeros(size(movementNew));
    seqNew(movementNew<0) = 1;
    seqNew(movementNew==0) = 2;
    seqNew(movementNew>0) = 3;

    % Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
    % Create state-matrix [5x5]
    statesNew = zeros(size(movementNew));
    statesNew(movementNew < 3*a) = 1;
    statesNew(movementNew >= 3*a & movementNew < a) = 2;
    statesNew(movementNew >= a & movementNew < b) = 3;
    statesNew(movementNew >= b & movementNew < 3*b) = 4;
    statesNew(movementNew >= 3*b ) = 5;

    disp(seqNew)
    disp(trans_train)
    disp(emis_train)
    
    % Use Viterbi to estimate most probable state sequence
    likelystatesNew = hmmviterbi(seqNew, trans_train, emis_train);

    close_prog = zeros(size(movementNew));
    close_prog(likelystatesNew == 1) = openNew(likelystatesNew == 1) + 4*a;
    close_prog(likelystatesNew == 2) = openNew(likelystatesNew == 2) + 2*a;
    close_prog(likelystatesNew == 3) = openNew(likelystatesNew == 3) + 0;
    close_prog(likelystatesNew == 4) = openNew(likelystatesNew == 4) + 2*b;
    close_prog(likelystatesNew == 5) = openNew(likelystatesNew == 5) + 4*b;
    
    days(startLearning-1) = nextDay;
    plotStates(startLearning-1) = statesNew;
    plotLikelyStates(startLearning-1) = likelystatesNew;
    plotClose(startLearning-1) = closeNew;
    plotCloseProg(startLearning-1) = close_prog;
    
end

subplot(2,1,1)
plot(days, plotStates,'b-', days, plotLikelyStates,'r-');

subplot(2,1,2)
plot(days, plotClose,'b-', days, plotCloseProg,'r-');

% MSE
err = immse(plotClose,plotCloseProg)

