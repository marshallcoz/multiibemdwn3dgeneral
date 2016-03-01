function [utc,stc]=inversion_w(uw,sw,para)
% utc : desplazamiento en tiempo corregido con la respuesta temporal de la
%       fuente

nf      = para.nf;
nfN     = nf/2+1; 
para.df = para.fmax/nfN; 
df      = para.fmax/nfN; 

zeropad = para.zeropad;
dt      = (1/(df*2*(nfN+zeropad))*(2*(nfN+zeropad)/(2*(nfN+zeropad)-2)));
tps     = 0:dt:1/df;
% if para.pulso.tipo~=3 % Ricker periodo característico tp
% tps     = para.pulso.b+tps;
% end
tps     = para.pulso.c+tps;

nuw     = size(uw);
nsw     = size(sw);

% correction espectros %
cspectre    =correction_spectre(para,nfN,df);

%wrap de las dimensiones
ntot=1;
nnuw=length(nuw);
for i=2:length(nuw)
    ntot=ntot*nuw(i);
end

uw      = reshape(uw,nuw(1),ntot);
utc     = zeros(nf+1 + 2*zeropad,ntot);

for i=1:ntot
    tmp     = uw(1:nfN,i).';
    tmp     = tmp.*cspectre;
%     utc(:,i)= real(1/(2*nf)*ifft([tmp(1:nfN),zeros(1,2*zeropad+1),conj(tmp(nfN-1:-1:2))])).*exp(para.DWNomei*tps);
    utc(:,i)= real(1/(dt)*ifft([tmp(1:nfN),zeros(1,2*zeropad+1),conj(tmp(nfN-1:-1:2))])).*exp(para.DWNomei*tps);

if para.pulso.tipo == 4
  tp=para.pulso.a;
  utc(:,i) = utc(:,i) * (tp/pi^.5);
end
    
%     nf      = para.nf;
%     df      = para.fmax/(para.nf/2);     %paso en frecuencia
%     Fq      = (0:nf/2)*df;
%     tmp= fft(real(ifft([tmp(1:nfN),zeros(1,2*zeropad+1),conj(tmp(nfN-1:-1:2))])).*exp(para.DWNomei*tps));
%     figure(101);subplot(2,1,2);plot(Fq,imag(tmp(1:nf/2+1)),'g','LineWidth',3)

end
utc  	= reshape(utc,[nf+1 + 2*zeropad,nuw(2:nnuw)]);


ntots=1;
nnsw=length(nsw);
for i2=2:length(nsw)
    ntots=ntots*nsw(i2);
end
sw      = reshape(sw,nsw(1),ntots);
stc     = zeros(nf+1 + 2*zeropad,ntots);

parfor i2=1:ntots
    tmp     = sw(1:nfN,i2).';
    tmp     = tmp.*cspectre;
    stc(:,i2)= real(1/(2*nf)*ifft([tmp(1:nfN),zeros(1,2*zeropad+1),conj(tmp(nfN-1:-1:2))])).*exp(para.DWNomei*tps);
end
stc  	= reshape(stc,[nf+1 + 2*zeropad,nsw(2:nnsw)]);
