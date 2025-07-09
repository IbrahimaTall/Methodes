* This is a model for survival analysis
webuse cancer, clear // Les do
stset studytim , failure(died) // crée des variables _st _d _t _t0
ltable studytime died, survival // défautes
ltable studytime died, failure
ltable studytime died, hazard
ltable studytime died, graph notable
