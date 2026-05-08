function x = checkatBoundM1(model, upper, lower)
% Check whether model 1 fit should be excluded as a boundary/weak-amplitude fit.

if abs(model.A) < 0.05
    x = true;
else
    x = false;
end

end
