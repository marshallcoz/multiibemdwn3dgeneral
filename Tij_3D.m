function T=Tij_3D(ks,kp,rij,gam,C,vn)
% Je conserve la notation de l article 
% du BSSA, Vol. 85, No. 1, pp. 269-284, 1995
% Seismic Response of Three-Dimensional Alluvial Valleys for Incident P, S, and Rayleigh Waves
% by Francisco J. Sanchez-Sesma and Francisco Luzon
% et non celle du programme de Paco

n       = length(rij);
ba      = kp/ks;%beta/alpha
kpr     = kp*rij;
ksr     = ks*rij;
ksrm1   = 1./ksr;
g       = zeros(3,n);


% A1(1)   = 0;
% A1(2)   = 0;
% A1(3)   =-1i;
% 
% A2(1)   =-1i*ba;
% A2(2)   = 1i*(2*ba^3-ba);
% A2(3)   = 0;
% 
% B1(1)   = 4;
% B1(2)   =-2;
% B1(3)   =-3;
% 
% B2(1)   =-4*ba^2-1;
% B2(2)   = 4*ba^2-1;
% B2(3)   = 2*ba^2;
% 
% C1(1)   =-12i;
% C1(2)   = 6i;
% C1(3)   = 6i;
% 
% C2(1)   = 12i*ba;
% C2(2)   =-6i*ba;
% C2(3)   =-6i*ba;
% 
% D1(1)   =-12;
% D1(2)   = 6;
% D1(3)   = 6;
% 
% D2(1)   = 12;
% D2(2)   =-6;
% D2(3)   =-6;
% for j=1:3
%     g(j,:)= ...
%     (ksr.*A1(j)+B1(j)+C1(j)*ksrm1+D1(j)*ksrm1.^2).*exp(-1i*ksr)+...
%     (ksr.*A2(j)+B2(j)+C2(j)*ksrm1+D2(j)*ksrm1.^2).*exp(-1i*kpr);
% end


g(1,:)= ...
    (                      4-12i*ksrm1-12*ksrm1.^2).*exp(-1i*ksr)+...
    (-1i*ba*ksr-4*ba^2-1+ 12i*ba*ksrm1+12*ksrm1.^2).*exp(-1i*kpr);

g(2,:)= ...
    (                             -2+6i*ksrm1+6*ksrm1.^2).*exp(-1i*ksr)+...
    ( 1i*(2*ba^3-ba)*ksr+4*ba^2-1-6i*ba*ksrm1-6*ksrm1.^2).*exp(-1i*kpr);

g(3,:)= ...
    (-1i*ksr-3+ 6i*ksrm1+6*ksrm1.^2).*exp(-1i*ksr)+...
    (2*ba^2 -6i*ba*ksrm1-6*ksrm1.^2).*exp(-1i*kpr);


T   = zeros(3,3,n);
d   = eye(3);

gknk= gam(1,:).*vn(1,:)+gam(2,:).*vn(2,:)+gam(3,:).*vn(3,:);
g0  = g(1,:)-g(2,:)-2*g(3,:);
fac = 1./(4*pi*rij.^2);
for i=1:3
    for j=1:3
        T(i,j,:)=fac.*(g0.*gam(i,:).*gam(j,:).*gknk +...
        g(3,:).*(gam(i,:).*vn(j,:)+gknk.*d(i,j))+g(2,:).*gam(j,:).*vn(i,:));
    end
end