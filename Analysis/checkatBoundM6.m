function x = checkatBoundM6(model, upper, lower)
% Check whether model 6 fit should be excluded as a boundary/weak-amplitude fit.

if round(model.peak2) - round(model.peak1) < 2 || ...
        round(model.peak3) - round(model.peak2) < 2
    x = true;
else
    x = false;
end

if abs(model.A) < 0.01 || ...
        (abs(model.ratio1) * abs(model.A)) < 0.05 || ...
        (abs(model.ratio2) * abs(model.A)) < 0.05
    x = true;
end

end
