%%
[imH,imW]=size(tudgt.sp_label_GT(:,:,1));
npix=imH*imW;

for t=1:20
    thisF=tudgt.sp_label_GT(:,:,t);
    imcol = zeros(imH,imW,3);
    
    segs = unique(thisF(:))';
    
    for s=segs
        
        [u,v]=find(thisF==s);
        imind=sub2ind(size(thisF),u,v);
        
        col=getColorFromID(s);
        
        imcol(imind)=col(1);
        imcol(imind+npix)=col(2);
        imcol(imind+2*npix)=col(3);
        imshow(imcol);
        pause
    end
    
    
end