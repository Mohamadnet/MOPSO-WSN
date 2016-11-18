function [Flag, NumOfDominated, DominatedIndexes] = CheckNonDominated (FitnessPrcle,PopFitness, ObjNum)
% This function receives a particle's multi-objective fitness, FitnessPrcle, along with
% the fitness array of a population, PopFitness, and checks whether the
% FitnessPrcle is a nondominated particle in the population or not. If yes,
% then Number of Dominated particles, NumOfDominated, plus their indexes,
% DominatedIndexes, is returned. 
% Is there any particle in PopFitness that dominates the FitnessPrcle? This
% is the question that this function answers to. 

    NumOfDominated = 0;
    DominatedIndexes=[];
    PopSize = size (PopFitness);
    
    Temp = zeros (size (PopFitness));
    for ii = 1 : ObjNum
        Temp (:,ii) = FitnessPrcle (ii);
    end
    
    NonDominatedFlag = LocalDominanceTest (PopFitness, Temp, ObjNum);
    
    s = sum (NonDominatedFlag == 1); % if there is no particle that dominates the FitnessPrcle then it is a non-dominated particle
    if (s == 0)
        Flag = 1; % The Input Particle is a nondominated particle
    else
        Flag = 0; % The Input Particle is not a nondominated particle
    end
    
    % Determination of the number and indexes of Doinated particles
        
    if (Flag==1)
        for ii = 1 : PopSize (1)
            if (NonDominatedFlag(ii) == -1)
                NumOfDominated = NumOfDominated+1;
                DominatedIndexes = [DominatedIndexes ii];                
            end
        end
        
    end   
end