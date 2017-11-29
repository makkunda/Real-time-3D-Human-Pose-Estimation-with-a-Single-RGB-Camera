function [ frame1 ] = DrawLine1( colorframe,pred_2dpos,k1,k2 )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%for i =1:size(pred_2d,2)
frame1 = insertShape(colorframe,'line',[pred_2dpos(1,k1) pred_2dpos(2,k1) pred_2dpos(1,k2) pred_2dpos(2,k2)],'LineWidth',5);

end