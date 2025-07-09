* This is a model for survival analysis
webuse cancer, clear
ltable studytime died, survival
ltable studytime died, failure
ltable studytime died, hazard
ltable studytime died, graph notable
