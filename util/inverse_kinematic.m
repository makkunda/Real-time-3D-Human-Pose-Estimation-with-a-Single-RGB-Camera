function[error1]=inverse_kinematic(new_pos,old_pos,d)
    a=new_pos(1,:)-old_pos(1,:);
    error_x =(a-d(1)).^2;
    error_y =(new_pos(2,:)-old_pos(2,:)-d(2)).^2;
    error_z=(new_pos(3,:)-old_pos(3,:)-d(3)).^2;
    error=error_x+error_y+error_z;
    error1=sum(error);
end
    
    
