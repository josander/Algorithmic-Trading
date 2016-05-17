%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 10; % No less than 10
beginning = 20;
change = 5;
iterVector = beginning:change:250;
deltas = zeros(iterVector(end)/change,1);
correct = zeros(iterVector(end)/change,1);
wrong = zeros(iterVector(end)/change,1);
money = zeros(iterVector(end)/change,1);
iter = zeros(iterVector(end)/change,1);
err = zeros(iterVector(end)/change,1);
transMatrices = zeros(5,5,iterVector(end)/change);
emisMatrices = zeros(5,9,iterVector(end)/change);

iter(beginning/change:end) = iterVector;

rat = zeros(length(deltas),2);
cap = zeros(length(deltas),2);
error = zeros(length(deltas),2);

% Read data
data = xlsread('OMXS30 2011-2013.xls');

dataset = 1;
%for dataset = 1:2
    first = [1 453];
    last = [370 822];
    
    % Get openinging price
    %opening = data(first(dataset):last(dataset)-1,2);
    opening = data(1:end-1,2);
    % Get closing price
    %closing = data(first(dataset)+1:last(dataset),2);
    closing = data(2:end,2);
    
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
        
        %buy = data(1:end-1,6);
        %sell = data(2:end,3);
        
        buy = opening;
        sell = closing;
        
        % Calculate the return
        [endCapital, index] = getEndingCapital(capital, buy, sell, learningVec(end), hidden);
        
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
    
    rat(:,dataset) = ratio';
    
    cap(:,dataset) = money;
    error(:,dataset) = err;
    
%end
%%
%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
figure(1)
subplot(1,1,1)
clf
plot(iter, rat(:,1), 'b');%,iter, rat(:,2), 'r');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Learning length $L$','Interpreter','latex', 'fontsize', 18);
ylabel('Ratio [\%]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2','Position', 'southwest');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Ratio of correct movements','Interpreter','latex', 'fontsize', 20);
xlim([iter(10) iter(end)])

figure(2)
subplot(1,1,1)
clf
plot(iter(4:end), cap(4:end,1),'b');%,iter(4:end), cap(4:end,2),'r');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Learning length $L$','Interpreter','latex', 'fontsize', 18);
ylabel('Capital [SEK]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Capital vs learning length','Interpreter','latex', 'fontsize', 20);
hold on
xlim([iter(10) iter(end)])

figure(3)
subplot(1,1,1)
clf
plot(iter(4:end), error(4:end,1), 'b');%,iter(4:end), error(4:end,2), 'r');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Learning length $L$','Interpreter','latex', 'fontsize', 18);
ylabel('MSE [SEK]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Mean squared error vs learning length','Interpreter','latex', 'fontsize', 20);
xlim([iter(10) iter(end)])
hold on
xlim([iter(10) iter(end)])