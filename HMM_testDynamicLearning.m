%% Test HMM functions of real data
clc
clear all
clf

data = xlsread('WIKI-FLWS.xls');

% Size of learningData
lengthLearningData = 20;

% Start and stop learning
startLearning = 2;
endLearning = size(data,1)-(lengthLearningData+1);

% Specify maximal number of iterations. Default is 500
maxiter = 1000;

% Tolerance for the Baum-Welch algoritm (hmmtrain)
tol = 1e-4;

warnings = 0;

% Memory allocation
days = zeros(1,endLearning-1);
plotStates = zeros(1,endLearning-1);
plotLikelyStates = zeros(1,endLearning-1);
plotClose = zeros(1,endLearning-1);
plotCloseProg = zeros(1,endLearning-1);


tic
for learn = startLearning:endLearning
    
    % Get opening price
    open = data(learn:learn+lengthLearningData-1,2)';
    
    % Get closing price
    close = data(learn:learn+lengthLearningData-1,5)';
    
    % Get intraday movement
    movement = open - close;
    
    % Create 3 observable states: [Rise, Constant, Drop]
    seq = zeros(size(movement));
    seq(movement<0) = 1;
    seq(movement==0) = 2;
    seq(movement>0) = 3;
    
    % Create 5 hidden states: [big drop, small drop, constant, small rise, big rise]
    biggestChange = max(movement) - min(movement);
    delta = biggestChange/500;
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
    [trans_train, emis_train] = hmmtrain(seq, trans_est, emis_est,'maxiterations',maxiter,'Tolerance',tol);
    [msgstr, msgid] = lastwarn;
    lastwarn('');
    if ~isempty(msgstr)
        warnings = warnings + 1;
    end
    
    % PROGNOSIS
    nextDay = learn + lengthLearningData + 1;
    
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
    
    % Use Viterbi to estimate most probable state sequence
    likelystatesNew = hmmviterbi(seqNew, trans_train, emis_train);
    
    close_prog = zeros(size(movementNew));
    close_prog(likelystatesNew == 1) = openNew(likelystatesNew == 1) + 4*a;
    close_prog(likelystatesNew == 2) = openNew(likelystatesNew == 2) + 2*a;
    close_prog(likelystatesNew == 3) = openNew(likelystatesNew == 3) + 0;
    close_prog(likelystatesNew == 4) = openNew(likelystatesNew == 4) + 2*b;
    close_prog(likelystatesNew == 5) = openNew(likelystatesNew == 5) + 4*b;
    
    days(learn-1) = nextDay;
    plotStates(learn-1) = statesNew;
    plotLikelyStates(learn-1) = likelystatesNew;
    plotClose(learn-1) = closeNew;
    plotCloseProg(learn-1) = close_prog;
    
end
toc
subplot(2,1,1)
plot(days, plotStates,'b-', days, plotLikelyStates,'r-');
legend('Actual state','Prognosis')
xlabel('Days');
ylabel('States');

subplot(2,1,2)
plot(days, plotClose,'b-', days, plotCloseProg,'r-');
legend('Actual price','Prognosis')
xlabel('Days');
ylabel('Price');

% MSE
err = immse(plotClose,plotCloseProg)

% Display number of warnings
disp(warnings)
