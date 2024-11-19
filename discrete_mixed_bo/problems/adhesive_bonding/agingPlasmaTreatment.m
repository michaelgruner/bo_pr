function [delta_CA, new] = agingPlasmaTreatment(timeTillGlue)    
    delta_CA = 46.8*((timeTillGlue+1)/60).^0.025-(46.8*(1/60).^0.025);
    
    timeTillGlue = timeTillGlue*60;    
    new = 46.8*((timeTillGlue+1).^0.01-1);
end