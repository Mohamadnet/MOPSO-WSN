function [UpdatedRep, UpdatedDominatedList, UpdatedRepRanking] = RepUpdate (GlobalRep, CurNonDominatedList, ObjNum, xRank, CurFitness,RepLimit)
    % Input: 
    %   1. Rep: A repository containing nondominated particles so far,
    %       used to find the Global guide. 
    %   2. CurNonDominatedList: The list of nondominated particles found during
    %       the current iteration. 
    %   3. RepSize: The maximum size of the Repository. 
    
    % Output: 
    %   1. UpdatedRep: The updated repository. 
    %   2. UpdatedRepRanking: Shows the rank of each entry in the repository based on
    %       the number of particles that are dominated by that specific
    %       entry of the repository. The more the dominated particles are, the
    %       less is the rank of entry. 
    
    % Note: The members of CurNonDominatedList to be added to the
    %       repository should not be also dominated by the previous members of the
    %       repository, and vice versa. 
    
    % To merge both GlobalRep and CurNonDominatedList in one datastructure
    % named Temp 

    GlobalRepSize = size (GlobalRep);
    CurNDLSize = size (CurNonDominatedList);
    
    Temp = GlobalRep;
    Temp (GlobalRepSize(1)+1 : GlobalRepSize(1)+CurNDLSize(1), :) = CurNonDominatedList(:,:);
    
    % Updating Temp to include just nondominated particles by calling the
    % CheckNonDominated function in the binary search mode. 
    TempSize = size (Temp);
    RepCounter = 0;
    
    % In the following loop we are going to (1) add the members of
    % CurNonDominatedList which are nondominated on Current Fitness, to the
    % Repository; however, to do that we need to check whether these
    % hypercubes are nondominated among the other members of
    % CurNonDominatedList or not. (2) After addining the final Nondominated
    % particles to the Repository we should caculate which particles in
    % Current Fitness are dominated by these Hypercubes. That's why we
    % recall the CheckNonDominated function twice. In the first recall 
    % we determine whether the given particle is
    % dominated by other memebrs of the CurNonDominatedList, and in the
    % second recall we invoke the CheckNonDominated function along with the
    % Current Fitness matrix to determine which particles in the current
    % fitness have been dominated by the members of Global Repository. 
    UpdatedRep = [];
    for ii=1: TempSize(1)        
        
        if (TempSize (1) > 1) % If Temp repository contains more than one enry. 
            if (ii==1)
                [Flag2, NumOfDominated2, DominatedIndexes2] = CheckNonDominated (Temp(ii,:), Temp (ii+1:TempSize (1),:), ObjNum);
                Flag1=1;
                NumOfDominated1=0;
                DominatedIndexes1=[];
            elseif (ii==TempSize(1))
                [Flag1, NumOfDominated1, DominatedIndexes1] = CheckNonDominated (Temp(ii,:), Temp (1:ii-1,:), ObjNum);
                Flag2=1;
                NumOfDominated2=0;
                DominatedIndexes2=[];
            else
                [Flag1, NumOfDominated1, DominatedIndexes1] = CheckNonDominated (Temp(ii,:), Temp (1:ii-1,:), ObjNum);
                [Flag2, NumOfDominated2, DominatedIndexes2] = CheckNonDominated (Temp(ii,:), Temp (ii+1:TempSize (1),:), ObjNum);
            end
                
        elseif (TempSize (1) <= 1) % If Temp repository contains only one enry.
            Flag1=1;
            Flag2=1;
            
            NumOfDominated1=0;
            NumOfDominated2=0;
            
            DominatedIndexes1=[];            
            DominatedIndexes2=[];
        end
        %NumOfDominated1
        %NumOfDominated2
        %TempSize
        if (Flag1+Flag2==2 && (NumOfDominated1 + NumOfDominated2) > 0)
                RepCounter=RepCounter+1;
                UpdatedRep(RepCounter,:)= Temp(ii,:);                
        end       
    end
    
    %Second calling of the CheckNonDominated function to determine which
    %particles in current fitness have been dominated by the memebers of
    %the Global Repository. 
    UpdatedRepSize = size (UpdatedRep);
    if (UpdatedRepSize(1) == 0)
        display('The Global Repository is empty');
        UpdatedDominatedList (ii).Index=[];
        UpdatedRepRanking (ii) = 0;
    else
        for ii=1: UpdatedRepSize(1)
            [Flag, NumOfDominated, DominatedIndexes] = CheckNonDominated (UpdatedRep(ii,:), CurFitness, ObjNum);
            UpdatedDominatedList (ii).Index= DominatedIndexes;

            if ((NumOfDominated) ==0)
                  UpdatedRepRanking (ii) = 0;
            else
                  IndexesSize=size(DominatedIndexes);
                  
                for jj=1:IndexesSize(2)                                      %%Q%%%%%%%%%%%%%%% NEW CHHHHHHHHHHHHHAnge
                    tempFitness(jj,:)=CurFitness(DominatedIndexes(jj),:);
                end
                sumCurfitness=sum(sum(tempFitness));
               % UpdatedRepRanking (i) =
               % xRank/abs(NumOfDominated-yRankConstant*sumCurfitness);
               % Contain FITNESS of the dominated
             
               %UpdatedRepRanking (ii) = xRank/abs(NumOfDominated-yRankConstant*sumCurfitness);
               UpdatedRepRanking (ii) = xRank/abs(NumOfDominated);
               
       
            end                
        end

    end
    if (UpdatedRepSize(1)>RepLimit)              %Limitation Operator
        TempUnsortedRep(:,1)=UpdatedRepRanking;
        TempUnsortedRep(:,2:(ObjNum+1))=UpdatedRep;
        TempUnsortedRep(:,ObjNum+2)=1:UpdatedRepSize(1);
        TempsortedRep=sortrows(TempUnsortedRep,2);
        TempsortedRepSize=size(TempsortedRep);
        UpdatedRep=TempsortedRep((TempsortedRepSize(1)-RepLimit):TempsortedRepSize(1),2:(ObjNum+1));
        d=TempsortedRep((TempsortedRepSize(1)-RepLimit):TempsortedRepSize(1),ObjNum+2);
        UpdatedDominatedList=UpdatedDominatedList (d);
        UpdatedRepRanking=UpdatedRepRanking(d);
    end
end