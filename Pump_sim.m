function [f,HBmin,HBmax]=Pump_sim(tstart1,tstop1, tstart2, tstop2)
try
    % Ermittlung der Anlagenkennlinien
    Qanlage = linspace(0,2000,2000);
    
    load('Qn'); % Netzverbrauch
    % xlsread % File muss sich im Pfad befinden
    tsimstart=('Enter Simulation Starting Time in [h]: ');
    tsim = input('Enter Duration Time in [h]: ');
    tsimend=tsimstart+tsim;
    
    HB=zeros(tsim,1); % Initialarray % am Besten Cell oder Struct
    HB(1)=54 % initialisiere Anfangsbehälterstand mit Epanet-Klasse
    
    t=[tsimstart:1:tsim];
    % Switch on / off-times Pumps
    tstart1=100;
    tstop1 = 200;;
    tstart2=100;
    tstop2 = 200;;
    tstart3=0;
    tstop3 = 0;; 
    tstart3=0;
    tstop3 = 0;;
    
    % Initialisierung Behälterstand
    Hstat=zeros(size(t));
    % HB(1)=51.5;
    
    % Daten Pumpenkennlinie
    % Unterschiedliche Vektorlänge aufgrund von Messdaten
    Q1 = linspace(306,1608,18);
    H1 =  linspace(74.61,66.14,18);
    Q2 = linspace(161,1219,14);
    H2 =  linspace(72.21,53.67,14); 
    Q3 = linspace(94,991,14);
    H3 =  linspace(63.64,51.39,14); 
    Q4 = linspace(106,833,12);
    H4 =  linspace(62.70,50.98,12);
    
    p = polyfit(Q1,H1,2);
    H1 = polyval(p,Qanlage);
    p = polyfit(Q2,H2,2);
    H2 = polyval(p,Qanlage);    
    p = polyfit(Q3,H3,2);
    H3 = polyval(p,Qanlage);   
    p = polyfit(Q4,H4,2);
    H4 = polyval(p,Qanlage);
    
    % figure
    % plot(Qanlage,H1,'r-','Displayname','Pumpecurve P1');
    % hold on 
    % plot(Qanlage,H2,'r-','Displayname','Pumpecurve P2');   
    % plot(Qanlage,H3,'r-','Displayname','Pumpecurve P3'); 
    % plot(Qanlage,H4,'r-','Displayname','Pumpecurve P4');
    
    % Angaben Vorlagebehälter
    % z.B. function tank
    A = pi*44^2/4;
    Hmin = 52.25;
    Hmax = 57;
    
    % Pumpe=1 > an (true); Pumpe=0 > aus (false)
    Pumpe = 1;
    % Initialisierung Betriebspunkt Pumpe
    QBP = zeros(size(t));
    HBP = zeros(size(t));
    etaBP = ones(size(t)); % eta maximieren als Restriction in der Zielfunktion
    
    Qhelp = 250:1:1800;
    Hhelp = 52:0.01:57;
    
    HPumpe = H2;
    
    % minimale / maximale Anlagenkennlinie
    HBmin = 51;
    Qnvmin = 260; 
    HBmax=58; 
    Qnvmax=1300;
    
    % Zeitlicher Verlauf Pumpenbetrieb / Pumpendynamik
    for i=1:size(t,2)-1
        % Kenndaten Anlagenkennlinie
        a=-0.000000002713*Qn(i)+0.000006504;
        b=0.0000004384*Qn(i)-0.001768;
        
        Hanlage(i,:)=a*Qanlage.^2 + b*Qanlage + HB(i,1);
        
        if (i>tstart1 && i<=tstop1) % Pumpe1 an 
            Pumpe=1;
            HPumpe=H1;
        elseif (i>tstart2 && i<=tstop2) % Pumpe2 an 
            Pumpe=1;
            HPumpe=H2; 
        elseif (i>tstart3 && i<=tstop3) % Pumpe3 an 
            Pumpe=1;
            HPumpe=H3;
         elseif (i>tstart4 && i<=tstop4) % Pumpe2 an 
            Pumpe=1;
            HPumpe=H4;
        else
            Pumpe=0;
        end
        
        % Pumpe an, wenn Behälterstand kleiner Hmax
        if (Pumpe==1);
            % Berechnung Betriebspunkt Pumpe
            [~,res]=min(abs(Hanlage(i,:)-Hpumpe));
            QBP(i)=Qanlage(res);
            HBP(i)=Hpumpe(res);
            etaBP(i)=eta2(res);
            
            % Berechnung neuer Behälterstand
            HB(i+1)=HB(i)+((QBP(i)-Qn(i))/60/A;
            
            if HB(i+1)>Hmax
                % Pumpe ausschalten, wenn Hmax überschritten wird 
                Pumpe=0;
                HB(i+1)=Hmax;
            end
        else
            % Pumpe aus, wenn Behälterstand > Hmax
            QBP(i)=0;
            HBP(i)=0;
            etaBP(i)=1;
            % Berechnung neuer Behälterstand
            HB(i+1)=HB(i)+((QBP(i)-Qn(i))/60/A;
            if HB(i+1) < Hmin
                % Pumpe einschalten, wenn Hmin unterschritten wird 
                Pumpe=1;
               if HB(i+1) < 51
                   HB(i+1) = 51;
               end
            end
        end
    end
 
% Berechnung Pumpenleistung
rho=1000;
g=9.81;
PBP=rho*g*QBP./3600.*HBP./etaBP;

catch errorObj % Catch Error Msg
    errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error'); % Dialog with Error (for exec)
    getReport(errorObj,'extended','hyperlinks','on') % Error in Command Window (for Matlab)
end

% spez. Energieverbrauch
f=sum(PBP)/sum(QBP)/1000;
HBmin=min(HB);
HBmax=max(HB);
% 
figure(2);
% QPumpe
plot(t./60,QBP,'r');
hold on
axis([0 24 0 1400]);
xlabel('Duration Time t [h]');
set(gca,'XTick',[0:4:24]);
ylabel('Flowrate [m³/h]');
legend('Simualtion','Location','SouthWest');
hold off
%
figure(3)
% HB
plot(t./60,HB,'r');
hold on
axis([0 24 51 58]);
xlabel('Duration Time t [h]');
set(gca,'XTick',[0:4:24]);
ylabel('Tanklevel [m]');
legend('Simualtion','Location','NorthEast');
%
figure(4)
% Plot Q-H-Kennlinie
plot(Qanlage,H1,'r-',Qanlage,H2,'b-',Qanlage,H3,'b-',Qanlage,H4,'b-');
hold on
% Plot Anlagenkennlinie
plot(Qanlage,Hanlage);
xlabel('Flowrate Q [m³/h]');
ylabel('Head [m]');
% formfig
axis([0 2000 0 80]);
% plot Betriebspunkt Pumpe
plot(QBP,HBP,'ko');
    
            
    