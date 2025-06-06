/mob/Del()//This makes sure that mobs with clients/keys are not just deleted from the game.
	ghostize(1)
	..()

/atom/proc/relaymove()
	return

/obj/effect/equip_e/process()
	return

/obj/effect/equip_e/proc/done()
	return

/obj/effect/equip_e/New()
	if (!ticker)
		del(src)
		return
	spawn(100)
		del(src)
		return
	..()
	return

/mob/proc/show_message(msg, type, alt, alt_type)//Message, type of message (1 or 2), alternative message, alt message type (1 or 2)
	if(!client)	return
	if (type)
		if ((type & 1 && (disabilities & 128 || (blinded || paralysis))))//Vision related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
		if ((type & 2 && (disabilities & 32 || ear_deaf)))//Hearing related
			if (!( alt ))
				return
			else
				msg = alt
				type = alt_type
				if ((type & 1 && disabilities & 128))
					return
	// Added voice muffling for Issue 41.
	if (stat == 1 || sleeping > 0)
		src << "<I>... You can almost hear someone talking ...</I>"
	else
		src << msg
	return

/mob/proc/findname(msg)
	for(var/mob/M in world)
		if (M.real_name == text("[]", msg))
			return M
	return 0

/mob/proc/movement_delay()
	return 0

/mob/proc/Life()
	return

/mob/proc/update_clothing()
	return

/mob/proc/restrained()
	if (handcuffed)
		return 1
	return

/mob/proc/db_click(text, t1)
	var/obj/item/weapon/W = equipped()
	switch(text)
		if("mask")
			if (wear_mask)
				return
			if (!( W.slot_flags & SLOT_MASK ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if (back)
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.slot_flags & SLOT_BACK ))
				return
			if(istype(W,/obj/item/weapon/twohanded) && W:wielded)
				usr << "<span class='warning'>Unwield the [initial(W.name)] first!</span>"
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
		else
	return



/mob/proc/drop_item_v()
	if (stat == 0)
		drop_item()
	return

/mob/proc/drop_from_slot(var/obj/item/item)
	if(!item)
		return
	if(!(item in contents))
		return
	u_equip(item)
	if (client)
		client.screen -= item
	if (item)
		item.loc = loc
		item.dropped(src)
		if (item)
			item.layer = initial(item.layer)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(item)
	return

/mob/proc/drop_item(var/atom/target)
	var/obj/item/W = equipped()

	if (W)
		u_equip(W)
		if (client)
			client.screen -= W
		if (W)
			W.layer = initial(W.layer)
			if(target)
				W.loc = target.loc
			else
				W.loc = loc
			W.dropped(src)
		var/turf/T = get_turf(loc)
		if (istype(T))
			T.Entered(W)
		update_clothing()
	return

/mob/proc/before_take_item(var/obj/item/item)
	item.loc = null
	item.layer = initial(item.layer)
	u_equip(item)
	return

/mob/proc/get_active_hand()
	if (hand)
		return l_hand
	else
		return r_hand

/mob/proc/get_inactive_hand()
	if (!hand)
		return l_hand
	else
		return r_hand

/mob/proc/put_in_hand(var/obj/item/I)
	if(!I) return
	I.loc = src
	if (hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/put_in_inactive_hand(var/obj/item/I)
	I.loc = src
	if (!hand)
		l_hand = I
	else
		r_hand = I
	I.layer = 20
	update_clothing()

/mob/proc/reset_view(atom/A)
	if (client)
		if (istype(A, /atom/movable))
			client.perspective = EYE_PERSPECTIVE
			client.eye = A
		else
			if (isturf(loc))
				client.eye = client.mob
				client.perspective = MOB_PERSPECTIVE
			else
				client.perspective = EYE_PERSPECTIVE
				client.eye = loc
	return

/mob/proc/equipped()
	if(issilicon(src))
		if(isrobot(src))
			if(src:module_active)
				return src:module_active
	else
		if (hand)
			return l_hand
		else
			return r_hand
		return

/mob/proc/show_inv(mob/user as mob)
	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(handcuffed ? text("<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>") : text("<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>"))]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return



/mob/proc/u_equip(W as obj)
	if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == back)
		back = null
	else if (W == wear_mask)
		wear_mask = null
	update_clothing()
	return


