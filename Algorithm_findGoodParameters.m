%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc

% Length of learning data
startLearning = 10; % No less than 10
beginning = 20;
change = 10;
iterVector = beginning:change:600;
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
data = xlsread('GOOG-LON_IGUS.xls');

% Get openinging price
opening = data(:,2);

% Get closing price
closing = data(:,5);

for i = iterVector % 45 is best but then we get a row with zeros in the emision matrix
    disp(i)
    lengthLearningData = i;
    learningVec = startLearning:startLearning+lengthLearningData-1;
    
    % Set difference (delta) between two states
    delta = 6;
    
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
    
    transMatrices(:,:,i/change) = trans;
    emisMatrices(:,:,i/change) = emis;
    
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
    
    err(i/change) = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');
    
end


ratio = correct./(correct+wrong);

disp(['LengthLearn','  ','Error ratio','  ','Ending capital',' ','MSE [10^3]'])
disp([iter, ratio, money, err/1000])

%------------------------ Check change in matrices -----------------------%

biggestDiffTrans = zeros(length(transMatrices)-2,1);
biggestDiffEmis = zeros(length(emisMatrices)-2,1);
for i = 3:length(transMatrices)-1

    biggestDiffTrans(i-2) = max(max(transMatrices(:,:,i)-transMatrices(:,:,i+1)));
    biggestDiffEmis(i-2) = max(max(emisMatrices(:,:,i)-emisMatrices(:,:,i+1)));
    
end

%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
figure(1)
subplot(3,2,1)
plot(iter, ratio);
ylabel('Ratio of correct movements');
xlabel('Learning length');


subplot(3,2,3)
plot(iter, money);
ylabel('Money');
xlabel('Learning length');


subplot(3,2,5)
plot(iter, err);
ylabel('MSE');
xlabel('Learning length');


subplot(3,2,2)
plot(biggestDiffTrans)
subplot(3,2, 4)
plot(biggestDiffEmis)