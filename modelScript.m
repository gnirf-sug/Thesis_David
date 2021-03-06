clear all;
%% COMPUTATION OF HB/QUEMADA/BUSCALL
% The script is divided in several sections. First introduce the constants for the
% model. Select the input data (viscosity vs stress). Run section 1
% for HB model. Run section 2 for viscosity model. Run section 3 for interparticle Energy
% Run section 4 for figures and rheology information. Run section 5 for bulk modulus computation.

%% CONSTANTS (Section 0)
K = 1.38064852e-23;
A = 1497;
concm = 0.637;
T = input('What is the temperature value (in K)?');
a = 1e-9*(input('What is particle radius (in nm)?'));
ah = 1e-9*(input('What is the hydrodynamic radius (in nm)?'));
nf = input('What is the dispersed fluid viscosity (in Pa)?');
L = ah - a;

%% INPUT DATA (Section 0)
%Data has to be in a folder in the format "SampleName_Concentration.DAT".
%Introduce "Compound" to import the data from that compound to the model.
%Concentration of particles is assumed to be in % units

compound = input('What is the compound you want to evaluate?'); %e.g. "Pluronic"
files = dir(compound + '*');
for i = (1:1:numel(dir('*.txt'))); 
conc(i,1) = str2num(files(i).name(10:11));
DATA = importdata(files(i).name);
stress(:,i) = DATA(:,1);
vis(:,i) = DATA(:,2);
end

she = stress./vis;

%% HERSCHEL-BULKLEY FIT (Section 1).
% In all the fittings, find commented to select properties to exclude
% points and select xData limits
for i = (1:1:numel(dir('*.txt')));
dec = 1;
while dec == 1;
    close all;
    [xData, yData] = prepareCurveData( she(:,i), stress(:,i));
    ft = fittype( 'yield+k*x^n', 'independent', 'x', 'dependent', 'y' );
    %a = input('What is the upper limit?');
    %b = input('What is the lower limit?');
    excludedPointsUp = xData > max(xData);
    excludedPointsLow = xData < min(xData);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Robust = input(['Do Robust fitting for sample ' num2str(i) '?: "Off" (No), "Bisquare", "LAR"? ']);
    opts.Display = 'Off';
    % Here to specify the limits for each of the coefficients
    %opts.Lower = [input('What is the lower limit for yield stress?') input('What is the lower limit for the k constant?') input('What is the lower limit for the n index?')];
    %opts.Upper = [input('What is the upper limit for yield stress?') input('What is the upper limit for the k constant?') input('What is the upper limit for the n index?')];
    %opts.Exclude = excludedPointsUp;
    %opts.Exclude = excludedPointsLow;
    
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'Herschel-Bulkley fitting' );
    h = plot( fitresult, xData, yData );
    ax = gca;
    %ax.XLim = ([min(xData) max(xData)]);
    disp("The adjusted R is equal to " + num2str(gof.adjrsquare));
    dec = menu('Are you happy with the fitting?', 'No', 'Yes');
    n(i) = fitresult.n;
    k(i) = fitresult.k;
    yield(i) = fitresult.yield;
end 
end

