%% Algorithm for trading on the stock market, loop through different parameters
% Uses HMM in order to make prognosis about the stock market

clf
clc
clear all

% Length of learning data
startLearning = 10; % No less than 10
lengthLearningData = 150;
beginning = 0.25;
change = 0.25;
iterVector = beginning:change:10;
deltas = zeros(iterVector(end)/change,1);
correct = zeros(iterVector(end)/change,1);
wrong = zeros(iterVector(end)/change,1);
money = zeros(iterVector(end)/change,1);
iter = zeros(iterVector(end)/change,1);

iter(beginning/change:end) = iterVector;

rat = zeros(length(deltas),2);
cap = zeros(length(deltas),2);
error = zeros(length(deltas),2);

dataset = 1;

% Read data
data = xlsread('OMXS30 2011-2013.xls');

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
        [endCapital, index] = getEndingCapital(capital, opening, closing, learningVec(end), hidden);
        
        movementProg = price-closing(learningVec(end)+1:end)';
        
        %---------------------------- Validation ---------------------------------%
        
        correct(i/change) = sum((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
            (states(learningVec(end)+1:end)== 4 | states(learningVec(end)+1:end)==5) == 2)...
            + sum((hidden(1:end-1)==3) + (states(learningVec(end)+1:end) == 3) == 2)...
            + sum((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
            (states(learningVec(end)+1:end)== 1 | states(learningVec(end)+1:end)==2) == 2);
        wrong(i/change) = length(movementProg(1:end-1)) - correct(i/change);
        
        %buy = data(1:end-1,6);
        %sell = data(2:end,3);
        
        buy = opening;
        sell = closing;
        
        
        % Calculate the return
        [endCapital, indexReturn] = getEndingCapital(capital, buy, sell, startLearning+lengthLearningData-1, hidden);
        
        money(i/change) = mean(endCapital);
        err(i/change) = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');
        disp(err)
    end

    
    ratio = correct./(correct+wrong);
    
    %disp(['Delta','  ','Correct','  ', 'Wrong','  ','Error ratio','  ','Ending capital'])
    %disp([deltas, correct, wrong, ratio, money])
    
    rat(:,dataset) = ratio';
    
    cap(:,dataset) = money;
    
    error(:,dataset) = err;
    
%end

%%
%---------------------------- PLOTS --------------------------------------%
clf

% Plot the true and forecasted price
figure(1)
subplot(1,1,1)
plot(deltas, rat(:,1),'b');%,deltas, rat(:,2),'r');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Delta $\Delta$','Interpreter','latex', 'fontsize', 18);
ylabel('Ratio [\%]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2','Position', 'southwest');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Ratio of correct movements','Interpreter','latex', 'fontsize', 20);
xlim([deltas(1) deltas(end)])

figure(2)
subplot(1,1,1)
plot(deltas, cap(:,1),'b');%,deltas,cap(:,2),'r');
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Delta $\Delta$','Interpreter','latex', 'fontsize', 18);
ylabel('Capital [SEK]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Capital vs delta','Interpreter','latex', 'fontsize', 20);
xlim([deltas(1) deltas(end)])


figure(3)
subplot(1,1,1)
plot(deltas, error(:,1),'b');%, deltas, error(:,2),'r');    
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Delta $\Delta$','Interpreter','latex', 'fontsize', 18);
ylabel('MSE [SEK]','Interpreter','latex', 'fontsize', 18);
%h_legend = legend('Data set 1','Data set 2','Position', 'southwest');
%set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Mean squared error','Interpreter','latex', 'fontsize', 20);
xlim([deltas(1) deltas(end)])

