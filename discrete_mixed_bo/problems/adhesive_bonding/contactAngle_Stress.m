function [S] = contactAngle_Stress(contactAngle)
    %S = 30*sigmoid(contactAngle, 60, -0.029)+14.8;
    %S = 3.5*sigmoid(contactAngle, 80, -0.08)+2.75;
    %figure
    %plot(S)
    %hold on
    %plot(S2)
    S = 6*sigmoid(contactAngle, 60, -0.04)+2.75;
end
