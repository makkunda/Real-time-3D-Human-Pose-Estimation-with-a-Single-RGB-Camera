function [ error1 ] = temp_acc( new_pos,old_pos,old_vel )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    new_vel(1,:)=new_pos(1,:)-old_pos(1,:);
    new_vel(2,:)=new_pos(2,:)-old_pos(2,:);
    new_vel(3,:)=new_pos(3,:)-old_pos(3,:);
    error=(new_vel-old_vel).^2;
    error1=sum(error);
end
