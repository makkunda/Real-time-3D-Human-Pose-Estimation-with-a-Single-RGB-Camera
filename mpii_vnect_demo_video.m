
CROP_TRACKING_MODE = false; 
IS_FIRST_FRAME = true;
%% Global Params
CROP_SIZE = 368; %384;
CROP_RECT = [0, 0, CROP_SIZE, CROP_SIZE];
hm_factor = 8;
VISUALIZE_HEATMAPS = true;
%Point to your matcaffe
addpath('/home/makkunda/caffe-rc5/matlab')
addpath('./util');
img_base_path = './data';
%Get the joint parents and the labels. The extended set also contains hand
%and feet tips which may not be as stable. Use the first 17 in that case.
[~,o1,~,relevant_labels] = mpii_vnect_get_joints('extended');  
%% Variables
CROP_SCALE = 1.0;
pad_offset(1:2) = 0;
% f1 = OneEuroFilter(30.0,1.7,0.3);
% f2 = OneEuroFilter(30.0,0.8,0.4);
% f3 = OneEuroFilter(30.0,20,0.4);
for i11 = 1:1:2
    for j11 = 1:1:21
        f1(i11,j11) = OneEuroFilter(60.0,1.7,0.3);
    end
end

for i11 = 1:1:3
    for j11 = 1:1:21
        f2(i11,j11) = OneEuroFilter(60.0,0.8,0.4);
    end
end

for i11 = 1:1:3
    for j11 = 1:1:21
        f3(i11,j11) = OneEuroFilter(60.0,20,0.4);
    end
end

