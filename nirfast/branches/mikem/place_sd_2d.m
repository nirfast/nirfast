% Places sources and detectors for spec/tomo system.
% Must have SD txt file to load with 4 points at the locations of the
% fiducial markers from the fiber holder.
% M. Mastanduno 6/20/10


% load fiducial points
sd_fn = 'homog_corner.txt';
mesh_fn = 'homog'; 
pix_sp = .625;

mesh = load_mesh(mesh_fn);


fid=fopen(sd_fn,'r');
for i=1:12
    tline=fgetl(fid);
end
a=fgetl(fid);
x= [];y=[];z=[];
while(a~=-1)
    str = str2num(a(6:end));
    x(int32(str(1))) = str(2);
    y(int32(str(1))) = str(3);
    z(int32(str(1))) = str(4);
    a = fgetl(fid);
end
x = x';
y = y';
z = z';
fclose(fid);

if length(x)>4
    cor_mim = [x(5:8) y(5:8) z(5:8)];
    f = [x(1:4) y(1:4) z(1:4)];
else
    f = [x y z];
end

if x(1)==x(2)
    f(:,1) = 0;
    f = [f(:,2) f(:,3) f(:,1)];
elseif y(1)==y(2)
    f(:,2) = 0;
    f = [f(:,1) f(:,3) f(:,2)];
else % z(1)==z(2)
    f(:,3) = 0;   
    f = [f(:,1) f(:,2) f(:,3)];
end

if length(x)>4
    if x(1)==x(2)
        cor_mim(:,1) = 0;
        cor_mim = [cor_mim(:,2) cor_mim(:,3) cor_mim(:,1)];
    elseif y(1)==y(2)
        cor_mim(:,2) = 0;
        cor_mim = [cor_mim(:,1) cor_mim(:,3) cor_mim(:,2)];
    else % z(1)==z(2)
        cor_mim(:,3) = 0;
        cor_mim = [cor_mim(:,1) cor_mim(:,2) cor_mim(:,3)];
    end
end


% account for bitmap transformation
[i j] = max(mesh.nodes(:,2)); % upper left
cor_bmp(1,:) = mesh.nodes(j,:);
[i j] = min(mesh.nodes(:,1)); % lower left
cor_bmp(2,:) = mesh.nodes(j,:);
[i j] = min(mesh.nodes(:,2)); % lower right
cor_bmp(3,:) = mesh.nodes(j,:);
[i j] = max(mesh.nodes(:,1)); % upper right
cor_bmp(4,:) = mesh.nodes(j,:);

trans = cor_mim(:,1:2)\cor_bmp(:,1:2);
fid_pts = f(:,1:2)*trans;

clf
trimesh(mesh.elements,mesh.nodes(:,1),mesh.nodes(:,2))
hold on;
plot(cor_mim(:,1),cor_mim(:,2),'ro','linewidth',2)
plot(cor_bmp(:,1),cor_bmp(:,2),'bo','linewidth',2)
% plot(f(:,1),f(:,2),'ro')
% plot(fid_pts(:,1),fid_pts(:,2),'bo')

dist = 8.9 + (0:12.7:7*12.7);

% place 1-8
shift(1:8,:) = repmat(f(1,1:3),8,1);
move1 = f(2,1:3) - f(1,1:3);
[sd(1:8,1),r,sd(1:8,3)] = cart2pol(move1(1),move1(2),move1(3));
sd(1:8,2) = dist;
% place 9-16
shift(9:16,:) = repmat(f(4,1:3),8,1);
move2 = f(3,1:3) - f(4,1:3);
[sd(9:16,1),r,sd(9:16,3)] = cart2pol(move2(1),move2(2),move2(3));
%th916 = atand(shift(9,2)/shift(9,1));
%sd(9:16,1) = th916;
sd(16:-1:9,2) = dist;
[sd(:,1) sd(:,2),sd(:,3)] = pol2cart(sd(:,1),sd(:,2),sd(:,3));
sd = sd+shift;

% write source file
fid = fopen([mesh_fn,'.source'],'w');
for i = 1:16
    fprintf(fid,'%f %f \n',sd(i,1),sd(i,2));
end
fclose(fid);

% write meas file
fid = fopen([mesh_fn,'.meas'],'w');
for i = 1:16
    fprintf(fid,'%f %f \n',sd(i,1),sd(i,2));
end
fclose(fid);
% fprintf(fid,'%f %f %f \n',sd(i,1),sd(i,2),sd(i,3));
close all
mesh = load_mesh(mesh_fn);
plotmesh(mesh,1)