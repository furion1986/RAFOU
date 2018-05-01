-- Interface
-- Author: Furion
-- DateCreated: 4/17/2018 4:22:12 PM
--------------------------------------------------------------
print("Loaded");
--------------------------------------------------------------
function RVLOnPlayerTurnActivated(ePlayer:number, bFirstTimeThisTurn:boolean)
	local iPlayer		:table = Players[ePlayer];
	local iLeader	:string = PlayerConfigurations[ePlayer]:GetLeaderTypeName();
	local iBalance	:number = iPlayer:GetTreasury():GetGoldBalance();
	if (iLeader == "LEADER_HOSTER_TULLY") then
		local aPlayers = PlayerManager.GetAlive();
		for _, pPlayer in ipairs(aPlayers) do
			local civ	:string = PlayerConfigurations[pPlayer:GetID()]:GetCivilizationTypeName();
			local civInfo:table	= GameInfo.Civilizations[civ];
			if (civInfo.StartingCivilizationLevelType == "CIVILIZATION_LEVEL_CITY_STATE") then
				local iAnnexCost :number = 320;
				local pPlayerCities	:table = pPlayer:GetCities();
				for _, pCity in pPlayerCities:Members() do
					local pDistrictCount			:number = pCity:GetDistricts():GetCount();
					iAnnexCost = iAnnexCost + (54*3*pDistrictCount);
					local pPopulation 				:number= pCity:GetPopulation();
					iAnnexCost = iAnnexCost + 50*(pPopulation-1);
					local pCityBuildings = pCity:GetBuildings();
					local pCityPlots:table = Map.GetCityPlots():GetPurchasedPlots( pCity );
					if (pCityPlots ~= nil) then
						for _,plotID in pairs(pCityPlots) do
							local pBuildingTypes:table = pCityBuildings:GetBuildingsAtLocation(plotID);
							for _, type in ipairs(pBuildingTypes) do
								local building = GameInfo.Buildings[type]; 
								iAnnexCost = iAnnexCost + GameInfo.Buildings[building.BuildingType].Cost;
							end
							--End of looping through buildings
						end
						--End of looping through plots
					end
					--End of plots
				end
				--End of Looping through cities
				iAnnexCost = iAnnexCost + iPlayer:GetInfluence():GetLevyMilitaryCost( pPlayer );
				local pGameSpeedMultiplier =  (GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier)/100;
				iAnnexCost = iAnnexCost*pGameSpeedMultiplier;
				local iSuzerainID = pPlayer:GetInfluence():GetSuzerain();
				local pEnvoyTokens = pPlayer:GetInfluence():GetTokensReceived(ePlayer);
				if  (iSuzerainID == ePlayer) and (iBalance > iAnnexCost) then
					local annexProb = math.random(1,3);
					if annexProb == 1 then
						print("Hoster Tully is trying to Annex a City-State!");
						LuaEvents.AI_Tully_AnnexCityState(ePlayer, pPlayer:GetID(), pEnvoyTokens, iAnnexCost);
					end
				end
				--End of Calling LUA Event
			end
			--End of if is City-States
		end
		--End of Loop Through Players
	end
	--End of If is Tully
end

function RAFOnLoadScreenClose()
	Events.PlayerTurnActivated.Add(RVLOnPlayerTurnActivated);
end
----------Events----------
Events.LoadScreenClose.Add(RAFOnLoadScreenClose);