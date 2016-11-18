function [OutputParticleAC OutputParticleVal OutputFitness OutputRepSize Energy] = PSO (iteration,X,Y,E,sink,sender,xRank,RepLimit,PopNum,C1,Weight,ETX,EDA,Emp,NodeNum,PlotSize,ObjNum,do,VelocityLimit,R,Efs,MutualDominance,SenderIndex,MobilityRate) 


VelocityAC = zeros(PopNum,NodeNum);
VelocityVal = zeros(PopNum,NodeNum);
  %initial randomly
Val =(-R/2)+((rand(PopNum,NodeNum))*R);
AC=(-R/2)+((rand(PopNum,NodeNum))*R);   %existence of node in the path
CurFitness = -inf*ones(PopNum,ObjNum);

%Those particles that hit the best fitness so far should be saved
%as the local best particle along with the best local best fitness
LBestAC  = zeros(PopNum,NodeNum);
LBestVal = zeros(PopNum,NodeNum);
LBest = -inf*ones(PopNum,ObjNum);

% The best particle among the local best particles in each iteration is
% saved as the current Global Best particle. 
GlobalRep = [];
GBest = -inf*ones(1,ObjNum);

GBestAC  = AC (ceil(PopNum*rand()),:);
I=ceil(PopNum*rand());
GBestVal = Val(I,:);
for itrn=1:iteration
    [next.x next.y]=NodeMovement(sink.x,sink.y,PlotSize,PlotSize,MobilityRate);
    [CurFitness tempEnergy] = MultObjFitness (AC, Val,X,Y,R,E,next,sender,ETX,EDA,Emp,PlotSize,do,Efs,1,SenderIndex);
    DominanceStatus = LocalDominanceTest (CurFitness, LBest, ObjNum);
    % DominanceStatus is an array which for each of particles keeps 1 if CurFitness domiates LBest; 
    %   -1 if LBest domiates CurFitness; and 0 if CurFitness and LBest will
    %   be mutully non-dominated
    for ii  = 1 : PopNum
        if (DominanceStatus(ii)==1) 
            LBest (ii,:) = CurFitness(ii,:);
            LBestAC (ii,:) = AC(ii,:);
            LBestVal(ii,:) = Val(ii,:);
%         elseif (DominanceStatus(ii)==0)%In this state we choose randomly among CurFitness and LBest 
%             flag = round (rand());
%             if (flag == 1)
%                 LBest (ii,:) = CurFitness(ii,:);
%                 LBestAC (ii,:) = AC(ii,:);
%                 LBestVal(ii,:) = Val(ii,:);
%             end            
         end        
    end
    
%Finding the nondominated particles among the current population
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Calculation of the Nondominated particles on Current fitness array
    
    % Updating Temp to include just nondominated particles by calling the
    % CheckNonDominated function in the binary search mode. 

    NDCounter = 0;
    for ii=1: PopNum% Population size
        
        if (ii==1)
            [Flag2, NumOfDominated2, DominatedIndexes2] = CheckNonDominated (CurFitness(ii,:), CurFitness (ii+1:PopNum,:), ObjNum);
            Flag1=1;  %no dominated in the first part
            NumOfDominated1=0;
            DominatedIndexes1=[];
        elseif (ii==PopNum)
            [Flag1, NumOfDominated1, DominatedIndexes1] = CheckNonDominated (CurFitness(ii,:), CurFitness (1:ii-1,:), ObjNum);
            Flag2=1;  % no dominated in the second part
            NumOfDominated2=0;
            DominatedIndexes2=[];
        else
            [Flag1, NumOfDominated1, DominatedIndexes1] = CheckNonDominated (CurFitness(ii,:), CurFitness (1:ii-1,:), ObjNum);
            [Flag2, NumOfDominated2, DominatedIndexes2] = CheckNonDominated (CurFitness(ii,:), CurFitness (ii+1:PopNum,:), ObjNum);
        end
        
        if (Flag1+Flag2==2 && (NumOfDominated1 + NumOfDominated2)~=0)
            NDCounter=NDCounter+1;
            CurNonDominatedList(NDCounter,:)= CurFitness(ii,:);            
        end        
    end
