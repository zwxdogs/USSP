function J = dopplermap(m,iswhite)
% MUST中的多普勒速度colormap

if nargin < 1
   f = get(groot,'CurrentFigure');
   if isempty(f)
      m = size(get(groot,'DefaultFigureColormap'),1);
   else
      m = size(f.Colormap,1);
   end
end

if nargin<2, iswhite = false; end

if rem(m,2)==0
    x = [linspace(0,.5,m/2) linspace(.5,1,m/2)]';
else
    x = linspace(0,1,m)';
end

% RGB values
R = min(1.8*sqrt(x-0.5),1).*(x>=0.5); % + 0.06*(x<0.5);
G = -8*(x-0.5).^4 + 6*(x-0.5).^2;
B = 1.1*sqrt(0.5-x).*(x<=0.5); % + 0.03*(x>0.5);

% Doppler color map
J = [R G B];

if iswhite
    J = 1-J;
    J = J.*circshift(tukeywin(m),round(m/2));
    J = 1-J;
end
    


