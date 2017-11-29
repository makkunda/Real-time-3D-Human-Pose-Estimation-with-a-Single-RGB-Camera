function [ error1 ] = proj( new_pos,old_2Dpos )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    FocalLength=567;
    new_2Dpos(1,:)=FocalLength*new_pos(1,:)/new_pos(3,:);
    new_2Dpos(2,:)=FocalLength*new_pos(2,:)/new_pos(3,:);
    error_x=(new_2Dpos(1,:)-old_2Dpos(1,:)).^2;
    error_y=(new_2Dpos(2,:)-old_2Dpos(2,:)).^2;
    error=error_x+error_y;
    error1=sum(error);
end