//Attemps to remove an object on a mob.  Will not move it to another area or such, just removes from the mob.
/mob/proc/remove_from_mob(var/obj/O)
	u_equip(O)
	if (client)
		client.screen -= O
	O.layer = initial(O.layer)
	O.screen_loc = null
	return 1


/mob/proc/ret_grab(obj/effect/list_container/mobl/L as obj, flag)
	if ((!( istype(l_hand, /obj/item/weapon/grab) ) && !( istype(r_hand, /obj/item/weapon/grab) )))
		if (!( L ))
			return null
		else
			return L.container
	else
		if (!( L ))
			L = new /obj/effect/list_container/mobl( null )
			L.container += src
			L.master = src
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if (!( L.container.Find(G.affecting) ))
				L.container += G.affecting
				if (G.affecting)
					G.affecting.ret_grab(L, 1)
		if (!( flag ))
			if (L.master == src)
				var/list/temp = list(  )
				temp += L.container
				//L = null
				del(L)
				return temp
			else
				return L.container
	return


/*
/mob/verb/dump_source()

	var/master = "<PRE>"
	for(var/t in typesof(/area))
		master += text("[]\n", t)
		//Foreach goto(26)
	src << browse(master)
	return
*/

/mob/proc/update_flavor_text()
	set src in usr
	if(usr != src)
		usr << "No."
	var/msg = input(usr,"Set the flavor text in your 'examine' verb. Can also be used for OOC notes about your character.","Flavor Text",html_decode(flavor_text)) as message|null

	if(msg != null)
		msg = copytext(msg, 1, MAX_MESSAGE_LEN)
		msg = html_encode(msg)

		flavor_text = msg

/mob/proc/warn_flavor_changed()
	if(flavor_text && flavor_text != "") // don't spam people that don't use it!
		src << "<h2 class='alert'>OOC Warning:</h2>"
		src << "<span class='alert'>Your flavor text is likely out of date! <a href='byond://?src=\ref[src];flavor_change=1'>Change</a></span>"

/mob/proc/print_flavor_text()
	if (flavor_text && flavor_text != "")
		var/msg = dd_replacetext(flavor_text, "\n", " ")
		if(length(msg) <= 40)
			return "\blue [msg]"
		else
			return "\blue [copytext(msg, 1, 37)]... <a href='byond://?src=\ref[src];flavor_more=1'>More...</a>"


/*
/mob/verb/help()
	set name = "Help"
	src << browse('help.html', "window=help")
	return
*/

/mob/Topic(href, href_list)
	if(href_list["mach_close"])
		var/t1 = text("window=[href_list["mach_close"]]")
		machine = null
		src << browse(null, t1)

	if(href_list["teleto"])
		client.jumptoturf(locate(href_list["teleto"]))

	if(href_list["priv_msg"])
		var/mob/M = locate(href_list["priv_msg"])
		if(M)
			//if(src.client && client.muted_complete)
			//	src << "You are muted have a nice day"
			//	return
			if (!ismob(M))
				return

			var/recipient_name = M.key
			if(M.client && M.client.holder && M.client.stealth)
				recipient_name = "Administrator"

			//This should have a check to prevent the player to player chat but I am too tired atm to add it.
			var/t = input("Message:", text("Private message to [recipient_name]"))  as text|null
			if (!t || !usr || !usr.client)
				return
			if (usr.client && usr.client.holder)
				M << "\red Admin PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
				usr << "\blue Admin PM to-<b>[key_name(M, usr, 1)]</b>: [t]"
			else
				if (M)
					if (M.client && M.client.holder)
						M << "\blue Reply PM from-<b>[key_name(usr, M, 1)]</b>: [t]"
					else
						M << "\red Reply PM from-<b>[key_name(usr, M, 0)]</b>: [t]"
					usr << "\blue Reply PM to-<b>[key_name(M, usr, 0)]</b>: [t]"

			log_admin("PM: [key_name(usr)]->[key_name(M)] : [t]")

			//we don't use message_admins here because the sender/receiver might get it too
			for (var/mob/K in world)
				if(K && usr)
					if(K.client && K.client.holder && K.key != usr.key && K.key != M.key)
						K << "<b><font color='blue'>PM: [key_name(usr, K)]->[key_name(M, K)]:</b> \blue [t]</font>"
	if(href_list["flavor_more"])
		usr << browse(text("<HTML><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>", name, dd_replacetext(flavor_text, "\n", "<BR>")), text("window=[];size=500x200", name))
		onclose(usr, "[name]")
	if(href_list["flavor_change"])
		update_flavor_text()