%%
caffe.set_mode_gpu()
caffe.set_device(0)
caffe.reset_all();
net = caffe.Net('./models/vnect_net.prototxt', './models/vnect_model.caffemodel', 'test');
video_path = fullfile(img_base_path, sprintf('IMG_3881.MOV'));
v=VideoReader(video_path);
v1=VideoWriter('sid3.avi');
open(v1);
i12=130;
while (hasFrame(v))
	video=readFrame(v);
    %video=permute(video,[2,1,3]);
    % fprintf('#####')
    
    i12=i12+1;
    % if mod(i12-1,10)~=0
    %     continue
    % end
   
    img = permute(double(video)/255.0 - 0.4, [2,1,3]);
    img = img(:,:,[3 2 1]);
    img = imresize(img, [848, 448]);

    if(~CROP_TRACKING_MODE)
      scales = 1:-0.2:0.6;
      box_size = [size(img,1),size(img,2)];
      CROP_TRACKING_MODE = true;
    else
        scales = [1.0,0.7];
        box_size = [CROP_SIZE, CROP_SIZE];
        crop_offset = int32(floor(40.0 / CROP_SCALE)); 
        %Get 2D locations in the previous frame
        min_crop = (int32(CROP_RECT(1:2) + min(pred_2d, [], 2)'/CROP_SCALE) - int32(pad_offset/CROP_SCALE)) - crop_offset;
        max_crop = (int32(CROP_RECT(1:2) + max(pred_2d, [], 2)'/CROP_SCALE) - int32(pad_offset/CROP_SCALE)) + crop_offset;
        old_crop = CROP_RECT;

        CROP_RECT(1:2) = max(min_crop, int32([1, 1]));
        CROP_RECT(3:4) = min(max_crop, int32([size(img, 1), size(img,2)]));
        CROP_RECT(3:4) = CROP_RECT(3:4) - CROP_RECT(1:2);

        %Temporal smoothing of the crops
        if(~IS_FIRST_FRAME)
            mu = 0.8;
            CROP_RECT = (1-mu)* CROP_RECT + mu * old_crop;
            IS_FIRST_FRAME = false;
        end
        
        img = imcrop(img, CROP_RECT([2,1,4,3]));
        CROP_SCALE = (CROP_SIZE-2) / max(size(img, 1), size(img, 2));
        img = imresize(img, CROP_SCALE);

        if(size(img,1) > size(img,2))
            pad_offset(1) = 0;
            pad_offset(2) = (CROP_SIZE-size(img,2)) / 2;
        else
            pad_offset(2) = 0;
            pad_offset(1) = (CROP_SIZE-size(img,1)) / 2;
        end
        img = mpii_vnect_pad_image(img, box_size);

    end

    %Once we know the crop, get the image ready to be fed into the network
    data = zeros(box_size(1), box_size(2), 3, length(scales));
    for si = 1:length(scales)
      data(:,:,:,si) = mpii_vnect_pad_image(imresize(img, scales(si)), box_size);
    end

    net.blobs('data').reshape([size(data,1) size(data,2) size(data,3) size(data,4)]);
    net.forward({data(:,:,:,:)});

    %Get the heatmaps and the location maps from the network
    output_heatmap = net.blobs('heatmap').get_data();
    output_xmap = net.blobs('x_heatmap').get_data();
    output_ymap = net.blobs('y_heatmap').get_data();
    output_zmap = net.blobs('z_heatmap').get_data();

    %Housekeeping for the next step
    hm_size = box_size/hm_factor; %or size(output_heatmap); 1 and 2
    heatmap = zeros(hm_size(1), hm_size(2), size(output_heatmap,3));
    xmap = zeros(hm_size(1), hm_size(2), size(output_zmap,3));
    ymap = zeros(hm_size(1), hm_size(2), size(output_zmap,3));
    zmap = zeros(hm_size(1), hm_size(2), size(output_zmap,3));

    %Since the predicted heatmaps and location maps are at different
    %scales,they need to be rescaled and averaged
    for si = 1:length(scales)
      s_hm = imresize(output_heatmap(:,:,:,si), 1.0/scales(si), 'bilinear');
      s_xhm = imresize(output_xmap(:,:,:,si), 1.0/scales(si), 'bilinear');
      s_yhm = imresize(output_ymap(:,:,:,si), 1.0/scales(si), 'bilinear');
      s_zhm = imresize(output_zmap(:,:,:,si), 1.0/scales(si), 'bilinear');
      mid_pt = size(s_hm)/2;
      heatmap = heatmap + s_hm( (mid_pt(1) -floor(hm_size(1)/2)+1): (mid_pt(1) +ceil(hm_size(1)/2)), (mid_pt(2) -floor(hm_size(2)/2)+1): (mid_pt(2) +ceil(hm_size(2)/2)),:);
      xmap = xmap + s_xhm( (mid_pt(1) -floor(hm_size(1)/2)+1): (mid_pt(1) +ceil(hm_size(1)/2)), (mid_pt(2) -floor(hm_size(2)/2)+1): (mid_pt(2) +ceil(hm_size(2)/2)),:);
      ymap = ymap + s_yhm( (mid_pt(1) -floor(hm_size(1)/2)+1): (mid_pt(1) +ceil(hm_size(1)/2)), (mid_pt(2) -floor(hm_size(2)/2)+1): (mid_pt(2) +ceil(hm_size(2)/2)),:);
      zmap = zmap + s_zhm( (mid_pt(1) -floor(hm_size(1)/2)+1): (mid_pt(1) +ceil(hm_size(1)/2)), (mid_pt(2) -floor(hm_size(2)/2)+1): (mid_pt(2) +ceil(hm_size(2)/2)),:);
    end
    
    %Final heatmaps and location maps, from which we can infer the 2D and
    %3D pose
    heatmap = heatmap/length(scales);
    xmap = xmap/length(scales);
    ymap = ymap/length(scales);
    zmap = zmap/length(scales);


    if(i12>132)
        old_vel=pred_p-old_p;
    end
    if(i12>131)
        old_p=pred_p;
    end
    pred_p = zeros(3,size(heatmap,3));
    pred_2d = zeros(2, size(pred_p,2));

    hm = zeros(box_size(2), box_size(1), size(heatmap,3));
    % Take the maximas in the heatmaps as the 2D predictions. You can
    % substitue this with a function guided by the distance from the
    % root joint. Use the maxima locations to get the 3D joint locations
    for k = 1:size(heatmap,3)
        hm(:,:,k) = imresize(permute(heatmap(:,:,k),[2,1,3]), hm_factor);
        [~,max_idx] = max(reshape(hm(:,:,k),1,[]));
        [y,x] = ind2sub(size(hm(:,:,k)), max_idx(1));
        pred_2d(1:2,k) = [x,y];
    end
    for i11 = 1:1:2
        for j11 = 1:1:21
            [f1(i11,j11),pred_2d(i11,j11)] = f1(i11,j11).filter2(pred_2d(i11,j11),i12-130);
        end
    end
    %[f1,pred_2d] = f1.filter2(pred_2d,i-130);
    for k = 1:size(heatmap,3)
        x = pred_2d(1,k);
        y = pred_2d(2,k);
        pred_p(1,k) = 100* xmap(max(floor(x/hm_factor),1), max(floor(y/hm_factor),1) ,k);
        pred_p(2,k) = 100* ymap(max(floor(x/hm_factor),1), max(floor(y/hm_factor),1) ,k);
        pred_p(3,k) = 100* zmap(max(floor(x/hm_factor),1), max(floor(y/hm_factor),1) ,k);
    end
    %Subtract the root location just to be safe.
    pred_p = bsxfun(@minus, pred_p, pred_p(:,15));

    for i11 = 1:1:3
        for j11 = 1:1:21
            [f2(i11,j11),pred_p(i11,j11)] = f2(i11,j11).filter2(pred_p(i11,j11),i12-130);
        end
    end
    if(i12>132)
        fun=@(x)TotalError(x,pred_p,pred_2d,old_p,old_vel);
        x0(:,1:21)=pred_p;
        if(i12==133)
        	x0(:,22)=0;
        else
            x0(:,22)=d;
        end
        options.Algorithm='levenberg-marquardt';
        x=lsqnonlin(fun,x0,[],[],options);
        pred_p=x(:,1:21);
        d=x(:,22);
    end  %Plot the predicted Pose 
    for i11 = 1:1:3
        for j11 = 1:1:21
            [f3(i11,j11),pred_p(i11,j11)] = f3(i11,j11).filter2(pred_p(i11,j11),i12-130);
        end
    end   
  
    
    
    
    

  if(i12>133)
      video2=DrawCircle(permute(img(:,:,[3,2,1]), [2,1,3])+0.4,pred_2d);
      video2=DrawLine1(video2,pred_2d,1,17);
      video2=DrawLine1(video2,pred_2d,17,2);
      video2=DrawLine1(video2,pred_2d,2,6);
      video2=DrawLine1(video2,pred_2d,2,3);
      video2=DrawLine1(video2,pred_2d,3,4);
      video2=DrawLine1(video2,pred_2d,4,5);
      video2=DrawLine1(video2,pred_2d,5,18);
      video2=DrawLine1(video2,pred_2d,6,7);
      video2=DrawLine1(video2,pred_2d,7,8);
      video2=DrawLine1(video2,pred_2d,2,16);
      video2=DrawLine1(video2,pred_2d,16,15);
      video2=DrawLine1(video2,pred_2d,15,12);
      video2=DrawLine1(video2,pred_2d,12,13);
      video2=DrawLine1(video2,pred_2d,13,14);
      video2=DrawLine1(video2,pred_2d,14,21);
      video2=DrawLine1(video2,pred_2d,15,9);
      video2=DrawLine1(video2,pred_2d,9,10);
      video2=DrawLine1(video2,pred_2d,10,11);
      video2=DrawLine1(video2,pred_2d,11,20);
      video1 = imresize(video2,[size(video,1),size(video,2)]);
      % %video1=uint8(video2);
      % fprintf('############zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz')
      imshow(video1)
      % writeVideo(v1,video1);
      %F=getframe(gcf);
      %F=imresize(F,[size(video,1),size(video,2)])
      %imshow(F);
      
      writeVideo(v1,mat2gray(video1)); 
      F.Visible='off';
  end  
end
close(v1)
%close(v)
