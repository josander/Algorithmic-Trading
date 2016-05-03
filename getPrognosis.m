function [prognosis, likelyHidden] = getPrognosis(seq, endLearning, trans, emis, delta, closing)
% This function will generate a prognosis of a time series. 

% Length of prognosis
lengthProg = length(seq)-endLearning;

likelyHidden = zeros(lengthProg,1);

for nextDay = 1:lengthProg
    
    % Get new observation
    seqNew = seq(endLearning+nextDay);

    % Use Viterbi to estimate most probable state sequence
    likelyHidden(nextDay) = hmmviterbi(seqNew, trans, emis);
  
end

prognosis = getPrice(likelyHidden, delta, closing, endLearning);

end
