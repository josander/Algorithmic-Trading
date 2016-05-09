%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc

% Length of learning data
startLearning = 10; % No less than 10
beginning = 40;
change = 10;
iterVector = beginning:change:200;
deltas = zeros(iterVector(end)/change,1);
correct = zeros(iterVector(end)/change,1);
wrong = zeros(iterVector(end)/change,1);
money = zeros(iterVector(end)/change,1);
iter = zeros(iterVector(end)/change,1);
err = zeros(iterVector(end)/change,1);
transMatrices = zeros(5,5,iterVector(end)/change);
emisMatrices = zeros(5,9,iterVector(end)/change);

iter(beginning/change:end) = iterVector;

% Read data
data = xlsread('DataFiltered1.xlsx');

% Get openinging price
opening = data(1:end-1,3);

% Get closing price
closing = data(2:end,3);

for i = iterVector % 45 is best but then we get a row with zeros in the emision matrix
    disp(i)
    lengthLearningData = i;
    learningVec = startLearning:startLearning+lengthLearningData-1;
    
    % Set difference (delta) between two states
    delta = 2;
    
    deltas(i/change) = delta;
    
    % Starting capital
    capital = 100;
    
    %-------------------------------------------------------------------------%
    
    % Get price movement today and tomorrow
    moveToday = closing - opening;
    moveTomorrow = moveToday(2:end);
    
    % Get observable sequence for learning
    seq = getObservations(moveToday, closing, delta);
    
    % Get hidden sequenc e for learning
    states = getHidden(moveTomorrow, delta);
    
    % Get model parameters
    [trans, emis] = getModel(seq(learningVec), states(learningVec));

    % Get prognosis
    [price, hidden] = getPrognosis(seq, learningVec(end), trans, emis, delta, closing);
    
    buy = data(1:end-1,6);
    sell = data(2:end,3);
    
    % Calculate the return
    endCapital = getEndingCapital(capital, buy, sell, learningVec(end), hidden);
    
    movementProg = price-closing(learningVec(end)+1:end)';
    
    %---------------------------- Validation ---------------------------------%
    
    correct(i/change) = sum((movementProg(1:end-1) > 0 & moveToday(learningVec(end)+2:end)' > 0) | ...
        (movementProg(1:end-1) < 0 & moveToday(learningVec(end)+2:end)' < 0) | ...
        (movementProg(1:end-1) == 0 & moveToday(learningVec(end)+2:end)' == 0));
    wrong(i/change) = length(movementProg(1:end-1)) - correct(i/change);
    
    money(i/change) = mean(endCapital);
    
    err(i/change) = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');
    
end


ratio = correct./(correct+wrong);

disp(['LengthLearn','  ','Error ratio','  ','Ending capital',' ','MSE [10^3]'])
disp([iter, ratio, money, err/1000])

%---------------------------- PLOTS --------------------------------------%
%%
% Plot the true and forecasted price
figure(1)
subplot(2,1,1)
plot(iter, ratio);
title('Ratio of correct movements');
xlabel('Learning length');

subplot(2,1,2)
plot(iter(4:end), money(4:end));
title('Capital');
ylabel('Money [SEK]');
xlabel('Learning length');
%%
subplot(3,1,3)
plot(iter(4:end), err(4:end));
title('Error')
ylabel('MSE [SEK]');
xlabel('Learning length');
