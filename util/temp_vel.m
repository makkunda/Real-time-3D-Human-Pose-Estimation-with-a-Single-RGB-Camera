function [ error1 ] = temp_vel( new_pos,old_pos )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    new_vel_z=new_pos(2,:)-old_pos(2,:);
    error=(new_vel_z).^2;
    error1=sum(error);
end

