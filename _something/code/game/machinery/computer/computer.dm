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

/obj/machinery/computer/cargo/express/samara_cargo/proc/is_sec(mob/user)
	var/datum/job/job = user?.mind?.assigned_role
	return istype(job, /datum/job/sectrooper) || istype(job, /datum/job/secmed)

/obj/machinery/computer/cargo/express/samara_cargo/proc/is_group(mob/user)
	var/datum/job/job = user?.mind?.assigned_role
	return istype(job, /datum/job/grouptrooper) || istype(job, /datum/job/groupmed)

/obj/machinery/computer/cargo/express/samara_cargo/proc/get_budget(mob/user)
	if(is_sec(user))
		return GLOB.secbudget
	if(is_group(user))
		return GLOB.groupbudget
	return 0

/obj/machinery/computer/cargo/express/samara_cargo/proc/spend_budget(mob/user, amount)
	if(is_sec(user))
		GLOB.secbudget -= amount
	else if(is_group(user))
		GLOB.groupbudget -= amount

/obj/machinery/computer/cargo/express/samara_cargo/ui_data(mob/user)
	var/list/data = list()
	data["points"] = get_budget(user)
	message = "Sales are near-instantaneous - please choose carefully."
	if(SSshuttle.supplyBlocked)
		message = blockade_warning
	data["message"] = message
	// Mapload runs before SSshuttle fills supply_packs, so the list built in Initialize is empty
	if(!length(meme_pack_data))
		packin_up()
	data["supplies"] = meme_pack_data
	return data

/obj/machinery/computer/cargo/express/samara_cargo/ui_act(action, params, datum/tgui/ui)
	// Not calling the express parent: its "add" would bill the cargo budget and land in the cargo bay
	if(action != "add")
		return
	add_fingerprint(usr)
	update_last_used(usr)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_EXPRESSPOD_CONSOLE))
		say("Railgun recalibrating. Stand by.")
		return
	var/area/landing_area
	if(is_sec(usr))
		landing_area = GLOB.areas_by_type[/area/secclean_cargo]
	else if(is_group(usr))
		landing_area = GLOB.areas_by_type[/area/groupclean_cargo]
	else
		return
	if(!landing_area)
		WARNING("[src] could not find its landing area, using its own.")
		landing_area = get_area(src)
	var/id = params["id"]
	id = text2path(id) || id
	var/datum/supply_pack/pack = SSshuttle.supply_packs[id]
	if(!istype(pack))
		CRASH("Unknown supply pack id given by samara order console ui. ID: [params["id"]]")
	// Same filters as packin_up(), so ids not offered in the catalog can't be ordered
	if(pack.hidden || pack.special || (pack.contraband && !contraband))
		return
	var/cost = pack.get_cost()
	if(cost > get_budget(usr))
		say("Insufficient credits.")
		return
	var/list/empty_turfs
	for(var/turf/open/floor/T in landing_area.contents)
		if(T.is_blocked_turf())
			continue
		LAZYADD(empty_turfs, T)
		CHECK_TICK
	if(!length(empty_turfs))
		say("Landing zone obstructed.")
		return
	// Budget and cooldown can change during CHECK_TICK
	if(cost > get_budget(usr) || TIMER_COOLDOWN_CHECK(src, COOLDOWN_EXPRESSPOD_CONSOLE))
		return
	var/order_name = "*None Provided*"
	var/order_rank = "*None Provided*"
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		order_name = H.get_authentification_name()
		order_rank = H.get_assignment(hand_first = TRUE)
	else if(issilicon(usr))
		order_name = usr.real_name
		order_rank = "Silicon"
	var/datum/supply_order/SO = new(pack, order_name, order_rank, usr.ckey, "")
	TIMER_COOLDOWN_START(src, COOLDOWN_EXPRESSPOD_CONSOLE, 5 SECONDS)
	spend_budget(usr, cost)
	new /obj/effect/pod_landingzone(pick(empty_turfs), pack.special_pod || podType, SO)
	update_appearance()
	return TRUE