//	..()
	return

/mob/proc/get_damage()
	return health

/mob/proc/UpdateLuminosity()
	ul_SetLuminosity(LuminosityRed, LuminosityGreen, LuminosityBlue)//Current hardcode max at 7, should likely be a const somewhere else
	return 1

/mob/proc/pull_damage()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.health - H.halloss <= config.health_threshold_crit)
			for(var/name in H.organs)
				var/datum/organ/external/e = H.organs[name]
				if((H.lying) && ((e.status & ORGAN_BROKEN && !(e.status & ORGAN_SPLINTED)) || e.status & ORGAN_BLEEDING) && (H.getBruteLoss() + H.getFireLoss() >= 100))
					return 1
					break
		return 0


/mob/MouseDrop(mob/M as mob)
	..()
	if(M != usr) return
	if(usr == src) return
	if(get_dist(usr,src) > 1) return
	if(istype(M,/mob/living/silicon/ai)) return
	if(LinkBlocked(usr.loc,loc)) return
	show_inv(usr)

/atom/movable/verb/pull()
	set name = "Pull"
	set category = "IC"
	set src in oview(1)

	if ( !usr || usr==src || !istype(src.loc,/turf) )	//if there's no person pulling OR the person is pulling themself OR the object being pulled is inside something: abort!
		return

	if(ishuman(usr))
		if(usr.hand) // if he's using his left hand.
			var/datum/organ/external/temp = usr:get_organ("l_hand")
			if(temp.status & ORGAN_DESTROYED)
				usr << "\blue You look at your stump."
				return
		else
			var/datum/organ/external/temp = usr:get_organ("r_hand")
			if(temp.status & ORGAN_DESTROYED)
				usr << "\blue You look at your stump."
				return

	if (!( anchored ))
		usr.pulling = src
		if(ismob(src))
			var/mob/M = src
			if(!istype(usr, /mob/living/carbon))
				M.LAssailant = null
			else
				M.LAssailant = usr
			if(M.pull_damage())
				usr << "\red <B>Pulling \the [M] in their current condition would probably be a bad idea.</B>"
	if(istype(src, /obj/machinery/artifact))
		var/obj/machinery/artifact/A = src
		A.attack_hand(usr)
	return

/mob/proc/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/stool/bed/chair)) // buckling does not restrict hands
		return 0
	return ..()

/mob/proc/is_active()
	return (0 >= usr.stat)

/mob/proc/see(message)
	if(!is_active())
		return 0
	src << message
	return 1

/mob/proc/show_viewers(message)
	for(var/mob/M in viewers())
		M.see(message)

