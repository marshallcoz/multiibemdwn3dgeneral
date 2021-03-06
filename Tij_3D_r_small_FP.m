function Tij=Tij_3D_r_small_FP(coord,xs,ys,zs,jjpb,ks,kp,gaussian,C)
% trata el calculo de la contribution de un segmento centrado en xj,zj
% sobre un punto de colocacion xi,zi cual esta mas cercano que dr a xj,zj

xfc0    = coord.x0(jjpb).';
thfc    = coord.th(jjpb).';
nbptc   = coord.nbptc(jjpb).';

zfc     = coord.z(jjpb).';

vnx     = coord.vnx(jjpb).';
vnz     = coord.vnz(jjpb).';
vnx0    = vnx./cos(thfc);
ind     = (mod(thfc-pi/2,pi)==0);
vnx0(ind)= coord.vny(jjpb(ind)).'./sin(thfc(ind));

drxz    = coord.drxz(jjpb).';

ngau    = gaussian.ngau;
xgau    = gaussian.xgau;
wgau    = gaussian.wgau;
nj      = length(jjpb);

%construction des coordonnees des points de Gauss

xij     = zeros(nj,ngau^2);
yij     = zeros(nj,ngau^2);
zij     = zeros(nj,ngau^2);
vnxij   = zeros(nj,ngau^2);
vnyij   = zeros(nj,ngau^2);
vnzij   = zeros(nj,ngau^2);
wij     = zeros(nj,ngau^2);

k   = 0;
for i=1:ngau
    %boucle sur le vertical, plan xz
    % pour le calcul des rayons initiaux
    xfi     = xfc0-vnz .*drxz*xgau(i)*0.5;
    zfi     = zfc +vnx0.*drxz*xgau(i)*0.5;
    for j=1:ngau
        k=k+1;
        %boucle sur le rayon ds le plan xy
        % on recalcule les positions des points de gauss 
        % et leur normales(car elements courbes)
        % on dispose les points de Gauss sur l element courbe comme si
        % deplies (le long de r)
        dthgauss    = 2*pi./nbptc*xgau(j)*.5;
        xij(:,k)    = xfi.*cos(thfc+dthgauss)-xs;
        yij(:,k)    = xfi.*sin(thfc+dthgauss)-ys;
        zij(:,k)    = zfi-zs;
        vnxij(:,k)  = vnx0.*cos(thfc+dthgauss);
        vnyij(:,k)	= vnx0.*sin(thfc+dthgauss);
        vnzij(:,k)	= vnz;
        wij(:,k)    = wgau(i)*wgau(j)*xfi./xfc0;
    end
end
xij     = reshape(xij,1,nj*ngau^2);
yij     = reshape(yij,1,nj*ngau^2);
zij     = reshape(zij,1,nj*ngau^2);
vn      = zeros(3,nj*ngau^2);
vn(1,:) = reshape(vnxij,1,nj*ngau^2);
vn(2,:) = reshape(vnyij,1,nj*ngau^2);
vn(3,:) = reshape(vnzij,1,nj*ngau^2);

rij     = sqrt(xij.^2+yij.^2+zij.^2);

g       = zeros(3,nj*ngau^2);
g(1,:)  = xij./rij;
g(2,:)  = yij./rij;
g(3,:)  = zij./rij;

Trij    = Tij_3D(ks,kp,rij,g,C,vn);
indpb   = (rij<=min(drxz)/30);
Trij(:,:,indpb) =0;
Trij    = reshape(Trij,3,3,nj,ngau^2);


Tij=zeros(3,3,nj);
if nj~=1
    for i=1:3
        for j=1:3
            Tij(i,j,:)	= sum(0.25*wij.*squeeze(Trij(i,j,:,:)),2);
        end
    end
else
    for i=1:3
        for j=1:3
            Tij(i,j,:)	= sum(0.25*wij.'.*squeeze(Trij(i,j,:,:)));
        end
    end
end