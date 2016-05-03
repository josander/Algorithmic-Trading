%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc

% Length of learning data
startLearning = 10; % No less than 10
lengthLearningData = 50;
beginning = 0.5;
change = 0.25;
iterVector = beginning:change:12;
deltas = zeros(iterVector(end)/change,1);
correct = zeros(iterVector(end)/change,1);
wrong = zeros(iterVector(end)/change,1);
money = zeros(iterVector(end)/change,1);
iter = zeros(iterVector(end)/change,1);

iter(beginning/change:end) = iterVector;

% Read data
data = xlsread('GOOG-LON_IGUS.xls');

% Get openinging price
opening = data(:,2);

% Get closing price
closing = data(:,5);

for i = iterVector % 45 is best but then we get a row with zeros in the emision matrix
    disp(i)
    learningVec = startLearning:startLearning+lengthLearningData-1;
    
    % Set difference (delta) between two states
    delta = i;
    
    deltas(i/change) = delta;
    
    % Starting capital
    capital = 100;
    
    %-------------------------------------------------------------------------%
    
    % Get price movement today and tomorrow
    moveToday = opening(1:end) - closing(1:end);
    moveTomorrow = moveToday(2:end);
    
    % Get observable sequence for learning
    seq = getObservations(moveToday, closing, delta);
    
    % Get hidden sequenc e for learning
    states = getHidden(moveTomorrow, delta);
    
    % Get model parameters
    [trans, emis] = getModel(seq(learningVec), states(learningVec));
    
    % Get prognosis
    [price, hidden] = getPrognosis(seq, learningVec(end), trans, emis, delta, closing);
    
    % Calculate the return
    endCapital = getEndingCapital(capital, opening, closing, learningVec, hidden);
    
    movementProg = price-closing(learningVec(end)+1:end)';
    
    %---------------------------- Validation ---------------------------------%
    
    correct(i/change) = sum((movementProg(1:end-1) > 0 & moveToday(learningVec(end)+2:end)' > 0) | ...
        (movementProg(1:end-1) < 0 & moveToday(learningVec(end)+2:end)' < 0) | ...
        (movementProg(1:end-1) == 0 & moveToday(learningVec(end)+2:end)' == 0));
    wrong(i/change) = length(movementProg(1:end-1)) - correct(i/change);
    
    money(i/change) = endCapital(end);
    
end


ratio = correct./(correct+wrong);

disp(['Delta','  ','Correct','  ', 'Wrong','  ','Error ratio','  ','Ending capital'])
disp([deltas, correct, wrong, ratio, money])

% MSE
err = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');

disp('Mean squared error:')
disp(err)
%%
%---------------------------- PLOTS --------------------------------------%
    
    % Plot the true and forecasted price
    figure(1)
    subplot(2,1,1)
    plot(deltas, ratio);
    ylabel('');
    xlabel('Delta');

    
    subplot(2,1,2)
    plot(deltas, money);
    ylabel('Money');
    xlabel('Delta');
