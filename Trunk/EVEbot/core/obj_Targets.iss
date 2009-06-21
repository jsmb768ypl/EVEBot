
/*
Officer spawns appear in their home region, or in any region where their
faction normally appears, but *only* in systems with -0.8 or below true
sec rating.

Faction: Guristas/Pithi/Dread Guristas
Home Region: Venal
Officers:
Estamel
Vepas
Thon
Kaikka


Faction: Angels/Gisi/Domination
Home Region: Curse
Officers:
Tobias
Gotan
Hakim
Mizuro

Faction: Serpentis/Coreli/Shadow:
Home Region: Fountain
Officers:
Cormack
Setele
Tuvan
Brynn

Faction: Sanshas/Centi/True Sansha:
Home Region: Stain
Officers:
Chelm
Vizan
Selynne
Brokara

Faction: Blood/Corpi/Dark Blood:
Home Region: Not sure actually... Delve?
Officers:
Draclira
Ahremen
Raysere
Tairei
*/

objectdef obj_Targets
{
	variable string SVN_REVISION = "$Rev$"
	variable int Version

	variable index:int TargetQueue
	variable index:int TargetQueueOverride

	variable index:int DefensiveQueue
	variable index:int DefensiveQueueOverride

	variable int ReservedDefensiveSlots = 2

	variable index:string PriorityTargets
	variable iterator PriorityTarget

	variable index:string ChainTargets
	variable iterator ChainTarget

	variable index:string SpecialTargets
	variable iterator SpecialTarget

	variable bool CheckChain
	variable bool Chaining

	variable bool m_SpecialTargetPresent
	variable set DoNotKillList
	variable bool CheckedSpawnValues = FALSE

	method Initialize()
	{
		m_SpecialTargetPresent:Set[FALSE]

		ReservedDefensiveSlots:Set[${Ship.MaxLockedTargets}]
		while ${ReservedDefensiveSlots} > 2
		{
			ReservedDefensiveSlots:Dec
		}

		; TODO - load this all from XML files

		; Priority targets will be targeted (and killed)
		; before other targets, they often do special things
		; which we cant use (scramble / web / damp / etc)
		; You can specify the entire rat name, for example
		; leave rats that dont scramble which would help
		; later when chaining gets added
		PriorityTargets:Insert["Dire Guristas"]
		PriorityTargets:Insert["Guristas Nullifier"]

		PriorityTargets:Insert["Arch Angel Hijacker"]
		PriorityTargets:Insert["Arch Angel Outlaw"]
		PriorityTargets:Insert["Arch Angel Rogue"]
		PriorityTargets:Insert["Arch Angel Thug"]
		PriorityTargets:Insert["Sansha's Loyal"]

		PriorityTargets:Insert["Guardian Agent"]			/* web/scram */
		PriorityTargets:Insert["Guardian Initiate"]			/* web/scram */
		PriorityTargets:Insert["Guardian Scout"]			/* web/scram */
		PriorityTargets:Insert["Guardian Spy"]				/* web/scram */
		PriorityTargets:Insert["Crook Watchman"]			/* damp */
		PriorityTargets:Insert["Guardian Watchman"]			/* damp */
		PriorityTargets:Insert["Serpentis Watchman"]		/* damp */
		PriorityTargets:Insert["Crook Patroller"]			/* damp */
		PriorityTargets:Insert["Guardian Patroller"]		/* damp */
		PriorityTargets:Insert["Serpentis Patroller"]		/* damp */

		PriorityTargets:Insert["Elder Blood Upholder"]		/* web/scram */
		PriorityTargets:Insert["Elder Blood Worshipper"]	/* web/scram */
		PriorityTargets:Insert["Elder Blood Follower"]		/* web/scram */
		PriorityTargets:Insert["Elder Blood Herald"]		/* web/scram */
		PriorityTargets:Insert["Blood Wraith"]				/* web/scram */
		PriorityTargets:Insert["Blood Disciple"]			/* web/scram */

		; Chain targets will be scanned for the first time
		; and then the script will determin if its safe / alright
		; to chain the belt.
		ChainTargets:Insert["Guristas Destroyer"]
		ChainTargets:Insert["Guristas Conquistador"]
		ChainTargets:Insert["Guristas Eliminator"]
		ChainTargets:Insert["Guristas Exterminator"]
		ChainTargets:Insert["Guristas Massacrer"]
		ChainTargets:Insert["Guristas Usurper"]
		ChainTargets:Insert["Angel Throne"]
		ChainTargets:Insert["Angel Saint"]
		ChainTargets:Insert["Angel Malakim"]
		ChainTargets:Insert["Angel Nephilim"]
		;ChainTargets:Insert["Serpentis Commodore"]	/* 650k */
		ChainTargets:Insert["Serpentis Port Admiral"]	/* 800k */
		ChainTargets:Insert["Serpentis Rear Admiral"]	/* 950k */
		ChainTargets:Insert["Serpentis Flotilla Admiral"]
		ChainTargets:Insert["Serpentis Vice Admiral"]
		ChainTargets:Insert["Serpentis Admiral"]
		ChainTargets:Insert["Serpentis Admiral"]
		ChainTargets:Insert["Serpentis Grand Admiral"]
		ChainTargets:Insert["Serpentis High Admiral"]
		ChainTargets:Insert["Serpentis Lord Admiral"]
		ChainTargets:Insert["Sansha's Lord"]
		ChainTargets:Insert["Sansha's Slave Lord"]
		ChainTargets:Insert["Sansha's Savage Lord"]
		ChainTargets:Insert["Sansha's Mutant Lord"]

		; Special targets will (eventually) trigger an alert
		; This should include haulers / faction / officers
		SpecialTargets:Insert["Dread Guristas"]
		SpecialTargets:Insert["Hakim Stormare"]
		SpecialTargets:Insert["Estamel Tharchon"]
		SpecialTargets:Insert["Kaikka Peunato"]
		SpecialTargets:Insert["Thon Eney"]
		SpecialTargets:Insert["Vepas Minimala"]
		SpecialTargets:Insert["Courier"]
		SpecialTargets:Insert["Ferrier"]
		SpecialTargets:Insert["Gatherer"]
		SpecialTargets:Insert["Harvester"]
		SpecialTargets:Insert["Loader"]
		SpecialTargets:Insert["Bulker"]
		SpecialTargets:Insert["Carrier"]
		SpecialTargets:Insert["Convoy"]
		SpecialTargets:Insert["Hauler"]
		SpecialTargets:Insert["Trailer"]
		SpecialTargets:Insert["Transporter"]
		SpecialTargets:Insert["Trucker"]
		SpecialTargets:Insert["Cormack"]
		SpecialTargets:Insert["Setele"]
		SpecialTargets:Insert["Tuvan"]
		SpecialTargets:Insert["Brynn"]
		SpecialTargets:Insert["Shadow Serpentis"]
		SpecialTargets:Insert["True Sansha"]
		SpecialTargets:Insert["Dark Blood"]

		; Get the iterators
		PriorityTargets:GetIterator[PriorityTarget]
		ChainTargets:GetIterator[ChainTarget]
		SpecialTargets:GetIterator[SpecialTarget]

		DoNotKillList:Clear
	}

	method ResetTargets()
	{
		This.CheckChain:Set[TRUE]
		This.Chaining:Set[FALSE]
		This.CheckedSpawnValues:Set[FALSE]
		This.TotalSpawnValue:Set[0]
	}

	member:bool SpecialTargetPresent()
	{
		return ${m_SpecialTargetPresent}
	}

	member:bool IsPriorityTarget(string name)
	{
		; Loop through the priority targets
		if ${PriorityTarget:First(exists)}
		do
		{
			if ${name.Find[${PriorityTarget.Value}]} > 0
			{
				return TRUE
			}
		}
		while ${PriorityTarget:Next(exists)}

		return FALSE
	}

	member:bool IsSpecialTarget(string name)
	{
			; Loop through the special targets
			if ${SpecialTarget:First(exists)}
			do
			{
				if ${name.Find[${SpecialTarget.Value}]} > 0
				{
					return TRUE
				}
			}
			while ${SpecialTarget:Next(exists)}

			return FALSE
	}

	member:bool PC()
	{
		variable index:entity tgtIndex
		variable iterator tgtIterator

		EVE:DoGetEntities[tgtIndex, CategoryID, CATEGORYID_SHIP]
		tgtIndex:GetIterator[tgtIterator]

		if ${tgtIterator:First(exists)}
		do
		{
			if ${tgtIterator.Value.Owner.CharID} != ${Me.CharID}
			{	/* A player is already present here ! */
				UI:UpdateConsole["Player found ${tgtIterator.Value.Owner}"]
				return TRUE
			}
		}
		while ${tgtIterator:Next(exists)}

		; No other players around
		return FALSE
	}

	member:bool NPC()
	{
		variable index:entity tgtIndex
		variable iterator tgtIterator

		EVE:DoGetEntities[tgtIndex, CategoryID, CATEGORYID_ENTITY]
		UI:UpdateConsole["DEBUG: Found ${tgtIndex.Used} entities."]

		tgtIndex:GetIterator[tgtIterator]
		if ${tgtIterator:First(exists)}
		do
		{
			switch ${tgtIterator.Value.GroupID}
			{
				case GROUP_LARGECOLLIDABLEOBJECT
				case GROUP_LARGECOLLIDABLESHIP
				case GROUP_SENTRYGUN
				case GROUP_CONCORDDRONE
				case GROUP_CUSTOMSOFFICIAL
				case GROUP_POLICEDRONE
				case GROUP_CONVOYDRONE
				case GROUP_FACTIONDRONE
				case GROUP_BILLBOARD
				case GROUP_DEADSPACEOVERSEERSSTRUCTURE
				case GROUP_LARGECOLLIDABLESTRUCTURE
					UI:UpdateConsole["DEBUG: Ignoring entity ${tgtIterator.Value.Group} (${tgtIterator.Value.GroupID})"]
					continue
					break
				default
					UI:UpdateConsole["DEBUG: NPC found: ${tgtIterator.Value.Group} (${tgtIterator.Value.GroupID})"]
					return TRUE
					break
			}
		}
		while ${tgtIterator:Next(exists)}

		; No NPCs around
		return FALSE
	}
	
	/* bool HaveFullAggro(string entities):
	Iterate through entities and determine if any are not targeting me. If so, return FALSE. Otherwise, return TRUE. */
	member:bool HaveFullAggro(string entities)
	{
		variable iterator itrEntities
		${entities}:GetIterator[itrEntities]
		
		if ${itrEntities:First(exists)}
		{
			do
			{
				;If our target is a hauler, it won't be targeting us.
				;Same goes for assorted deadspace entities
				if ${Entity[${itrEntities.Value.EntityID}].Group.Find["Hauler"](exists)} || \
				${Entity[${itrEntities.Value.EntityID}].GroupID} == GROUP_DEADSPACEOVERSEERSSTRUCTURE || \
				${Entity[${itrEntities.Value.EntityID}].GroupID} == GROUP_LARGECOLLIDABLESTRUCTURE
				{
					continue
				}
				if !${Entity[${itrEntities.Value.EntityID}].IsTargetingMe}
				{
					UI:UpdateConsole["DEBUG: obj_Targets - Entity[${itrEntities.Value.EntityID}].Name (${Entity[${itrEntities.Value.EntityID}].Name}) is not targeting me, we don't have full aggro",LOG_DEBUG]
					return FALSE
				}
			}
			while ${itrEntities:Next(exists)}
		}
		return TRUE
	}
	member:bool IsNPCTarget(int groupID)
	{
		switch ${groupID}
		{
			case GROUP_LARGECOLLIDABLEOBJECT
			case GROUP_LARGECOLLIDABLESHIP
			case GROUP_LARGECOLLIDABLESTRUCTURE
			case GROUP_SENTRYGUN
			case GROUP_CONCORDDRONE
			case GROUP_CUSTOMSOFFICIAL
			case GROUP_POLICEDRONE
			case GROUP_CONVOYDRONE
			case GROUP_FACTIONDRONE
			case GROUP_BILLBOARD
			case GROUPID_SPAWN_CONTAINER
			case GROUP_DEADSPACEOVERSEERSSTRUCTURE
				return FALSE
				break
		}

		return TRUE
	}
}

