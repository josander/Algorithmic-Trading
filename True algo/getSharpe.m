function sharpe = getSharpe(returnA, returnB)

    % Computes the daily Sharpe ratio of an asset (A) in relation to a
    % benchmarked asset (B).

    D = returnA-returnB;
    meanD = mean(D);
    sigma = std(D);
    sharpe = meanD/sigma;
    
end