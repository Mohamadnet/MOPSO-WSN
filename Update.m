function [NewX NewV] = Update (X, V, LBestP, GBestP, XBound, Weight, C1, C2, VelocityLimit,selectDead,Energy)
    
    ParticleSize = size (X);
    NewV = Weight * V + C1 * (rand (1,ParticleSize(2)).* (LBestP - X))+ C2 * (rand (1,ParticleSize(2)).* (GBestP - X));
    %NewV = Weight * V + (C1 * (LBestP - X))+ (C2 * (GBestP - X));
    NewV = max (NewV, -XBound/VelocityLimit);
    NewV = min (NewV, XBound/VelocityLimit);        
    NewX = X + NewV;

%     if (select==2 && repairMode==1)   %repairing interval values by random assignment   OPERATOR
%         tempFault=(NewX(2:2:end)-NewX(1:2:end))<=0;
%         NewX(2:2:end)=((tempFault==0).*NewX(2:2:end))+(tempFault.*(NewX(1:2:end)+(IntervalSize*rand(size(NewX(1:2:end))))));
%         
%     elseif (select==2 && repairMode==2)%repairing interval values by penalty
%         tempFault=(X(2:2:end)-X(1:2:end))<=0;
%     end
    NewX = max (NewX, -XBound/2);
    NewX = min (NewX, XBound/2); 
    if(selectDead==2)
        NewX=(Energy<=0 )*(-XBound/2) + ~(Energy<=0).*NewX;
    end
end