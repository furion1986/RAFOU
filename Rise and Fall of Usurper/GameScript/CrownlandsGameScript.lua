-- Crownlands Trait
-- Author: Furion
-- DateCreated: 4/16/2018 2:44:22 PM
--------------------------------------------------------------
print("Loaded")
--------------------------------------------------------------
-- UTILITY FUNCTIONS
--CivilizationHasTrait
function CivilizationHasTrait(sCiv, sTrait)
	for tRow in GameInfo.CivilizationTraits() do
		if (tRow.CivilizationType == sCiv and tRow.TraitType == sTrait) then
			return true;
		end
	end
	return false;
end

function LeaderHasTrait(sLeader, sTrait)
	for tRow in GameInfo.LeaderTraits() do
		if (tRow.LeaderType == sLeader and tRow.TraitType == sTrait) then return true end
	end
	return false;
end
----------Set Civilization Trait to The Crownlands----------
local sFireAndBlood = "TRAIT_CIVILIZATION_FIRE_AND_BLOOD";
local sTheSilverPrince = "TRAIT_THE_SILVER_PRINCE";

----------Change Settler to Builder----------
function RTOnCityAddedToMap(ownerPlayerID:number, cityID:number)
	local pPlayer = Players[ownerPlayerID];
	local pPlayerConfig = PlayerConfigurations[ownerPlayerID];
	local sCiv = pPlayerConfig:GetCivilizationTypeName();
	print(sCiv);
	if (not CivilizationHasTrait(sCiv,sFireAndBlood)) then return; end --Test if current player is The Crownlands
	
	--See if already have captical city--
	local pCapitalCity:table = pPlayer:GetCities():GetCapitalCity();
	if pCapitalCity ~= nil then
		--Loop Through Player Units--
		local pPlayerUnits:table = pPlayer:GetUnits();
		for i, pUnit in pPlayerUnits:Members() do
			local unitType = GameInfo.Units[pUnit:GetType()];
			if unitType.UnitType == "UNIT_SETTLER" then
				local unitX = pUnit:GetX();
				local unitY = pUnit:GetY();
				UnitManager.Kill(pUnit, false);
				pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BUILDER"].Index, unitX, unitY);
			end
		end
	end
end

function RTOnUnitCaptured( currentUnitOwner, unitID, owningPlayer, capturingPlayer )
	local pPlayer = Players[capturingPlayer];
	local pPlayerConfig = PlayerConfigurations[capturingPlayer];
	local sCiv = pPlayerConfig:GetCivilizationTypeName();
	print(sCiv);
	if (not CivilizationHasTrait(sCiv,sFireAndBlood)) then return; end --Test if current player is The Crownlands
	
	--See if already have captical city--
	local pCapitalCity:table = pPlayer:GetCities():GetCapitalCity();
	if pCapitalCity ~= nil then
		local pUnit = UnitManager.GetUnit(capturingPlayer, unitID);
		local unitType = GameInfo.Units[pUnit:GetType()];
		if unitType.UnitType == "UNIT_SETTLER" then
			local unitX = pUnit:GetX();
			local unitY = pUnit:GetY();
			UnitManager.Kill(pUnit, false);
			pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BUILDER"].Index, unitX, unitY);
		end
	end
end

function RTOnUnitAdded(playerID, unitID)
	local pPlayer = Players[playerID];
	local pPlayerConfig = PlayerConfigurations[playerID];
	local sCiv = pPlayerConfig:GetCivilizationTypeName();
	print(sCiv);
	if (not CivilizationHasTrait(sCiv,sFireAndBlood)) then return; end --Test if current player is The Crownlands
	
	--See if already have captical city--
	local pCapitalCity:table = pPlayer:GetCities():GetCapitalCity();
	if pCapitalCity ~= nil then
		local pUnit = UnitManager.GetUnit(playerID, unitID);
		local unitType = GameInfo.Units[pUnit:GetType()];
		if unitType.UnitType == "UNIT_SETTLER" then
			local unitX = pUnit:GetX();
			local unitY = pUnit:GetY();
			UnitManager.Kill(pUnit, false);
			pPlayer:GetUnits():Create(GameInfo.Units["UNIT_BUILDER"].Index, unitX, unitY);
		end		
	end
end

--Dragon Decrease Loyalty--

function RTOnPlayerTurnActivated(ePlayer:number, bFirstTimeThisTurn:boolean)
	local pPlayer = Players[ePlayer];
	local pPlayerCities	:table = pPlayer:GetCities();
	--Loop through cities
	for _, pCity in pPlayerCities:Members() do
		--print("Looping through cities");
		local cityX = pCity:GetX();
		local cityY = pCity:GetY();
		--Find Dragons--
		local aPlayers = PlayerManager.GetAlive();
		for _, iPlayer in ipairs(aPlayers) do
			local iPlayerUnits = iPlayer:GetUnits();
			for i, iUnit in iPlayerUnits:Members() do
				local iUnitType = GameInfo.Units[iUnit:GetType()].UnitType;
				--print(iUnitType);
				if (iUnitType == "UNIT_TARGARYEN_DRAGON") and (iUnit:GetOwner() ~= ePlayer) then
					local unitX = iUnit:GetX();
					local unitY = iUnit:GetY();
					local distanceToCity = Map.GetPlotDistance(cityX, cityY ,unitX, unitY);
					--print(tostring(distanceToCity));
					if distanceToCity <= 6 then
						--print("Dragon Makes City Loose Loyalty!");
						pCity:ChangeLoyalty(-5);
					else
						pCity:ChangeLoyalty(-1);
					end
				end
			end
		end
	end
end

----------In Game Events----------
function RVLOnLoadScreenClose()
	Events.CityAddedToMap.Add(RTOnCityAddedToMap);
	Events.UnitCaptured.Add(RTOnUnitCaptured);
	Events.UnitAddedToMap.Add(RTOnUnitAdded);
	Events.PlayerTurnActivated.Add(RTOnPlayerTurnActivated);
end
----------Events----------
Events.LoadScreenClose.Add(RVLOnLoadScreenClose);