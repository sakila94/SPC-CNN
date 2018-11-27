function op = jointCooccurrence(im,id,layer)
    LM(:,:,1:3) = im(1:2:end,1:2:end,:);
    LM(:,:,4:6) = im(1:2:end,2:2:end,:);
    LM(:,:,7:9) = im(2:2:end,1:2:end,:);
    LM(:,:,10:12) = im(2:2:end,2:2:end,:);

    SI(:,:,1) = LM(:,:,(id(1)-1)*3+layer(1));
    SI(:,:,2) = LM(:,:,(id(2)-1)*3+layer(2));
    SI(:,:,3) = LM(:,:,(id(3)-1)*3+layer(3));
    
    limit = max(max(max(SI))) - min(min(min(SI))) + 1;
    op = zeros(limit,limit,limit);

    dim = size(SI);
    for i = 1:dim(1)
        for j = 1:dim(2)
            a = reshape(SI(i,j,:),[1,3]);
            op(a(1),a(2),a(3)) = op(a(1),a(2),a(3)) + 1;
        end
    end
    op = op / (dim(1) * dim(2) );

end