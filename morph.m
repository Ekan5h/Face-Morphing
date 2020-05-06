function fifty = morph(img1, img2, tpts, fname_out)
    n_frames = 21;
    img1 = imread(fname_inp1);
    img2 = imread(fname_inp2);
    twentyfive = zeros(size(img1));
    fifty = zeros(size(img1));
    seventyfive = zeros(size(img1));
    tpts(end+1,:) = [1 1 1 1];
    tpts(end+1,:) = [1 size(img1,2) 1 size(img1,2)];
    tpts(end+1,:) = [size(img1,1) 1 size(img1,1) 1];
    tpts(end+1,:) = [size(img1,1) size(img1,2) size(img1,1) size(img1,2)];
    P1 = tpts(:,1:2);
    P2 = tpts(:,3:4);
    DT = delaunayTriangulation(P2);
    indices = DT.ConnectivityList;
    I = [1 0 0; 0 1 0; 0 0 1];
    transforms = zeros([3 3 size(indices,1)]);
    for i = 1:size(indices,1)
        M1 = [
                P1(indices(i,1),1) P1(indices(i,2),1) P1(indices(i,3),1);
                P1(indices(i,1),2) P1(indices(i,2),2) P1(indices(i,3),2);
                1 1 1
             ];
        M2 = [
                P2(indices(i,1),1) P2(indices(i,2),1) P2(indices(i,3),1);
                P2(indices(i,1),2) P2(indices(i,2),2) P2(indices(i,3),2);
                1 1 1
             ];
         transforms(:,:,i) = M2*(M1^-1);
    end

    s1 = size(img1);
    out = zeros(size(img1));


    for l = 0:1/(n_frames-1):1
        prevTri = 1;
        trans = (((1-l).*I + l.*transforms(:,:,1))^-1);
        trans1 = transforms(:,:,1);
        P = (1-l).*P1 + l.*P2;
        for i = 1:size(out,1)
            for j = 1:size(out,2)
                tri = 1;
                for k = 1:size(indices,1)
                    if(inTriangle(P(indices(k,1),:), P(indices(k,2),:), P(indices(k,3),:), [i j]))
                        tri = k;
                        break;
                    end
                end
                if(tri~=prevTri)
                    trans1 = transforms(:,:,tri);
                    trans = (((1-l)*I + l*trans1)^-1);
                    prevTri = tri;
                end
                initial_point = trans*[i;j;1];
                final_point = trans1*initial_point;
                x1 = round(initial_point(1,1));
                y1 = round(initial_point(2,1));
                x2 = round(final_point(1,1));
                y2 = round(final_point(2,1));
                if(x1<1 || x1>s1(1) || y1<1 || y1>s1(2) || isnan(y1) || isnan(x1))
                    value1 = 0;
                else
                    value1 = img1(x1,y1,:);
                end
                if(x2<1 || x2>s1(1) || y2<1 || y2>s1(2) || isnan(y2) || isnan(x2))
                    value2 = 0;
                else
                    value2 = img2(x2,y2,:);
                end
                out(i,j,:) = (1-l)*value1 + l*value2;
                if(round(l*(n_frames-1)+1)==round(n_frames/4))
                    twentyfive(i,j,:) = out(i,j,:);
                elseif(round(l*(n_frames-1)+1)==round(n_frames/2))
                    fifty(i,j,:) = out(i,j,:);
                elseif(round(l*(n_frames-1)+1)==round(3*n_frames/4))
                    seventyfive(i,j,:) = out(i,j,:);
                end
            end
        end
        [imind,cm] = rgb2ind(uint8(out),256); 
        if l == 0 
          imwrite(imind,cm,sprintf("%s.gif",fname_out),'gif', 'Loopcount',inf,'DelayTime',0); 
        else 
          imwrite(imind,cm,sprintf("%s.gif",fname_out),'gif','WriteMode','append','DelayTime',0); 
        end 
        disp(l);
    end
    figure();
    subplot(2,3,1);
    imshow(img1);
    title("Original Image");
    subplot(2,3,3);
    imshow(img2);
    title("Transformed Image");
    subplot(2,3,4);
    imshow(uint8(twentyfive));
    title("25%");
    subplot(2,3,5);
    imshow(uint8(fifty));
    title("50%");
    subplot(2,3,6);
    imshow(uint8(seventyfive));
    title("75%");
end

function in = inTriangle(point1, point2, point3, point)
    centroid = (point1+point2+point3)/3;
    in = sameSide(point1, point2, point, centroid)*sameSide(point2, point3, point, centroid)*sameSide(point3, point1, point, centroid);
end

function s = sameSide(point1, point2, point, pointd)
    s = round((point(2) - point2(2) - (point(1) - point2(1))*(point1(2)-point2(2))/(point1(1)-point2(1))))*round((pointd(2) - point2(2) - (pointd(1) - point2(1))*(point1(2)-point2(2))/(point1(1)-point2(1)))) >= 0;
end


