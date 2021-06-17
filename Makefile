stg:
	jets clean:build
	JETS_ENV=test jets deploy
prod:
	jets clean:build
	JETS_ENV=production jets deploy
