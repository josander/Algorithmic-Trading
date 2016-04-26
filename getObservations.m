function [ seq ] = getObservations( movement, lengthObs, delta)
% From a movement vector, a sequence of observations will be returned. 

% Create observable sequence
seq = zeros(lengthObs, 1);
seq(movement(1:lengthObs) < -3*delta) = 1;
seq(movement(1:lengthObs) >= -3*delta & movement(1:lengthObs) < -delta) = 2;
seq(movement(1:lengthObs) >= -delta & movement(1:lengthObs) < delta) = 3;
seq(movement(1:lengthObs) >= delta & movement(1:lengthObs) < 3*delta) = 4;
seq(movement(1:lengthObs) >= 3*delta ) = 5;

end