%%%%%%%%%%%%%%%%%
    % To update the nondominated repository 
    [GlobalRep, UpdatedDominatedList, UpdatedRepRanking]=RepUpdate (GlobalRep, CurNonDominatedList, ObjNum, xRank, CurFitness,RepLimit);
    GlobalRepSize = size (GlobalRep);
    
    %Rollete wheel
    if (GlobalRepSize(1)>1)% if there is more than one particle in the repository to choose
        NDRaningSum = sum (UpdatedRepRanking);
        Wheel = UpdatedRepRanking/NDRaningSum;
    
        counter = ceil(rand() * GlobalRepSize(1));
        ChosenHyperCube = 0;
        while (ChosenHyperCube == 0)
            Position=mod(counter,GlobalRepSize(1))+1;
            if (Wheel (Position) > rand())
                ChosenHyperCube = Position;            
            end
            counter=counter+1;            %%!!!!!!!!!!!!!!!!!!!!!!!!!!!!WARNING it was added .NEW
        end
        
    elseif(GlobalRepSize(1)==1)% if there is only one particle in the repository to choose
        ChosenHyperCube=1;
    elseif(GlobalRepSize(1)==0)
        ChosenHyperCube=0;
    end
    if (ChosenHyperCube > 0)
        HypSize= numel (UpdatedDominatedList(ChosenHyperCube).Index);
        Position = ceil(rand() * HypSize); 
        I = UpdatedDominatedList(ChosenHyperCube).Index(Position);
    else
        %I=ceil(rand() * PopNum); 
        [maxVal I]=max(sum(CurFitness,2));
    end
    if (LocalDominanceTest (CurFitness(I,:), GBest, ObjNum)==1)
        GBest = CurFitness(I,:); %?????????? Current or LocalBest??????
        GBestAC  = AC (I,:);  %%????????????????????????????/Current or local best is a serious question
        GBestVal = Val(I,:);      
    elseif (LocalDominanceTest (CurFitness(I,:), GBest, ObjNum)==0 && MutualDominance==1) %%% DDDDDDDDDDDGGGGGGGGGGGGGGGGGG
        tempSelect=round(rand());
        if(tempSelect==1)
            GBest = CurFitness(I,:); %?????????? Current or LocalBest??????
            GBestAC  = AC (I,:);  %%????????????????????????????/Current or local best is a serious question
            GBestVal = Val(I,:); 
        end
    end
    if (GBestVal(1)>0)
        MutualDominance=2; % ????????????????????????
    end
    for ii = 1: PopNum
        [AC(ii, :) VelocityAC(ii,:)] = Update (AC(ii, :), VelocityAC(ii,:), LBestAC(ii,:), GBestAC, R, Weight, C1, C1,VelocityLimit,1,E);        
        [Val(ii, :) VelocityVal(ii,:)] = Update (Val(ii, :), VelocityVal(ii,:), LBestVal(ii,:), GBestVal, R, Weight, C1, C1,VelocityLimit,2,E);
    end
   
    OutputParticleAC (itrn,:) = GBestAC;
    OutputParticleVal (itrn,:) = GBestVal;
    OutputFitness(itrn,:) = GBest;
    OutputRepSize(itrn,:) = GlobalRepSize(1);
    
    %%%%%%%%%%%%%%CONCERGENCE CHECK
    
%     if (itrn>100 && sum(OutputFitness(itrn,:)-OutputFitness(itrn-20,:))<alpha)
%         AC = rand(PopNum,DatasetSize(2))*R-(R/2);
%         for ii=1:DatasetSize(2)% Number of attributes
%             % Random selection of the intervals for particles. 
%             PopPermut=[];
%             for jj=1:ceil(PopNum/PermutaionNum)
%                 PopPermut= [PopPermut randperm(PermutaionNum)];
%             end
% 
%             Val (:,2*ii-1)=(-R/2)+(PopPermut-1)*IntervalSize;%Lower Bound Initialization
%             Val (:,2*ii)=(-R/2)+(PopPermut)*IntervalSize-0.0001;%Upper Bound Initialization    
%         end
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

[CurFitness Energy] = MultObjFitness (GBestAC, GBestVal,X,Y,R,E,next,sender,ETX,EDA,Emp,PlotSize,do,Efs,2,SenderIndex);
end