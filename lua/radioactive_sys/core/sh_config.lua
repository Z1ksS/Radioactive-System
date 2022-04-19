radAreaSys.config = radAreaSys.config or {}

radAreaSys.config.HazmatEntityModel = "models/props_c17/suitcase_passenger_physics.mdl" -- entities model

radAreaSys.config.HazmatSuitModel = "models/player/vad36cccp/bohazmat1.mdl" --write here hazmat suit model, which will change for player
radAreaSys.config.OnEquipPhrase = "You have hazmat suit!" --it will print in player's chat, if player already is using hazmat

radAreaSys.config.NeedPhraseOnEntity = false --if false, then phrase above entity won't show
radAreaSys.config.PhraseOnEntity = "Use [E] to equip hazmat suit" --phrase 