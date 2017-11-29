function [ sum_er ] = TotalError( to_optimise,current_pos,current_2Dpos,old_pos,old_vel )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    new_pos=to_optimise(:,1:21);
    d=to_optimise(:,22);
    error1=inverse_kinematic(new_pos,current_pos,d);
    error2=proj(new_pos,current_2Dpos);
    error3=temp_acc(new_pos,old_pos,old_vel);
    error4=temp_vel(new_pos,old_pos);
    sum_er=error1+(44*error2)+(0.07*error3)+(0.11*error4);
    
end

