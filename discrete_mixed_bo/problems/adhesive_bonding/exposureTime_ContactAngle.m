function [CA] = exposureTime_ContactAngle(exposureTime, contactAngle_inf, contactAngle_0)
    CA = contactAngle_inf + (contactAngle_0-contactAngle_inf).*exp(-5.2*exposureTime);
end