function [Results Energy] = MultObjFitness (AC, Val,X,Y,R,E,sink,sender,ETX,EDA,Emp,PlotSize,do,Efs,select,SenderIndex)
    % This function caculates various objectives of the problem, Result, including
    % 1. Objective 1 = Energy
    % 2. Objective 2 = Delay      all objectives are maximization
    ValSize=size(Val);
    row=1:ValSize(2);
    PresenceX = AC >=0 ;
    Steps=0;
    if (select==2)
        ValSize(1)=1;
    end

    for ii=1:ValSize(1)
        %[item I]=find(PresenceX(ii,:));
        [sorted SortIndex]=sort(Val(ii,:));
	    [sorted order]=sort(SortIndex);  %rank find
        PriorityX=X([SenderIndex find(order.*PresenceX(ii,:))]);
        PriorityY=Y([SenderIndex find(order.*PresenceX(ii,:))]);
        PriorityEnergy=[SenderIndex find(order.*PresenceX(ii,:))];
        PresenceSize=size(PriorityX);
        Steps(ii)=PresenceSize(2)+1;
        Energy(ii,:)=E;
%         distance=sqrt( (sender.x-PriorityX(1) )^2 + (sender.y-PriorityY(1))^2) ;
%         if (distance>do)
%             Energy(ii,SenderIndex)=E(SenderIndex)- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
%         elseif (distance<=do)
%             Energy(ii,SenderIndex)=E(SenderIndex)- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance ));
%         end
        for jj=1:PresenceSize(2)-1
            distance=sqrt( (PriorityX(jj)-PriorityX(jj+1) )^2 + (PriorityY(jj)-PriorityY(jj+1))^2) ;
            if (distance>do)
                Energy(ii,PriorityEnergy(jj))=E(PriorityEnergy(jj))- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance ));
            elseif (distance<=do)
                Energy(ii,PriorityEnergy(jj))=E(PriorityEnergy(jj))- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance ));
            end
        end
        distance=sqrt( (sink.x-PriorityX(PresenceSize(2)) )^2 + (sink.y-PriorityY(PresenceSize(2)))^2) ;
        if (distance>do)
            Energy(ii,PriorityEnergy(PresenceSize(2)))=E(PriorityEnergy(PresenceSize(2)))- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
        elseif (distance<=do)
            Energy(ii,PriorityEnergy(PresenceSize(2)))=E(PriorityEnergy(PresenceSize(2)))- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance ));
        end
    end
    Energysum=sum(Energy,2);
    delay=-(Steps);
    Results(:,1)=Energysum;
    Results(:,2)=delay;
    
end