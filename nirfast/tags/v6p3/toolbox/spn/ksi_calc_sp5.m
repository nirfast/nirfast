function [f1,f2,f3,g1,g2,g3,h1,h2,h3] = ksi_calc_sp5(mesh);

%Calculates the boundary condition values for SP3 case based on equations 28a & 28b
%of Klose 2006 paper. 

[BC]=bound_coeffs(mesh,5);

A=BC(:,1:3);
B=BC(:,4:6);
C=BC(:,7:9);
D=BC(:,10:12);
E=BC(:,13:15);
F=BC(:,16:18);

M1= (7/24)+A(:,2)-(3.*D(:,2).*((1/8)+C(:,1)))./(1+B(:,1));
M2= 1+B(:,2)-(21.*D(:,2).*D(:,1))./(1+B(:,1));
M3= (1/8)+C(:,2)-(3.*D(:,2).*((-1/16)+E(:,1)))./(1+B(:,1));
M4= (41/384)+E(:,2)+(3.*D(:,2).*((-1/16)+E(:,1)))./(1+B(:,1));
M5= 11.*F(:,2)+(33.*D(:,2).*F(:,1))./(1+B(:,1));

N1= (407/1920)+A(:,3)-(3.*D(:,3).*((-1/16)+E(:,1)))./(1+B(:,1));
N2= 1+B(:,3)-(33.*D(:,3).*F(:,1))./(1+B(:,1));
N3= (-1/16)+C(:,3)-(3.*D(:,3).*((1/2)+A(:,1)))./(1+B(:,1));
N4= (41/384)+E(:,3)+(3.*D(:,3).*((1/8)+C(:,1)))./(1+B(:,1));
N5= 7.*F(:,3)+(21.*D(:,3).*(D(:,1)))./(1+B(:,1));

O1= (1/2)+A(:,1)-(3.*D(:,1).*M3)./M2;
O2= (1/8)+C(:,1)-(3.*D(:,1).*M1)./M2;
O3 = (-1/16)+E(:,1)+(3.*D(:,1).*M5)./M2;
O4= 7.*F(:,1)+(3.*D(:,1).*M5)./M2;

P1= N1-(N5.*M4)./M2;
P2= N2-(N5.*M5)./M2;
P3= N3+(N5.*M3)./M2;
P4= N4-(N5.*M1)./M2;

f1= (O1-(O4.*P3)./P2)./(1+B(:,1));
f2= (M1-(M5.*P4)./P2)./M2;
f3= P1./P2;

g1= -(O2+(O4.*P4)./P2)./(1+B(:,1));
g2= -(M3+(M5.*P3)./P2)./M2;
g3= -P3./P2;

h1= -(O3-(O4.*P1)./P2)./(1+B(:,1));
h2= -(M4-(M5.*P1)./P2)./M2;
h3= -P4./P2;