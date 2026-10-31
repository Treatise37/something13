/obj/machinery/computer/cargo/express/samara_cargo
	name = "Samara"
	desc = "This console allows the user to purchase a package \
		with 1/40th of the delivery time: made possible by Nanotrasen's new \"1500mm Orbital Railgun\".\
		All sales are near instantaneous - please choose carefully"
	icon_screen = "supply_express"
	circuit = /obj/item/circuitboard/computer/cargo/express
	blockade_warning = "Bluespace instability detected. Delivery impossible."
	req_access = null
	is_express = TRUE
	landingzone = null

/obj/machinery/computer/cargo/express/samara_cargo/Initialize(mapload)
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/samara_cargo/on_construction()
	. = ..()
	packin_up()

/obj/machinery/computer/cargo/express/samara_cargo/Destroy()
	if(beacon)
		beacon.unlink_console()
	return ..()

/obj/machinery/computer/cargo/express/samara_cargo/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SamaraCargo", name)
		ui.open()

/obj/machinery/computer/cargo/express/samara_cargo/ui_data(mob/user)
	var/list/data = list()
	data["locked"] = FALSE
	data["points"] = 0
	if(istype(user.mind?.assigned_role, /datum/job/sectrooper) || istype(user.mind?.assigned_role, /datum/job/secmed))
		data["points"] = GLOB.secbudget
	else if(istype(user.mind?.assigned_role, /datum/job/grouptrooper) || istype(user.mind?.assigned_role, /datum/job/groupmed))
		data["points"] = GLOB.groupbudget
	data["siliconUser"] = user.has_unlimited_silicon_privilege
	data["printMsg"] = cooldown > 0 ? "Print Beacon for [BEACON_COST] credits ([cooldown])" : "Print Beacon for [BEACON_COST] credits"//buttontext for printing beacons
	data["supplies"] = list()
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	if(!meme_pack_data)
		packin_up()
		stack_trace("There was no pack data for [src]")
	data["supplies"] = meme_pack_data
	if (cooldown > 0)//cooldown used for printing beacons
		cooldown--
	return data

/obj/machinery/computer/cargo/express/samara_cargo/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("add")//Generate Supply Order first
			if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_EXPRESSPOD_CONSOLE))
				say("Railgun recalibrating. Stand by.")
				return
			var/id = params["id"]
			id = text2path(id) || id
			var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
			if(!istype(pack))
				CRASH("Unknown supply pack id given by express order console ui. ID: [params["id"]]")
			var/name = "*None Provided*"
			var/rank = "*None Provided*"
			var/ckey = usr.ckey
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				name = H.get_authentification_name()
				rank = H.get_assignment(hand_first = TRUE)
			else if(issilicon(usr))
				name = usr.real_name
				rank = "Silicon"
			var/reason = ""
			var/list/empty_turfs
			var/datum/supply_order/SO = new(pack, name, rank, ckey, reason)
			var/points_to_check
			if(istype(usr.mind?.assigned_role, /datum/job/sectrooper) || istype(usr.mind?.assigned_role, /datum/job/secmed))
				points_to_check = GLOB.secbudget
			else if(istype(usr.mind?.assigned_role, /datum/job/grouptrooper) || istype(usr.mind?.assigned_role, /datum/job/groupmed))
				points_to_check = GLOB.groupbudget
			if(SO.pack.get_cost() <= points_to_check)
				var/LZ
				if(istype(usr.mind?.assigned_role, /datum/job/sectrooper) || istype(usr.mind?.assigned_role, /datum/job/secmed))
					landingzone = get_area(/area/secclean_cargo)
				else if(istype(usr.mind?.assigned_role, /datum/job/grouptrooper) || istype(usr.mind?.assigned_role, /datum/job/groupmed))
					landingzone = get_area(/area/secclean_cargo)
				if (!landingzone)
					WARNING("[src] WHERE ARE YOU????")
					landingzone = get_area(src)
				for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
					if(T.is_blocked_turf())
						continue
					LAZYADD(empty_turfs, T)
					CHECK_TICK
				if(empty_turfs?.len)
					LZ = pick(empty_turfs)
				if (SO.pack.get_cost() <= points_to_check && LZ)//we need to call the cost check again because of the CHECK_TICK call
					TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
					if(istype(usr.mind?.assigned_role, /datum/job/sectrooper) || istype(usr.mind?.assigned_role, /datum/job/secmed))
						GLOB.secbudget -= SO.pack.get_cost()
					else if(istype(usr.mind?.assigned_role, /datum/job/grouptrooper) || istype(usr.mind?.assigned_role, /datum/job/groupmed))
						GLOB.groupbudget -= SO.pack.get_cost()
					if(pack.special_pod)
						new /obj/effect/pod_landingzone(LZ, pack.special_pod, SO)
					else
						new /obj/effect/pod_landingzone(LZ, podType, SO)
					. = TRUE
					update_appearance()