%% VISCOSITY MODEL FIT (Section 2.1)
%vis = vis/nf; Use this if viscosity units are not relative
F = 1 - vis.^(-1/2);
for i = (1:1:numel(dir('*.txt')));
dec = 1;
B = a^3./(conc*K*T/100);
while dec == 1;
    close all;
    [xData, yData] = prepareCurveData( stress(:,i), F(:,i));
    ft = fittype( ['((x/0.63)+(x/xinf)*(x*' num2str(B(i)) '*sigma*(1/(1+E))))/(1+(x*' num2str(B(i)) '*sigma*(1/(1+E))))'], 'independent', 'sigma', 'dependent', 'y' );
    %a = input('What is the upper limit?');
    %b = input('What is the lower limit?');
    excludedPointsUp = xData > max(xData);
    excludedPointsLow = xData < min(xData);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Robust = input(['Do Robust fitting for sample ' num2str(i) '?: "Off" (No), "Bisquare", "LAR"? ']);
    opts.Display = 'Off';
    % Here to specify the limits for each of the coefficients
    %opts.Lower = [input('What is the lower limit for yield stress?') input('What is the lower limit for the k constant?') input('What is the lower limit for the n index?')];
    %opts.Upper = [input('What is the upper limit for yield stress?') input('What is the upper limit for the k constant?') input('What is the upper limit for the n index?')];
    %opts.Exclude = excludedPointsUp;
    %opts.Exclude = excludedPointsLow;
    
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'Viscosity model' );
    h = plot( fitresult, xData, yData );
    ax = gca;
    %ax.XLim = ([min(xData) max(xData)]);
    disp("The adjusted R is equal to " + num2str(gof.adjrsquare));
    dec = menu('Are you happy with the fitting?', 'No', 'Yes');
    frac(i) = fitresult.x;
    fracInf(i) = fitresult.xinf;
    frac0(i) = 0.63;
    E(i) = fitresult.E;
end 
end






%% VISCOSITY MODEL FIT, sigmac extract (Section 2.2)
%vis = vis/nf; Use this if viscosity units are not relative
for i = (1:1:numel(dir('*.txt')));
dec = 1;
while dec == 1;
    close all;
    [xData, yData] = prepareCurveData( stress(:,i), F(:,i));
    ft = fittype('((x/xo)+(x/1)*(sigma/sigmac))/(1+(sigma/sigmac))',  'independent', 'sigma', 'dependent', 'y' );
    %a = input('What is the upper limit?');
    %b = input('What is the lower limit?');
    excludedPointsUp = xData > max(xData);
    excludedPointsLow = xData < min(xData);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Robust = input(['Do Robust fitting for sample ' num2str(i) '?: "Off" (No), "Bisquare", "LAR"? ']);
    opts.Display = 'Off';
    % Here to specify the limits for each of the coefficients
    %opts.Lower = [input('What is the lower limit for yield stress?') input('What is the lower limit for the k constant?') input('What is the lower limit for the n index?')];
    %opts.Upper = [input('What is the upper limit for yield stress?') input('What is the upper limit for the k constant?') input('What is the upper limit for the n index?')];
    %opts.Exclude = excludedPointsUp;
    %opts.Exclude = excludedPointsLow;
    
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'Viscosity model' );
    h = plot( fitresult, xData, yData );
    ax = gca;
    %ax.XLim = ([min(xData) max(xData)]);
    disp("The adjusted R is equal to " + num2str(gof.adjrsquare));
    dec = menu('Are you happy with the fitting?', 'No', 'Yes');
    sigmac(i) = fitresult.sigmac;
end 
end


%% INTERPARTICLE ENERGY (Section 3)
    D = (2*a.*(concm./(conc/100)).^(1/3))-(2*a);
    r = D + 2*a;
    figure();
    plot (D/(2*L),E,'.','MarkerSize',20)
    hold on
    %U from theory
    U = A*K*T*exp(-pi.*D/L);
    plot (D/(2*L),U/(K*T),'--','Linewidth',3);
    legend('Viscosity model','Repulsive U equation');
    xlabel('D/2L');
    ylabel('U/KbT');
    ax = gca; 
    ax.FontSize = 16;
    H = U/(K*T);

