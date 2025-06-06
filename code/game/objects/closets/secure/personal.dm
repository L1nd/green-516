/obj/structure/closet/secure_closet/personal/var/registered_name = null
/obj/structure/closet/secure_closet/personal/req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)

/obj/structure/closet/secure_closet/personal/New()
	..()
	spawn(2)
		new /obj/item/device/assembly/signaler(src)
		new /obj/item/wardrobe/assistant(src)

		var/obj/item/weapon/storage/backpack/BPK = new /obj/item/weapon/storage/backpack(src)
		var/obj/item/weapon/storage/box/newbox = new(BPK)
		new /obj/item/weapon/pen(newbox)
	return

/obj/structure/closet/secure_closet/personal/patient/New()
	..()
	contents = list()
	spawn(4)
		new /obj/item/clothing/suit/patientgown( src )
		new /obj/item/clothing/under/color_/white( src )
		new /obj/item/clothing/shoes/white( src )
	return


/obj/structure/closet/secure_closet/personal/cabinet/New()
	..()
	spawn(4)
		contents = list()
		new /obj/item/weapon/storage/backpack/satchel/withwallet( src )
		new /obj/item/device/radio/headset( src )
	return

/obj/structure/closet/secure_closet/personal/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (src.opened)
		if (istype(W, /obj/item/weapon/grab))
			src.MouseDrop_T(W:affecting, user)      //act like they were dragged onto the closet
		user.drop_item()
		if (W) W.loc = src.loc
	else if(istype(W, /obj/item/weapon/card/id))
		if(src.broken)
			user << "\red It appears to be broken."
			return
		var/obj/item/weapon/card/id/I = W
		if(!I || !I.registered_name)	return
		if(src.allowed(user) || !src.registered_name || (istype(I) && (src.registered_name == I.registered_name)))
			//they can open all lockers, or nobody owns this, or they own this locker
			src.locked = !( src.locked )
			if(src.locked)	src.icon_state = src.icon_locked
			else	src.icon_state = src.icon_closed

			if(!src.registered_name)
				src.registered_name = I.registered_name
				src.desc = "Owned by [I.registered_name]."
				src.name = "Personal Closet - [I.registered_name]"
		else
			user << "\red Access Denied"

	else if( (istype(W, /obj/item/weapon/card/emag)||istype(W, /obj/item/weapon/melee/energy/blade)) && !src.broken)
		broken = 1
		locked = 0
		desc = "It appears to be broken."
		icon_state = src.icon_broken
		if(istype(W, /obj/item/weapon/melee/energy/blade))
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(5, 0, src.loc)
			spark_system.start()
			playsound(src.loc, 'blade1.ogg', 50, 1)
			playsound(src.loc, "sparks", 50, 1)
			for(var/mob/O in viewers(user, 3))
				O.show_message("\blue The locker has been sliced open by [user] with an energy blade!", 1, "\red You hear metal being sliced and sparks flying.", 2)

	else if(istype(W, /obj/item/device/multitool) && !src.broken)
		var/obj/item/device/multitool/multi = W
		if(multi.is_used)
			user << "\red This multitool is already in use!"
			return
		multi.is_used = 1
		user << "\red Resetting circuitry(0/6)..."
		playsound(user, 'lockreset.ogg', 50, 1)
		var/obj/structure/closet/secure_closet/crat = src
		src = null
		if(do_mob(user, crat, 200))
			user << "\red Resetting circuitry(1/6)..."
			for(var/mob/O in viewers(world.view, user))
				if(O != user)
					O.show_message(text("\red <B>[] picks in wires of the [] with a multitool.</B>", user, crat), 1)
			if(do_mob(user, crat, 200))
				user << "\red Resetting circuitry(2/6)..."
				for(var/mob/O in viewers(world.view, user))
					if(O != user)
						O.show_message(text("\red <B>[] picks in wires of the [] with a multitool.</B>", user, crat), 1)
				if(do_mob(user, crat, 200))
					user << "\red Resetting circuitry(3/6)..."
					for(var/mob/O in viewers(world.view, user))
						if(O != user)
							O.show_message(text("\red <B>[] picks in wires of the [] with a multitool.</B>", user, crat), 1)
					if(do_mob(user, crat, 200))
						user << "\red Resetting circuitry(4/6)..."
						for(var/mob/O in viewers(world.view, user))
							if(O != user)
								O.show_message(text("\red <B>[] picks in wires of the [] with a multitool.</B>", user, crat), 1)
						if(do_mob(user, crat, 200))
							user << "\red Resetting circuitry(5/6)..."
							for(var/mob/O in viewers(world.view, user))
								if(O != user)
									O.show_message(text("\red <B>[] picks in wires of the [] with a multitool.</B>", user, crat), 1)
							if(do_mob(user, crat, 200))
								crat.locked = !crat.locked
								if(crat.locked)
									crat.icon_state = crat.icon_locked
									user << "\blue You enable the locking modules."
									for(var/mob/O in viewers(world.view, user))
										if(O != user)
											O.show_message(text("\red <B>[] locks [] with a multitool.</B>", user, crat), 1)
								else
									crat.icon_state = crat.icon_closed
									user << "\blue You disable the locking modules."
									for(var/mob/O in viewers(world.view, user))
										if(O != user)
											O.show_message(text("\red <B>[] unlocks [] with a multitool.</B>", user, crat), 1)
		multi.is_used = 0
		return

	else
		user << "\red Access Denied"
	return
