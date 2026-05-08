function x = checkatBoundM2(model, upper, lower)
% Check whether model 2 fit should be excluded as a boundary/weak-amplitude fit.

if round(model.peak2) - round(model.peak1) < 2
    x = true;
else
    x = false;
end

if abs(model.A) < 0.05 || (abs(model.ratio) * abs(model.A)) < 0.05
    x = true;
end

end
