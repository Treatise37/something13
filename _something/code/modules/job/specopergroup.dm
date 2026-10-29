/datum/job/grouptrooper
	title = "SpecOperGroup Trooper"
	department_head = list("pain")
	supervisors = "no-one"

	outfit = /datum/outfit/grouptrooper
	attribute_sheet = /datum/attribute_holder/sheet/job/grouptrooper

/datum/job/grouptrooper/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	//if(ishuman(spawned))
	//	spawned.apply_status_effect(/datum/status_effect/gakster_dissociative_identity_disorder)
	if(!prob(5))
		return
	qdel(spawned.get_item_by_slot(ITEM_SLOT_ID))
	qdel(spawned.get_item_by_slot(ITEM_SLOT_LPOCKET))
	//spawned.equip_to_slot(new /obj/item/cellphone/hacker(spawned.loc), ITEM_SLOT_ID)
	//to_chat(spawned, "")
	//combat_music см в mind.dm

//It is time to equip our warriors...
/datum/outfit/grouptrooper/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(!get_guns)
		return

	var/randback = list(1,2)
	randback = pick(1,2)
	switch(randback)
		if(1)
			back = /obj/item/storage/backpack/satchel/itobe
		if(2)
			back =/obj/item/storage/backpack/satchel/chestrig

	//guns
	var/gun_equip = list(1,2,3,4,5,6,7)
	if(prob(50))
		gun_equip = 7
	else
		gun_equip = pick(1,2,3,4,5,6)
	switch(gun_equip)
		if(1)
			r_hand = /obj/item/gun/ballistic/automatic/remis/abyss
			backpack_contents = list(/obj/item/ammo_box/magazine/a545 = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(2)
			r_hand = /obj/item/gun/ballistic/automatic/remis/smg/bolsa
			backpack_contents = list(/obj/item/ammo_box/magazine/uzi9mm = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(3)
			r_hand = /obj/item/gun/ballistic/shotgun/automatic/combat
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/shotgun/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(4)
			r_hand = /obj/item/gun/ballistic/shotgun/bolas
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(5)
			r_hand = /obj/item/gun/ballistic/automatic/remis/svd
			backpack_contents = list(/obj/item/ammo_box/magazine/a762svd = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(6)
			r_hand = /obj/item/gun/ballistic/rifle/boltaction/remis/federson
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/a276/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(7)
			if(prob(50))//random chance for the colt instead of the glock
				belt = /obj/item/gun/ballistic/automatic/pistol/m1911
				r_pocket = /obj/item/ammo_box/magazine/m45
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
			else if(prob(49))
				belt = /obj/item/gun/ballistic/automatic/pistol/glock17
				r_pocket = /obj/item/ammo_box/magazine/glock9mm
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
			else
				belt = /obj/item/gun/ballistic/revolver/poppy
				r_pocket = /obj/item/ammo_box/magazine/ammo_stack/a500
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)

	//Armor_trollege
	var/armor_equip = list(1,2,3)
	switch(armor_equip)
		if(1) //light
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt
		if(2) // medium
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt/medium
		if(3) // hard
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt/heavy

	if(prob(50))
		head = /obj/item/clothing/head/helmet/heavy
	else if (prob(25))
		head = /obj/item/clothing/head/helmet/medium

	if(prob(50))
		mask = /obj/item/clothing/mask/balaclava

/datum/outfit/grouptrooper
	var/get_guns = TRUE
	name = "SpecOperGroup Trooper"
	uniform = /obj/item/clothing/under/itobe
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots


//MEDIC
/datum/job/groupmed
	title = "SpecOperGroup Medic"
	department_head = list("pain")
	supervisors = "no-one"

	outfit = /datum/outfit/groupmed
	attribute_sheet = /datum/attribute_holder/sheet/job/groupmed

/datum/job/groupmed/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	//if(ishuman(spawned))
	//	spawned.apply_status_effect(/datum/status_effect/gakster_dissociative_identity_disorder)
	if(!prob(5))
		return
	qdel(spawned.get_item_by_slot(ITEM_SLOT_ID))
	qdel(spawned.get_item_by_slot(ITEM_SLOT_LPOCKET))
	//spawned.equip_to_slot(new /obj/item/cellphone/hacker(spawned.loc), ITEM_SLOT_ID)
	//to_chat(spawned, "")
	//combat_music см в mind.dm

//It is time to equip our warriors...
/datum/outfit/groupmed/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(!get_guns)
		return

	var/randback = list(1,2)
	randback = pick(1,2)
	switch(randback)
		if(1)
			back = /obj/item/storage/backpack/satchel/itobe
		if(2)
			back =/obj/item/storage/backpack/satchel/chestrig

	//guns
	var/gun_equip = list(1,2,3,4,5,6,7)
	if(prob(50))
		gun_equip = 7
	else
		gun_equip = pick(1,2,3,4,5,6)
	switch(gun_equip)
		if(1)
			r_hand = /obj/item/gun/ballistic/automatic/remis/abyss
			backpack_contents = list(/obj/item/ammo_box/magazine/a545 = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(2)
			r_hand = /obj/item/gun/ballistic/automatic/remis/smg/bolsa
			backpack_contents = list(/obj/item/ammo_box/magazine/uzi9mm = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(3)
			r_hand = /obj/item/gun/ballistic/shotgun/automatic/combat
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/shotgun/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(4)
			r_hand = /obj/item/gun/ballistic/shotgun/bolas
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/shotgun/bolas/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(5)
			r_hand = /obj/item/gun/ballistic/automatic/remis/svd
			backpack_contents = list(/obj/item/ammo_box/magazine/a762svd = 4,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(6)
			r_hand = /obj/item/gun/ballistic/rifle/boltaction/remis/federson
			backpack_contents = list(/obj/item/ammo_box/magazine/ammo_stack/a276/loaded = 6,
				/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
		if(7)
			if(prob(50))//random chance for the colt instead of the glock
				belt = /obj/item/gun/ballistic/automatic/pistol/m1911
				r_pocket = /obj/item/ammo_box/magazine/m45
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
			else if(prob(49))
				belt = /obj/item/gun/ballistic/automatic/pistol/glock17
				r_pocket = /obj/item/ammo_box/magazine/glock9mm
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)
			else
				belt = /obj/item/gun/ballistic/revolver/poppy
				r_pocket = /obj/item/ammo_box/magazine/ammo_stack/a500
				backpack_contents = list(/obj/item/reagent_containers/hypospray/medipen/retractible/blacktar = 1, /obj/item/flashlight/seclite = 1)

	//Armor_trollege
	var/armor_equip = list(1,2,3)
	switch(armor_equip)
		if(1) //light
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt
		if(2) // medium
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt/medium
		if(3) // hard
			if(prob(50))
				suit = /obj/item/clothing/suit/armor/vest/alt/heavy

	if(prob(50))
		head = /obj/item/clothing/head/helmet/heavy
	else if (prob(25))
		head = /obj/item/clothing/head/helmet/medium

	if(prob(50))
		mask = /obj/item/clothing/mask/balaclava

/datum/outfit/groupmed
	var/get_guns = TRUE
	name = "SpecOperGroup Medic"
	uniform = /obj/item/clothing/under/itobe
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/jackboots