/* Handles Targeting Rats:
	Prioritize jamming/scramming targets, keep chains in order.
*/
objectdef obj_Targets_Rats
{
	variable index:entity Targets
	variable iterator Target

	variable int TotalBattleShipValue
	variable bool UpdateSucceeded

	/* This will be called from obj_Ratter. Make use of the RatCache. */
	member:int CalcTotalBattleShipValue()
	{
		variable int iTotalBSValue = 0
		Ratter.RatCache.Entities:GetIterator[Ratter.RatCache.EntityIterator]
		
		; Determine the total spawn value
		if ${Ratter.RatCache.EntityIterator:First(exists)}
		{
			do
			{
				variable int pos
				variable string NPCName
				variable string NPCGroup
				variable string NPCShipType

				NPCName:Set[${Ratter.RatCache.EntityIterator.Value.Name}]
				NPCGroup:Set[${Ratter.RatCache.EntityIterator.Value.Group}]
				pos:Set[1]
				while ${NPCGroup.Token[${pos}, " "](exists)}
				{
					NPCShipType:Set[${NPCGroup.Token[${pos}, " "]}]
					pos:Inc
				}
				UI:UpdateConsole["NPC: ${NPCName}(${NPCShipType}) ${EVEBot.ISK_To_Str[${EVEDB_Spawns.SpawnBounty[${NPCName}]}]}",LOG_DEBUG]

				;UI:UpdateConsole["DEBUG: Type: ${Ratter.RatCache.EntityIterator.Value.Type}(${Ratter.RatCache.EntityIterator.Value.TypeID})"]
				;UI:UpdateConsole["DEBUG: Category: ${Ratter.RatCache.EntityIterator.Value.Category}(${Ratter.RatCache.EntityIterator.Value.CategoryID})"]

				switch ${Ratter.RatCache.EntityIterator.Value.GroupID}
				{
					case GROUP_LARGECOLLIDABLEOBJECT
					case GROUP_LARGECOLLIDABLESHIP
					case GROUP_LARGECOLLIDABLESTRUCTURE
						continue
						break
					default
						break
				}
				if ${NPCGroup.Find["Battleship"](exists)}
				{
					iTotalBSValue:Inc[${EVEDB_Spawns.SpawnBounty[${NPCName}]}]
				}
			 }
			 while ${Ratter.RatCache.EntityIterator:Next(exists)}
			 UI:UpdateConsole["NPC: Total Battleship Value is ${EVEBot.ISK_To_Str[${iTotalBSValue}]}",LOG_DEBUG]
		}
		return ${iTotalBSValue}
	}

	method UpdateTargetList()
	{
		if ${_MyShip.MaxLockedTargets} == 0
		{
			UI:UpdateConsole["Jammed: Unable to Target"]
			return
		}

		/* MyShip.MaxTargetRange contains the (possibly) damped value */
		if ${Ship.TypeID} == TYPE_RIFTER
		{
			EVE:DoGetEntities[Targets, CategoryID, CATEGORYID_ENTITY, radius, 100000]
		}
		else
		{
			EVE:DoGetEntities[Targets, CategoryID, CATEGORYID_ENTITY, radius, ${_MyShip.MaxTargetRange}]
		}
		This.Targets:GetIterator[This.Target]

		if !${This.Target:First(exists)}
		{
			if ${Ship.IsDamped}
			{
				/* Ship.MaxTargetRange contains the maximum undamped value */
				EVE:DoGetEntities[This.Targets, CategoryID, CATEGORYID_ENTITY, radius, ${Ship.MaxTargetRange}]
				This.Targets:GetIterator[This.Target]

				if !${This.Target:First(exists)}
				{
					UI:UpdateConsole["No targets found"]
					UpdateSucceeded:Set[FALSE]
					return
				}
				else
				{
					UI:UpdateConsole["Damped: Unable to Target"]
					UpdateSucceeded:Set[TRUE]
					return
				}
			}
			else
			{
				UI:UpdateConsole["No targets found..."]
				UpdateSucceeded:Set[FALSE]
				return
			}
		}

		; Chaining means there might be targets here which we shouldnt kill
		variable bool HasTargets = FALSE

		; Start looking for (and locking) priority targets
		; special targets and chainable targets, only priority
		; targets will be locked in this loop
		variable bool HasPriorityTarget = FALSE
		variable bool HasChainableTarget = FALSE
		variable bool HasSpecialTarget = FALSE
		variable bool HasMultipleTypes = FALSE

		m_SpecialTargetPresent:Set[FALSE]
		This:CalcTotalBattleShipValue[]
		if ${This.TotalBattleShipValue} >= ${Config.Combat.MinChainBounty}
		{
			 HasChainableTarget:Set[TRUE]
		}
		UI:UpdateConsole["obj_Targets: Total BS Value: ${This.TotalBattleShipValue}, Minimum: ${Config.Combat.MinChainBounty}, Chainable: ${HasChainableTarget}"]

		if ${This.Target:First(exists)}
		{
			variable int TypeID
			TypeID:Set[${This.Target.Value.TypeID}]
			do
			{
				switch ${This.Target.Value.GroupID}
				{
					case GROUP_LARGECOLLIDABLEOBJECT
					case GROUP_LARGECOLLIDABLESHIP
					case GROUP_LARGECOLLIDABLESTRUCTURE
					case GROUP_SENTRYGUN
					case GROUP_CONCORDDRONE
					case GROUP_CUSTOMSOFFICIAL
					case GROUP_POLICEDRONE
					case GROUP_CONVOYDRONE
					case GROUP_FACTIONDRONE
					case GROUP_BILLBOARD
						continue
						break
					Default
						break
				}

				; If the Type ID is different then there's more then 1 type in the belt
				if ${TypeID} != ${This.Target.Value.TypeID}
				{
					HasMultipleTypes:Set[TRUE]
				}

				; Check for a special target
				if ${This.IsSpecialTarget[${This.Target.Value.Name}]}
				{
					HasSpecialTarget:Set[TRUE]
					m_SpecialTargetPresent:Set[TRUE]
				}

				; Loop through the priority targets
				UI:UpdateConsole["obj_Targets: IsPriorityTarget(${This.Target.Value.Name}): ${Targets.IsPriorityTarget[${This.Target.Value.Name}]}"]
				if ${Targets.IsPriorityTarget[${This.Target.Value.Name}]}
				{
					/* We have a priority target, set the flag true. */
					HasPriorityTarget:Set[TRUE]
					; Yes, is it locked?
					!${Targeting.IsQueued[${This.Target.Value.ID}]}
					{
						/* Queue[ID, Priority, TypeID, Mandatory] */
						; No, report it and lock it.
						UI:UpdateConsole["obj_Targets: Queueing priority target ${This.Target.Value.Name}"]
						Targeting:Queue[${This.Target.Value.ID},5,${RatCache.EntityIterator.Value.TypeID},TRUE]
					}

					; By only saying there's priority targets when they arent
					; locked yet, the npc bot will target non-priority targets
					; after it has locked all the priority targets
					; (saves time once the priority targets are dead)
					if !${This.Target.Value.IsLockedTarget}
					{
						HasPriorityTarget:Set[TRUE]
					}

					; We have targets
					HasTargets:Set[TRUE]
				}
			}
			while ${This.Target:Next(exists)}
		}

		/* if we have priority targets just return until they're dead */
		if ${HasPriorityTarget}
		{
			UI:UpdateConsole["obj_Targets: Have priority target, returning 'til it's DEAD"]
			return
		}

		; Do we need to determine if we need to chain ?
		if ${Config.Combat.ChainSpawns} && ${CheckChain}
		{
			; Is there a chainable target? Is there a special or priority target?
			if ${HasChainableTarget} && !${HasSpecialTarget} && !${HasPriorityTarget}
			{
				Chaining:Set[TRUE]
			}

			; Special exception, if there is only 1 type its most likely
			; a chain in progress
			if !${HasMultipleTypes}
			{
				Chaining:Set[TRUE]
			}

			/* skip chaining if chain solo == false and we are alone */
			if !${Config.Combat.ChainSolo} && ${EVE.LocalsCount} == 1
			{
				;UI:UpdateConsole["NPC: We are alone.  Skip chaining!!"]
				Chaining:Set[FALSE]
			}

			if ${Chaining}
			{
				UI:UpdateConsole["NPC: Chaining Spawn"]
			}
			else
			{
				UI:UpdateConsole["NPC: Not Chaining Spawn"]
			}
			CheckChain:Set[FALSE]
		}

		; If there was a priority target, dont worry about targeting the rest
		if !${HasPriorityTarget} && ${This.Target:First(exists)}
		do
		{
		 switch ${This.Target.Value.GroupID}
		 {
			case GROUP_LARGECOLLIDABLEOBJECT
			case GROUP_LARGECOLLIDABLESHIP
			case GROUP_LARGECOLLIDABLESTRUCTURE
			case GROUP_SENTRYGUN
			case GROUP_CONCORDDRONE
			case GROUP_CUSTOMSOFFICIAL
			case GROUP_POLICEDRONE
			case GROUP_CONVOYDRONE
			case GROUP_FACTIONDRONE
			case GROUP_BILLBOARD
			   continue
			   break
			Default
			   break
		 }

			variable bool DoTarget = FALSE
			if ${Chaining}
			{
				; We're chaining, only kill chainable spawns'
				if ${This.Target.Value.Group.Find["Battleship"](exists)}
				{
				   DoTarget:Set[TRUE]
				}
			}
			else
			{
				; Target everything
				DoTarget:Set[TRUE]
			}

			; override DoTarget to protect partially spawned chains
			if ${DoNotKillList.Contains[${This.Target.Value.ID}]}
			{
				DoTarget:Set[FALSE]
			}

			; Do we have to target this target?
			if ${DoTarget}
			{
				if !${Targeting.IsQueued[${This.Target.Value.ID}]}
				{
					UI:UpdateConsole["Queueing ${This.Target.Value.Name}"]
					Targeting:Queue[${This.Target.Value.ID},1,${This.Target.Value.TypeID},FALSE]
				}

				; Set the return value so we know we have targets
				HasTargets:Set[TRUE]
			}
			else
			{
				if !${DoNotKillList.Contains[${This.Target.Value.ID}]}
				{
					UI:UpdateConsole["NPC: Adding ${This.Target.Value.Name} (${This.Target.Value.ID}) to the \"do not kill list\"!"]
					DoNotKillList:Add[${This.Target.Value.ID}]
				}
				; Make sure (due to auto-targeting) that its not targeted
				if ${Targeting.IsQueued[${This.Target.Value.ID}]}
				{
					Targeting:Remove[${This.Target.Value.ID}]
				}
			}
		}
		while ${This.Target:Next(exists)}

		;if ${HasTargets} && ${Me.ActiveTarget(exists)}
		;{
		;	variable int OrbitDistance
		;	OrbitDistance:Set[${Math.Calc[${_MyShip.MaxTargetRange}*0.40/1000].Round}]
		;	OrbitDistance:Set[${Math.Calc[${OrbitDistance}*1000]}]
		;	Me.ActiveTarget:Orbit[${OrbitDistance}]
		;}

		UpdateSucceeded:Set[${HasTargets}]
		return
	}
}
