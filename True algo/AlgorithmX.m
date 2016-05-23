%% Algorithm for trading on the stock market
% Uses HMM in order to make prognosis about the stock market

%clf
clc
clear all

% Length of learning data
startLearning = 11; % No less than 11
lengthLearningData = 150;

% Read data
data = xlsread('DataFiltered1.xlsx');


ratio = zeros(20,1);
pValueRatio = zeros(20,1);
SharpeRatio = zeros(20,1);
pValueReturn = zeros(20,1);
absReturn = zeros(20,1);
avgReturn = zeros(20,1);

% Chose data set
for dataset = 1:1;
    
    % Set difference (delta) between two states
    delta = 2;
    
    % Starting capital
    capital = 100;
    
    %-------------------------------------------------------------------------%
    
    %first = (1:371:7050)';
    %last = (371:371:7420)';
    first = [1 453];
    last = [371 823];
    
    % Get openinging price
    opening = data(first(dataset):last(dataset)-1,3);
    %opening = data(first(dataset):last(dataset)-1,4);
    %
    % Get closing price
    closing = data(first(dataset)+1:last(dataset),3);
    %closing = data(first(dataset)+1:last(dataset),4);
    
    % Get price movement today and tomorrow
    moveToday = closing - opening;
    moveTomorrow = moveToday(2:end);
    
    % Define learning vector for later
    learningVec = startLearning:startLearning+lengthLearningData-1;
    
    % Get observable sequence for learning
    seq = getObservations(moveToday, closing, delta);
    
    % Get hidden sequence for learning
    states = getHidden(moveTomorrow, delta);
    
    % Get model parameters
    [trans, emis] = getModel(seq(learningVec), states(learningVec));
    
    % Get prognosis
    [price, hidden] = getPrognosis(seq, learningVec(end), trans, emis, delta, closing);
    
    % Slumpa fram dolda tillstand
    %hidden = randi(2,length(hidden),1);
    
    buy = data(first(dataset):last(dataset)-1,6);
    sell = data(first(dataset)+1:last(dataset),3);
    %buy = opening;
    %sell = closing;
    
    % Calculate the return
    [endCapital, indexCapital, returnHMM, returnIndex, priceChange] = getEndingCapital(capital, buy, sell, learningVec(end), hidden);
    
    %---------------------------- Validation ---------------------------------%
    
    days = learningVec(end)+1:length(moveToday);
    movementProg = price-closing(learningVec(end)+1:end)';
    
    % correctProg = ((hidden(1:end-1)==4 | hidden(1:end-1)==5) + ...
    %     (states(startLearning+lengthLearningData:end)== 4 | states(startLearning+lengthLearningData:end)==5) == 2)...
    %     + ((hidden(1:end-1)==3) + (states(startLearning+lengthLearningData:end) == 3) == 2)...
    %     + ((hidden(1:end-1)==1 | hidden(1:end-1)==2) + ...
    %     (states(startLearning+lengthLearningData:end)== 1 | states(startLearning+lengthLearningData:end)==2) == 2);
    
    correctProg = (hidden(1:end-1)==states(startLearning+lengthLearningData:end));
    wrongProg = correctProg - 1;
    
    correct = sum(correctProg);
    wrong = -sum(wrongProg);
    
    % MSE
    err = immse(movementProg(1:end-1),moveToday(learningVec(end)+2:end)');
    
    ratio(dataset) = correct/(correct+wrong)*100;
    
    pValueRatio(dataset) = 1-binocdf(correct,wrong+correct,0.5);
    SharpeRatio(dataset) = getSharpe(returnHMM(2:end), returnIndex(2:end));
    pValueReturn(dataset) = 1-tcdf(SharpeRatio(dataset)*sqrt(length(returnHMM)),length(returnHMM)-1);
    absReturn(dataset) = (endCapital(end)/indexCapital(end))-1;
    avgReturn(dataset) = (mean(endCapital)/mean(indexCapital))-1;
    
end

disp(['Data set',' ','Ratio [%]',' ','p-value',' ','Abs Return', ' ','Avg Return',' ','SharpeRatio',' ','p-value'])
A = [(1:20)' ratio pValueRatio absReturn*100 avgReturn*100 SharpeRatio*100 pValueReturn];
disp(A)

%%
%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
% figure(1);
% clf
% subplot(1,1,1)
% plot(1:length(closing), closing','b-', days+1, price,'r-');
% set(gca,'TickLabelInterpreter','latex','fontsize',18)
% xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
% ylabel('Price [SEK]','Interpreter','latex', 'fontsize', 18);
% h_legend = legend('Actual closing price','Predicted closing price');
% set(h_legend,'Interpreter','latex', 'fontsize', 18);
% title('Prediction with static learning model','Interpreter','latex', 'fontsize', 20);
% xlim([1 length(closing)])
% 
% figure(2)
% subplot(1,1,1)
% plot(days+1,cumsum(movementProg)+opening(days(1)),'b',1:length(closing),closing,'r')
% set(gca,'TickLabelInterpreter','latex','fontsize',18)
% xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
% ylabel('Price [SEK]','Interpreter','latex', 'fontsize', 18);
% h_legend = legend('Cumulated movement','Actual closing price');
% set(h_legend,'Interpreter','latex', 'fontsize', 18);
% title('Cumulated movement in price','Interpreter','latex', 'fontsize', 20);
% xlim([1 length(closing)])

figure(3)
subplot(1,1,1)
plot(days, endCapital,'b',days, indexCapital,'r', [1 days(end)], [capital capital],'k')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('Capital [SEK]','Interpreter','latex', 'fontsize', 18);
h_legend = legend('Change in capital with HMM','Index movement');
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Change in capital','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])

figure(4)
subplot(1,1,1)
plot(days(1:end-1), cumsum(correctProg+wrongProg),'b', [1 days(end)], [0 0],'k')
set(gca,'TickLabelInterpreter','latex','fontsize',18)
xlabel('Trading day','Interpreter','latex', 'fontsize', 18);
ylabel('[-]','Interpreter','latex', 'fontsize', 18);
set(h_legend,'Interpreter','latex', 'fontsize', 18);
title('Cumulated correct and wrong number of predictions','Interpreter','latex', 'fontsize', 20);
xlim([1 length(closing)])


%%

%----------------------- Evalutaion of algorithm -------------------------%

disp(['Corr/wrong',' ','CapitalHMM',' ','CapitalIndex',' ','RetHMM',' ','RetIndex','   ', 'PredState', '   ' ,'ActState'])
disp([(correctProg+wrongProg) endCapital(2:end) indexCapital(2:end) returnHMM(2:end) returnIndex(2:end) hidden(1:end-1) states(learningVec(end)+1:end) moveToday(learningVec(end)+2:end)  priceChange(2:end)])

%%
SharpeRatio = sharpe(returnHMM(2:end), returnIndex(2:end));
SharpeRatio*100

N = length(returnHMM(2:end));
tstat = SharpeRatio * sqrt(N)
pValue = tcdf(tstat, N-1)

%hypothesisTest(returnHMM, returnIndex)

%%
upDown = hidden;
upDown((upDown==3)) = [];
upDown((upDown==1)|(upDown==2)) = 0;
upDown((upDown==4)|(upDown==5)) = 1;


%%
%---------------------------- PLOTS --------------------------------------%

% Plot the true and forecasted price
figure(1)
subplot(2,1,1)
plot(1:length(states), states,'b-', days, hidden,'r-');
legend('Actual states','Likely states');
xlabel('Day');
title('Prediction for the next day')

subplot(2,1,2)
plot(1:length(closing), closing','b-', days+1, price,'r-');
legend('Actual closing price','Predicted closing price');
xlabel('Day');

figure(2)
subplot(3,1,1)
hist(seq)
title('Histogram of observations');
subplot(3,1,2)
hist(states);
title('Histogram of hidden states')
subplot(3,1,3)
hist(hidden);
title('Predicted hidden states')

figure(3)
plot(days+1,movementProg,1:length(moveToday), moveToday')
legend('Predicted movement','Actual movement')

figure(4)
subplot(3,1,1)
plot(days+1,cumsum(movementProg)+opening(days(1)),1:length(closing),closing)
legend('Cumulated movement','Closing price')
title('Price of asset')

subplot(3,1,2)
plot(days, endCapital, [1 days(end)], [capital capital])
title('Capital')

subplot(3,1,3)
plot(days(1:end-1), cumsum(correctProg+wrongProg), [1 days(end)], [0 0])
title('Cumulations of correct and wrong number of predictions')


