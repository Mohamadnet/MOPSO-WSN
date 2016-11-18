function [NextX NextY]=NodeMovement(PrevX,PrevY,DimensionX,DimensionY,Rate)
NextX=(PrevX)+(sign((rand()*2)-1)*rand()*Rate);
NextY=(PrevY)+(sign((rand()*2)-1)*rand()*Rate);

NextX=min(NextX,DimensionX);
NextY=min(NextY,DimensionY);
end