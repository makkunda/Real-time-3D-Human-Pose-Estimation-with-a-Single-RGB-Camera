function [joint_idx, joint_parents_o1, joint_parents_o2, joint_names] = mpii_vnect_get_joints(joint_set_name)

    original_joint_idx = [10, 13, 16, 19, 22, 25, 28, 29, 31, 36, 40, 42, 43, 45, 50, 54, 56, 57,  63, 64, 69, 70, 71, 77, 78, 83, 84, 85];              %                            
        
    original_joint_names = {'spine3', 'spine4', 'spine2', 'spine1', 'spine', ...     %5       
                        'neck', 'head', 'head_top', 'left_shoulder', 'left_arm', 'left_forearm', ... %11
                       'left_hand', 'left_hand_ee',  'right_shoulder', 'right_arm', 'right_forearm', 'right_hand', ... %17
                       'right_hand_ee', 'left_leg_up', 'left_leg', 'left_foot', 'left_toe', 'left_ee', ...        %23   
                       'right_leg_up' , 'right_leg', 'right_foot', 'right_toe', 'right_ee'};  
                   
                   
    all_joint_names = {'spine3', 'spine4', 'spine2', 'spine', 'pelvis', ...     %5       
        'neck', 'head', 'head_top', 'left_clavicle', 'left_shoulder', 'left_elbow', ... %11
       'left_wrist', 'left_hand',  'right_clavicle', 'right_shoulder', 'right_elbow', 'right_wrist', ... %17
       'right_hand', 'left_hip', 'left_knee', 'left_ankle', 'left_foot', 'left_toe', ...        %23   
       'right_hip' , 'right_knee', 'right_ankle', 'right_foot', 'right_toe'}; 
   
   
  %The O1 and O2 indices are relaive to the joint_idx, regardless of the joint set 
                   
switch joint_set_name
    case 'extended' %Human3.6m joints in CPM order + End effectors for Hands and Feet
        %joint_idx = [8, 6, 15, 16, 17, 10, 11, 12, 24, 25, 26, 19, 20, 21, 5, 4, 7, 18, 13, 27, 22];
        joint_idx = [8, 6, 15, 16, 17, 10, 11, 12, 24, 25, 26, 19, 20, 21, 5, 4, 7, 18, 13, 28, 23];
        joint_parents_o1 = [ 2, 16, 2, 3, 4, 2, 6, 7, 15, 9, 10, 15, 12, 13, 15, 15, 2, 5, 8, 11, 14];
        joint_parents_o2 = [ 16, 15, 16, 2, 3, 16, 2, 6, 16, 15, 9, 16, 15, 12, 15, 15, 16, 4, 7, 10, 13];
        joint_names = all_joint_names(joint_idx);
             
    otherwise
end
end