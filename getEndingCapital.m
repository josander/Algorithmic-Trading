function [ endCapital ] = getEndingCapital( startCapital, opening, closing, learningEnd, hidden )

capital = startCapital;
endCapital = zeros(length(hidden),1);
endCapital(1) = startCapital;

for i = 1:length(hidden)-1
    
    % What position should be taken?
    switch hidden(i)
        
        case 1 % Negative predicted movement -> take short position
            
            dailyReturn = -(closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            
        case 2 % Negative predicted movement -> take short position
            
            dailyReturn = -(closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            
        case 3 % Predicted movement equals zero -> Do nothing
            
            endCapital(i+1) = capital;
            
        case 4 % Positive predicted movement -> take long position
            
            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            
        case 5 % Positive predicted movement -> take long position
            
            dailyReturn = (closing(learningEnd+1+i) - opening(learningEnd+1+i))/opening(learningEnd+1+i);
            capital = (dailyReturn + 1) * capital;
            endCapital(i+1) = capital;
            
    end
    
end

end

