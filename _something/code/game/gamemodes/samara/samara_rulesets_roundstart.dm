/datum/dynamic_ruleset/roundstart/samara
	name = "SAMARA"
	antag_flag = null
	antag_datum = null
	restricted_roles = list()
	required_candidates = 0
	weight = 0
	cost = 0
	requirements = list(101,101,101,101,101,101,101,101,101,101)
	flags = LONE_RULESET

/datum/dynamic_ruleset/roundstart/samara/acceptable(population, threat_level)
	return TRUE

/datum/dynamic_ruleset/roundstart/samara/ready(population, forced)
	return TRUE

/datum/dynamic_ruleset/roundstart/samara/pre_execute()
	. = ..()
	message_admins("Starting a round of SAMARA!")
	log_game("DYNAMIC: Starting a round of SAMARA.")
	mode.spend_roundstart_budget(mode.round_start_budget)
	mode.spend_midround_budget(mode.mid_round_budget)
	mode.threat_log += "[worldtime2text()]: SAMARA ruleset set threat to 0."
	var/soundfile = "modular_septic/sound/voice/valario/valario[rand(1,11)].ogg"
	var/sound/valario = sound(soundfile, FALSE, 0, CHANNEL_ADMIN, 100)
	SEND_SOUND(world, valario)
	var/datum/job_department/secclean/secclean_department
	var/datum/job_department/specopergroup/specopergroup_department
	//var/datum/job_department/denominators/denominator_department
	for(var/datum/job_department/department as anything in SSjob.joinable_departments)
		if(istype(department, /datum/job_department/secclean))
			secclean_department = department
		else if(istype(department, /datum/job_department/specopergroup))
			specopergroup_department = department
		//else if(istype(department, /datum/job_department/denominators))
			//denominator_department = department
		else
			SSjob.joinable_departments -= department
	secclean_department = new /datum/job_department/secclean()
	specopergroup_department = new /datum/job_department/specopergroup()
	//denominator_department = new /datum/job_department/denominators()
	SSjob.joinable_departments += secclean_department
	SSjob.joinable_departments_by_type[secclean_department.type] = secclean_department
	SSjob.joinable_departments += specopergroup_department
	SSjob.joinable_departments_by_type[specopergroup_department.type] = specopergroup_department
	//SSjob.joinable_departments += denominator_department
	//SSjob.joinable_departments_by_type[denominator_department.type] = denominator_department
	for(var/datum/job/job as anything in SSjob.all_occupations)
		if(istype(job, /datum/job/sectrooper) || istype(job, /datum/job/secmed))///datum/job/tutorial))
			SSjob.name_occupations[job.title] = job
			secclean_department.add_job(job)
			secclean_department.department_head = job.type
			job.job_flags |= JOB_NEW_PLAYER_JOINABLE
			job.total_positions = 64
			job.spawn_positions = 64
			SSjob.joinable_occupations += job
		//else if(istype(job, /datum/job/denominator))
			//addtimer(CALLBACK(src, PROC_REF(add_denominators), job, denominator_department), 15 MINUTES)
		//else if(istype(job, /datum/job/denominator_shotgunner))
			//addtimer(CALLBACK(src, PROC_REF(add_denominators), job, denominator_department), 15 MINUTES)
		else if(istype(job, /datum/job/grouptrooper) || istype(job, /datum/job/groupmed))
			SSjob.name_occupations[job.title] = job
			specopergroup_department.add_job(job)
			specopergroup_department.department_head = job.type
			job.job_flags |= JOB_NEW_PLAYER_JOINABLE
			job.total_positions = 64
			job.spawn_positions = 64
			SSjob.joinable_occupations += job

		else
			SSjob.joinable_occupations -= job

/**
/datum/dynamic_ruleset/roundstart/proc/add_denominators(var/datum/job/J, var/datum/job_department/denominators/denominator_department)
	if(istype(J, /datum/job/denominator))
		var/datum/job/denominator/job = J
		SSjob.name_occupations[job.title] = job
		denominator_department.add_job(job)
		denominator_department.department_head = job.type
		job.job_flags |= JOB_NEW_PLAYER_JOINABLE
		job.total_positions = 2
		job.spawn_positions = 2
		SSjob.joinable_occupations += job
	else if(istype(J, /datum/job/denominator_shotgunner))
		var/datum/job/denominator_shotgunner/job = J
		SSjob.name_occupations[job.title] = job
		denominator_department.add_job(job)
		denominator_department.department_head = job.type
		job.job_flags |= JOB_NEW_PLAYER_JOINABLE
		job.total_positions = 2
		job.spawn_positions = 2
		SSjob.joinable_occupations += job

*/
