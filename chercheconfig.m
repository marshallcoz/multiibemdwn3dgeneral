tmprep=para.nomrep;
tmprep1=para.nomcarpeta;
if exist([para.nomrep,'/configparatmp.mat'],'file')==2 && pdef==1
    load([para.nomrep,'/configparatmp']);
    rafraichi;
else
    cd(para.nomrep)
    [nomfile2,nomrep2]=uigetfile('*.mat','archivo de parametro');
    cd(para.nomcarpeta)
    if isequal(nomrep2,0) || isequal(nomfile2,0)
        helpdlg('entra un archivo de tipo configparatmp.mat','info');
    else
        disp([nomrep2,nomfile2])
        load([nomrep2,nomfile2]);
        para.name=[nomrep2,nomfile2];
        rafraichi;
    end
end
para.nomrep=pwd;
para.nomcarpeta=pwd;
b_dib(1).name=para.name;
if (isfield(para,'cont1'));
para.cont1 = cont1;
end

if exist('utc','var')
RESULT.utc=utc;     clear utc
RESULT.uw=uw;       clear uw
RESULT.stc=stc;     clear stc
RESULT.sw=sw;       clear sw
RESULT.cont1=cont1; clear cont1
end