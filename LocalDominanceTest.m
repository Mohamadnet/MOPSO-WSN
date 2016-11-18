function [Result] = LocalDominanceTest (CurFitness, LBest, ObjNum)
        
    % Totally 5 conditions can heppen when comparing CurFitness and Lbest
    % (1) if CurFitness strictly dominate Lbest (denoted u<v, 
    %          if fi(u) >= fi(v) ?i =1,...,D and fi(u) > fi(v) for some i) 
    %     ---> result = 1
    % (2) if CurFitness weakly dominate Lbest  (denoted as u <=v, 
    %           if fi(u) >= fi(v) for all i)
    %     ---> result = 1
    % (3) if Lbest strictly dominate CurFitness ---> result = -1
    % (4) if Lbest weakly dominate CurFitness ---> result = -1
    % (5) if neither Lbest nor CurFitness can dominte each other (Mutual non-dominared)---> result = 0
  
    Temp = CurFitness >= LBest; 
    Result = (sum (Temp,2) == ObjNum);
    
    Temp = CurFitness <= LBest; 
    Result = (-1).*(sum (Temp,2) == ObjNum) + Result;
    
end