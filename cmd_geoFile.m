thismed = get(bouton.med,'value');
para.cont(thismed,1).NumPieces = str2double(get(bouton.gfNumPieces,'string'));
nom = chercheSTL(thismed);
set(bouton.geoFileSelect,'string',['Piece(',num2str(info.ThisPiece),'): ',nom]);
% tomar los valores más actuales:
para.cont(thismed,1).piece{info.ThisPiece}.fileName = nom;
para.cont(thismed,1).piece{info.ThisPiece}.continuosTo = str2double(get(bouton.gfThisPieceContinuosTo,'string'));
para.cont(thismed,1).piece{info.ThisPiece}.ColorIndex = get(bouton.gfThisPieceColor,'value');
para.cont(thismed,1).piece{info.ThisPiece}.kind = get(bouton.gfThisPieceKind,'value');
if para.cont(thismed,1).piece{info.ThisPiece}.kind == 1 % free surface
  para.cont(thismed,1).piece{info.ThisPiece}.continuosTo = 0;
end
k = strfind(nom,'.txt');
if isempty(k)
[para.cont(thismed,1).piece{info.ThisPiece}.geoFileData,flag] = ...
 previewSTL(bouton.gfPreview,para.cont(thismed,1).piece{info.ThisPiece});
else
    %flag = 0;
    % para propositos toma el último de la lista
    data = importdata(nom);
    nn = length(data.rowheaders);
    stage = struct('fileName','','jini',0,'jfin',0);
    cd ..
    cd ins
    for idat = 1:nn
    v = fullfile(pwd, data.rowheaders(idat));
    stage(idat).fileName = v{1};
    stage(idat).jini = data.data(idat,1);
    stage(idat).jfin = data.data(idat,2);
    end
    cd ..
    cd multi-dwn-ibem.matlab
    para.cont(thismed,1).piece{info.ThisPiece}.stage = stage;
    auxcont.fileName = v{1}; clear nn v
    auxcont.ColorIndex = para.cont(thismed,1).piece{info.ThisPiece}.ColorIndex;
[para.cont(thismed,1).piece{info.ThisPiece}.geoFileData,~] = ...
 previewSTL(bouton.gfPreview,auxcont);
    clear auxcont
   flag = 2;
end
if flag == 0
  para.cont(thismed,1).piece{info.ThisPiece}.fileName ='X';
else
  % apilar
  para.cont(thismed,1).FV.vertices = [];
  para.cont(thismed,1).FV.faces = [];
  para.cont(thismed,1).FV.facenormals = [];
  for ip = 1:para.cont(thismed,1).NumPieces
      if size(para.cont(thismed,1).piece,2) >= ip
    if isfield(para.cont(thismed,1).piece{ip}.geoFileData,'V')
      para.cont(thismed,1).FV.vertices =    [para.cont(thismed,1).FV.vertices;    para.cont(thismed,1).piece{ip}.geoFileData.V];
      para.cont(thismed,1).FV.faces =       [para.cont(thismed,1).FV.faces;       para.cont(thismed,1).piece{ip}.geoFileData.F];
      para.cont(thismed,1).FV.facenormals = [para.cont(thismed,1).FV.facenormals; para.cont(thismed,1).piece{ip}.geoFileData.N];
    end
      end
  end
end
clear thismed nom ip k
rafraichi;
