function [prognosis] = getPrognosis(movement, lengthLearning, trans, emis, delta, open)
% This function will generate a prognosis of the next step in a time
% series. 

% Length of prognosis
lengthProg = length(movement)-lengthLearning-2;

likelyHidden = zeros(lengthProg,1);

for nextDay = 1:lengthProg
    
    % Get new movement and generate that sequence
    movementNew = movement(lengthLearning+2+nextDay);
    seqNew = zeros(size(movementNew));
    seqNew(movementNew<0) = 1;
    seqNew(movementNew==0) = 2;
    seqNew(movementNew>0) = 3;

    % Use Viterbi to estimate most probable state sequence
    likelyHidden(nextDay) = hmmviterbi(seqNew, trans, emis);
   

end

prognosis = getPrice(likelyHidden, delta, open, lengthLearning);

end
