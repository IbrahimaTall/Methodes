* This is a model for survival analysis
webuse cancer, clear
stset studytim , failure(died)
ltable studytime died, survival // défautes
ltable studytime died, failure
ltable studytime died, hazard
ltable studytime died, graph notable
