function [ seq ] = getObservations( movementToday, closing, delta)
% From a movement vector, a sequence of observations will be returned. 

%%%%%%%%%%%%%%%%%%%%%%%%%%% UNIVARIATE 5 STATES %%%%%%%%%%%%%%%%%%%%%%%%%%%
% seq(movementToday < -5*delta) = 1;
% seq(movementToday >= -5*delta & movementToday < -3*delta) = 2;
% seq(movementToday >= -3*delta & movementToday < -delta) = 3;
% seq(movementToday >= -delta & movementToday < delta) = 4;
% seq(movementToday >= delta & movementToday < 3*delta) = 5;
% seq(movementToday >= 3*delta & movementToday < 5*delta) = 6;
% seq(movementToday >= 5*delta) = 7;

%%%%%%%%%%%%%%%%%%%%%%%%%%% UNIVARIATE 3 STATES %%%%%%%%%%%%%%%%%%%%%%%%%%%
% seq(movementToday < 0) = 1;
% seq(movementToday == 0) = 2;
% seq(movementToday > 0) = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%% MULTIVARIATE MODEL %%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get moving average
movAver = tsmovavg(closing,'s',10,1);

% Difference in closing price and 10-value moving average
meanDisplacement = zeros(size(closing));
meanDisplacement(2:end) = closing(2:end) - movAver(1:end-1);
meanRev(meanDisplacement > delta) = 1;
meanRev(meanDisplacement <= delta & meanDisplacement >= -delta) = 2;
meanRev(meanDisplacement < -delta) = 3;

mov(movementToday>delta) = 1;
mov(movementToday<= delta & movementToday >= -delta) = 2;
mov(movementToday<-delta) = 3;

% Create 3 observable states: [Rise, Constant, Drop]
seq = zeros(size(movementToday));
seq(mov == 1 & meanRev == 1) = 1;
seq(mov == 1 & meanRev == 2) = 2;
seq(mov == 1 & meanRev == 3) = 3;
seq(mov == 2 & meanRev == 1) = 4;
seq(mov == 2 & meanRev == 2) = 5;
seq(mov == 2 & meanRev == 3) = 6;
seq(mov == 3 & meanRev == 1) = 7;
seq(mov == 3 & meanRev == 2) = 8;
seq(mov == 3 & meanRev == 3) = 9;

end

