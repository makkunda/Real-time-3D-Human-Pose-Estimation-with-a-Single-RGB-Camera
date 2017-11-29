function [pad_img] = mpii_vnect_pad_image(img, final_2d_size)
    image_size = size(img);
    pad_img = padarray(img, ceil((final_2d_size - image_size(1:2))/2), 'both');
    pad_img = pad_img(1:final_2d_size(1), 1:final_2d_size(2), :);
end