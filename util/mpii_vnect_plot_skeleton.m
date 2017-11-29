function [] = mpii_vnect_plot_skeleton(joint_loc, parent_vec, thickness)
    %figure();
    %thickness = 30;
    %fig = gca;
    %hold on;
    for i = 1:length(parent_vec)
        [X Y Z] = cylinder2P(thickness, 12, joint_loc(i,:), joint_loc(parent_vec(i),:));
        h = surf(X,Y,Z, repmat(i/length(parent_vec), size(X)));
        set(h,'edgecolor', 'none');
    end
    colormap('hsv');
    material dull;
    lightangle(45, -30);
    %light('Position',[0 1 0],'Style','infinite')
    %light('Position',[0 0 1],'Style','infinite')
    lighting gouraud;
    %hold off;