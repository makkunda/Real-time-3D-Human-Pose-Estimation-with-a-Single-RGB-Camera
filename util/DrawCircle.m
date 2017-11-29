function [ frame1 ] = DrawCircle( colorframe,pred_2dpos )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
frame1=colorframe;
for k =1:size(pred_2dpos,2)
    frame1 = insertShape(frame1,'Filledcircle',[pred_2dpos(1,k) pred_2dpos(2,k) 5]);

end