%% FIGURE GENERATION (Section 4)
    %Computation of Rheological factors
    visinf = (1 - (frac./fracInf)).^(-2);
    vis0 = (1 - (frac./frac0)).^(-2);
    R = (visinf./vis0).^(1/2);
    
    %Rheology index
    for i=(1:1:numel(dir('*.txt')));
    if (R(i) > 0) && (R(i) < 1)
        disp("Fraction" + num2str(i) + "gives a Pseudoplastic behaviour with value");
    elseif (R(i) > 1)
        disp("Fraction"  + num2str(i) + "gives a Dilatant behaviour");
    elseif (R(i) == 0)
        disp("Fraction" + num2str(i) +  "gives a Plastic behaviour");
    elseif (R(i) < 0)
        disp("Fraction" + num2str(i) + "gives a Discontinuous viscosity");
    else
        disp("Fraction" + num2str(i) + "gives a Newtonian behaviour");
    end
    end
    
    %High and low shear limits of the relative viscosity
    p = semilogy (conc, visinf,'o', conc, vis0,'.','color','r');
    p(1).MarkerSize = 12;
    p(2).MarkerSize = 30;
    xlabel('Fraction(%)');
    ylabel('\eta_{x}');
    legend('\eta_{x=inf}','\eta_{x=o}','Location','southeast');
    ax = gca; 
    ax.FontSize = 16;

    %High and low shear limits of the relative volume fraction
    figure();
    p = semilogy (conc, frac./fracInf,'o', conc, frac./frac0,'.','color','b');
    p(1).MarkerSize = 12;
    p(2).MarkerSize = 30;
    xlabel('Fraction(%)');
    ylabel('\phi/\phi_{x}');
    legend('\phi_{x=inf}','\phi_{x=o}','Location','southeast');
    axis([0 10 0 1.1]);
    ax = gca; 
    ax.FontSize = 16;
    %%
    % Yield stress
    sigmaY = sigmac.*((frac./frac0)-1)./(1-(frac./fracInf));
    figure();
    plot (conc, sigmaY,'k--o', 'MarkerSize', 12,'Linewidth',1);
    xlabel('Fraction(%)');
    ylabel('\sigma_Y (Pa)');
    ax = gca; 
    ax.FontSize = 16;
    hold on 
    plot (conc, yield,'b--o', 'MarkerSize', 12,'Linewidth',1);
    legend('Quemada model', 'HB model');
    hold off
    
%% BUSCALL FIT (Section 5.1)
% Last model to implement. Needs variables from viscosity model
dec = 1;
while dec == 1;
    close all;
    [xData, yData] = prepareCurveData( r, H);
    ft = fittype( 'exp1' );
    %a = input('What is the upper limit?');
    %b = input('What is the lower limit?');
    excludedPointsUp = xData > max(xData);
    excludedPointsLow = xData < min(xData);
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Robust = input('Do Robust fitting?: "Off" (No), "Bisquare", "LAR"? ');
    opts.Display = 'Off';
    % Here to specify the limits for each of the coefficients
    %opts.Lower = [input('What is the lower limit for yield stress?') input('What is the lower limit for the k constant?') input('What is the lower limit for the n index?')];
    %opts.Upper = [input('What is the upper limit for yield stress?') input('What is the upper limit for the k constant?') input('What is the upper limit for the n index?')];
    %opts.Exclude = excludedPointsUp;
    %opts.Exclude = excludedPointsLow;
    
    [fitresult, gof] = fit( xData, yData, ft, opts );
    figure( 'Name', 'Buscall model' );
    h = plot( fitresult, xData, yData );
    ax = gca;
    %ax.XLim = ([min(xData) max(xData)]);
    disp("The adjusted R is equal to " + num2str(gof.adjrsquare));
    dec = menu('Are you happy with the fitting?', 'No', 'Yes');
    q = fitresult.a;
    w = fitresult.b;
end
 
%% BUSCALL COMPUTATION (Section 5.2)
    d = q*w^2*exp(w*transpose(r));
    Rr = 2*a*(0.74./(frac*0.01)).^(1/3);
    G = (12*0.74.*d)./(5*pi.*Rr);
    semilogy(conc,G,'.','Markersize',24)
    xlabel('Concentration (%)');
    ylabel('G^{,}_{\infty}(Pa)');
    ax = gca; 
    ax.FontSize = 16;
