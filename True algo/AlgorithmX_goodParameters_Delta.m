%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc

% Length of learning data
startLearning = 10; % No less than 10
lengthLearningData = 120;
beginning = 0.25;
change = 0.25;
iterVector = beginning:change:10;
deltas = zeros(iterVector(end)/change,1);
correct = zeros(iterVector(end)/change,1);
wrong = zeros(iterVector(end)/change,1);
money = zeros(iterVector(end)/change,1);
iter = zeros(iterVector(end)/change,1);

iter(beginning/change:end) = iterVector;

% Read data
data = xlsread('DataFiltered1.xlsx');

% Get openinging price
opening = data(1:end-1,3);

% Get closing price
closing = data(2:end,3);

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
    moveToday = closing(1:end) - opening(1:end);
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
    endCapital = getEndingCapital(capital, opening, closing, learningVec(end), hidden);
    
    movementProg = price-closing(learningVec(end)+1:end)';
    
    %---------------------------- Validation ---------------------------------%
    
    correct(i/change) = sum((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
    (states(learningVec(end)+1:end)== 4 | states(learningVec(end)+1:end)==5) == 2)...
    + sum((hidden(1:end-1)==3) + (states(learningVec(end)+1:end) == 3) == 2)...
    + sum((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
    (states(learningVec(end)+1:end)== 1 | states(learningVec(end)+1:end)==2) == 2);
    wrong(i/change) = length(movementProg(1:end-1)) - correct(i/change);
    
    buy = data(1:end-1,6);
    sell = data(2:end,3);

    % Calculate the return
    endCapital = getEndingCapital(capital, buy, sell, startLearning+lengthLearningData-1, hidden);
    
    money(i/change) = mean(endCapital);
    err(i/change) = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');
    
end


ratio = correct./(correct+wrong);

disp(['Delta','  ','Correct','  ', 'Wrong','  ','Error ratio','  ','Ending capital'])
disp([deltas, correct, wrong, ratio, money])

%%
%---------------------------- PLOTS --------------------------------------%
    
    % Plot the true and forecasted price
    figure(1)
    subplot(2,1,1)
    plot(deltas, ratio);
    title('Ratio of correct predictions');
    ylabel('Percent');
    xlabel('Delta');

    
    subplot(2,1,2)
    plot(deltas, money);
    ylabel('Money [SEK]');
    title('Capital')
    xlabel('Delta');
%%    
    subplot(3,1,3)
    plot(deltas, err);
    ylabel('MSE');
    xlabel('Delta');