/*
adds a dizziness amount to a mob
use this rather than directly changing var/dizziness
since this ensures that the dizzy_process proc is started
currently only humans get dizzy

value of dizziness ranges from 0 to 1000
below 100 is not dizzy
*/
/mob/proc/make_dizzy(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	dizziness = min(1000, dizziness + amount)	// store what will be new value
													// clamped to max 1000
	if(dizziness > 100 && !is_dizzy)
		spawn(0)
			dizzy_process()


/*
dizzy process - wiggles the client's pixel offset over time
spawned from make_dizzy(), will terminate automatically when dizziness gets <100
note dizziness decrements automatically in the mob's Life() proc.
*/
/mob/proc/dizzy_process()
	is_dizzy = 1
	while(dizziness > 100)
		if(client)
			var/amplitude = dizziness*(sin(dizziness * 0.044 * world.time) + 1) / 70
			client.pixel_x = amplitude * sin(0.008 * dizziness * world.time)
			client.pixel_y = amplitude * cos(0.008 * dizziness * world.time)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_dizzy = 0
	if(client)
		client.pixel_x = 0
		client.pixel_y = 0

// jitteriness - copy+paste of dizziness

/mob/proc/make_jittery(var/amount)
	if(!istype(src, /mob/living/carbon/human)) // for the moment, only humans get dizzy
		return

	jitteriness = min(1000, jitteriness + amount)	// store what will be new value
													// clamped to max 1000
	if(jitteriness > 100 && !is_jittery)
		spawn(0)
			jittery_process()


// Typo from the oriignal coder here, below lies the jitteriness process. So make of his code what you will, the previous comment here was just a copypaste of the above.
/mob/proc/jittery_process()
	var/old_x = pixel_x
	var/old_y = pixel_y
	is_jittery = 1
	while(jitteriness > 100)
//		var/amplitude = jitteriness*(sin(jitteriness * 0.044 * world.time) + 1) / 70
//		pixel_x = amplitude * sin(0.008 * jitteriness * world.time)
//		pixel_y = amplitude * cos(0.008 * jitteriness * world.time)

		var/amplitude = min(4, jitteriness / 100)
		pixel_x = rand(-amplitude, amplitude)
		pixel_y = rand(-amplitude/3, amplitude/3)

		sleep(1)
	//endwhile - reset the pixel offsets to zero
	is_jittery = 0
	pixel_x = old_x
	pixel_y = old_y

/mob/Stat()
	..()

	statpanel("Status")

	if (client && client.holder)
		stat(null, "([x], [y], [z])")
		stat(null, "CPU: [world.cpu]")
		stat(null, "Controller: [controllernum]")
		if (master_controller)
			stat(null, "Current Iteration: [controller_iteration]")

	if (spell_list.len)

		for(var/obj/effect/proc_holder/spell/S in spell_list)
			switch(S.charge_type)
				if("recharge")
					statpanel("Spells","[S.charge_counter/10.0]/[S.charge_max/10]",S)
				if("charges")
					statpanel("Spells","[S.charge_counter]/[S.charge_max]",S)
				if("holdervar")
					statpanel("Spells","[S.holder_var_type] [S.holder_var_amount]",S)



// facing verbs
/mob/proc/canface()
	if(!canmove)						return 0
	if(client.moving)					return 0
	if(world.time < client.move_delay)	return 0
	if(stat==2)							return 0
	if(anchored)						return 0
	if(monkeyizing)						return 0
	if(restrained())					return 0
	return 1


/mob/verb/eastface()
	set hidden = 1
	if(!canface())	return 0
	dir = EAST
	client.move_delay += movement_delay()
	return 1


/mob/verb/westface()
	set hidden = 1
	if(!canface())	return 0
	dir = WEST
	client.move_delay += movement_delay()
	return 1


/mob/verb/northface()
	set hidden = 1
	if(!canface())	return 0
	dir = NORTH
	client.move_delay += movement_delay()
	return 1


/mob/verb/southface()
	set hidden = 1
	if(!canface())	return 0
	dir = SOUTH
	client.move_delay += movement_delay()
	return 1


/mob/proc/IsAdvancedToolUser()//This might need a rename but it should replace the can this mob use things check
	return 0
/*
/mob/proc/createGeas()

	var/obj/effect/stop/S
	for(var/obj/effect/stop/temp in loc)
		if(temp.victim == src)
			S = temp

	if(!S)
		S = new /obj/effect/stop
		S.victim = src
		S.loc = src.loc
		geaslist += S

	return
*/

/mob/proc/Stun(amount)
	if(canstun)
		stunned = max(max(stunned,amount),0) //can't go below 0, getting a low amount of stun doesn't lower your current stun
//		if(stunned)
//			createGeas()
	else
		if(istype(src, /mob/living/carbon/alien))	// add some movement delay
			var/mob/living/carbon/alien/Alien = src
			Alien.move_delay_add = min(Alien.move_delay_add + round(amount / 2), 10) // a maximum delay of 10
	return

/mob/proc/SetStunned(amount) //if you REALLY need to set stun to a set amount without the whole "can't go below current stunned"
	if(canstun)
		stunned = max(amount,0)
//		if(stunned)
//			createGeas()
	return

/mob/proc/AdjustStunned(amount)
	if(canstun)
		stunned = max(stunned + amount,0)
//		if(stunned)
//			createGeas()
	return

/mob/proc/Weaken(amount)
	if(canweaken)
		weakened = max(max(weakened,amount),0)
//		if(weakened)
//			createGeas()
	return

/mob/proc/SetWeakened(amount)
	if(canweaken)
		weakened = max(amount,0)
//		if(weakened)
//			createGeas()
	return

/mob/proc/AdjustWeakened(amount)
	if(canweaken)
		weakened = max(weakened + amount,0)
//		if(weakened)
//			createGeas()
	return

/mob/proc/Paralyse(amount)
	paralysis = max(max(paralysis,amount),0)
//	if(paralysis)
//		createGeas()
	return

/mob/proc/SetParalysis(amount)
	paralysis = max(amount,0)
	return
//	if(paralysis)
//		createGeas()

/mob/proc/AdjustParalysis(amount)
	paralysis = max(paralysis + amount,0)
//	if(paralysis)
//		createGeas()
	return

/mob/proc/Sleeping(amount)
	sleeping = max(max(sleeping,amount),0)
//	if(sleeping)
//		createGeas()
	return

/mob/proc/SetSleeping(amount)
	sleeping = max(amount,0)
	return
//	if(sleeping)
//		createGeas()


/mob/proc/AdjustSleeping(amount)
	sleeping = max(sleeping + amount,0)
//	if(sleeping)
//		createGeas()
	return

/mob/proc/Resting(amount)
	resting = max(max(resting,amount),0)
//	if(resting)
//		createGeas()
	return

/mob/proc/SetResting(amount)
	resting = max(amount,0)
	return
//	if(resting)
//		createGeas()

/mob/proc/AdjustResting(amount)
	resting = max(resting + amount,0)
//	if(resting)
//		createGeas()
	return


// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching

/mob/proc/getBruteLoss()
	return bruteloss

/mob/proc/adjustBruteLoss(var/amount)
	bruteloss = max(bruteloss + amount, 0)

/mob/proc/getOxyLoss()
	return oxyloss

/mob/proc/adjustOxyLoss(var/amount)
	oxyloss = max(oxyloss + amount, 0)

/mob/proc/setOxyLoss(var/amount)
	oxyloss = amount

/mob/proc/getToxLoss()
	return toxloss

/mob/proc/adjustToxLoss(var/amount)
	toxloss = max(toxloss + amount, 0)

/mob/proc/setToxLoss(var/amount)
	toxloss = amount

/mob/proc/getFireLoss()
	return fireloss

/mob/proc/adjustFireLoss(var/amount)
	fireloss = max(fireloss + amount, 0)

/mob/proc/getCloneLoss()
	return cloneloss

/mob/proc/adjustCloneLoss(var/amount)
	cloneloss = max(cloneloss + amount, 0)

/mob/proc/setCloneLoss(var/amount)
	cloneloss = amount

/mob/proc/getHalLoss()
	return halloss

/mob/proc/adjustHalLoss(var/amount)
	halloss = max(halloss + amount, 0)

/mob/proc/setHalLoss(var/amount)
	halloss = amount



/mob/proc/getBrainLoss()
	return brainloss

/mob/proc/adjustBrainLoss(var/amount)
	brainloss = max(brainloss + amount, 0)

/mob/proc/setBrainLoss(var/amount)
	brainloss = amount

// ++++ROCKDTBEN++++ MOB PROCS //END

/*
 * Sends resource files to client cache
 */
/mob/proc/getFiles()
	if(args && args.len)
		for(var/file in args)
			src << browse_rsc(file)
		return 1
	return 0


/** The stuff below here really should be in /mob/living, but due to tons of procs that should only
	take /mob/living only taking /mob(or, indeed, some silly procs relying on usr.. yes, *procs*, not verbs..),
	I'm putting this stuff into /mob for now
**/
/mob/proc/rebuild_appearance()
	// Rebuild the entire mob appearance completely, this should ONLY be called in rare cases,
	// e.g. when the mob spawns.
	return update_clothing() // most mobs still implement update_clothing() by simply rebuilding the entire appearance

/mob/proc/update_body_appearance()
	// Call this proc whenever something about the appearance of the body itself changes.
	// For example, this must be called when you add a wound to a mob.

/mob/proc/update_lying()
	// Call this whenever the lying status of a mob changes.

/mob/update_clothing()
	// Call this proc whenever something about the clothing of a mob changes. Normally, you
	// don't need to call this by hand, as the equip procs will do it for you.
	..()

/mob/proc/get_visible_gender()
	return gender