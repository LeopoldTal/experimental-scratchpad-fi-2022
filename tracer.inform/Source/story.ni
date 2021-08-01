"Test"

To debug-log (T - a text):
	say T;
	say line break.

A ray is a kind of thing.
A ray has a direction called the propagation-dir.
A ray has a thing called the parent.

A light source is a kind of device.
A light source has a direction called the emission-dir.
A light source can be active or inactive.

A light sink is a kind of thing.
A light sink has a list of directions called the lightcatching-dirs.

To say raydesc-parent of (R - a ray):
	if parent of R is a light source:
		say the parent of R;
	otherwise:
		let way be the opposite of propagation-dir of R;
		let origin-place be the room way from the location of R;
		say "[the origin-place] to [the way]".

To say raydesc-dest of (R - a ray):
	let sink be the obstacle of R;
	if sink is not nothing:
		say "hits [the sink]";
	otherwise:
		let way be the propagation-dir of R;
		let destination-place be the room way from the location of R;
		if destination-place is a room:
			say "stretches [way]wards into [the destination-place]";
		otherwise:
			say "peters out against the [way] wall".

To say raydesc of (R - a ray):
	say "This ray of light emerges from [raydesc-parent of R], and [raydesc-dest of R]"

The description of a ray is usually "[raydesc of the noun]."

To decide which object is the obstacle of (R - a ray):
	let candidates be the list of light sinks enclosed by the location of R;
	[TODO: how to choose out of multiple?]
	repeat with candidate running through candidates:
		if candidate is enclosed by a container:
			next;
		if candidate is enclosed by the player:
			next;
		if the propagation-dir of R is listed in the lightcatching-dirs of candidate:
			decide on candidate;
	decide on nothing.

Illuminating it with is an action applying to two things.

A mirror is a kind of thing.
A light sink is part of every mirror.
Two light sources are part of every mirror.
A mirror has a direction called the orientation.

Table of SW Mirror Directions
incoming	outgoing
north	west
east	south

Table of NW Mirror Directions
incoming	outgoing
south	west
east	north

Table of NE Mirror Directions
incoming	outgoing
south	east
west	north

Table of SE Mirror Directions
incoming	outgoing
north	east
west	south

[TODO: vertical]

Table of Mirror Orientation Tables
orientation	dict
southwest	Table of SW Mirror Directions
northwest	Table of NW Mirror Directions
northeast	Table of NE Mirror Directions
southeast	Table of SE Mirror Directions
[TODO: pick something for cardinal directions]

To orient (M - a mirror) towards (D - a direction):
	now the orientation of M is D;
	let the dictionary be the dict corresponding to an orientation of D in the Table of Mirror Orientation Tables;
	let L be a list of directions;
	repeat through the dictionary:
		add incoming entry to L; 
	let S be a random light sink which is part of M;
	now the lightcatching-dirs of S are L.

Carry out illuminating something (called the target) with something (called the hitting-ray) when the target is part of a mirror:
	repeat with M running through mirrors which enclose target:
		let O be the orientation of M;
		let dictionary be the dict corresponding to an orientation of O in the Table of Mirror Orientation Tables;
		let way-in be the propagation-dir of hitting-ray;
		let way-out be the outgoing corresponding to an incoming of way-in in dictionary;
		let S be a random switched off light source which is part of M;
		if S is nothing:
			say "BUG: trying to emit 2 rays from same source ([S]).";
		otherwise:
			now the emission-dir of S is way-out;
			now S is switched on.

Every turn:
	now every light source which is part of a mirror is switched off.

[TODO: room description with rays and mirrors]

Raystore is a container which is nowhere. There are 100 rays in raystore.

[FIXME: loops. Limited fuel? Merge ray into identical ray?]
To raytrace:
	debug-log "Raytracing starts.";
	now every ray is in raystore;
	now every light source is active;
	let sources be the list of active switched on light sources;
	let open-rays be a list of rays;
	while the number of entries in sources is not 0:
		[emit rays from light sources]
		repeat with source running through sources:
			let place be location of source;
			debug-log "Emitting ray from [source] in [place] towards the [emission-dir of source].";
			let new-ray be a random ray in raystore;
			if new-ray is nothing:
				debug-log "Out of rays!";
			otherwise:
				now propagation-dir of new-ray is emission-dir of source;
				now parent of new-ray is source;
				move new-ray to place;
				add new-ray to open-rays;
			now source is inactive;
		[propagate rays]
		while the number of entries in open-rays is not 0:
			let growing-ray be entry 1 of open-rays;
			remove entry 1 from open-rays;
			let place be the location of growing-ray;
			let way be propagation-dir of growing-ray;
			[light sinks]
			let target be the obstacle of growing-ray;
			if target is not nothing:
				debug-log "Ray going towards [way] in [place] hits [target] (catching [lightcatching-dirs of target]).";
				try illuminating the target with growing-ray;
				next;
			[trace to next room if any]
			let spread-to be the room way from place;
			if spread-to is a room:
				debug-log "Ray going towards [way] in [place] proceeds to [spread-to].";
				let new-ray be a random ray in raystore;
				if new-ray is nothing:
					debug-log "Out of rays!";
				otherwise:
					now propagation-dir of new-ray is way;
					now parent of new-ray is growing-ray;
					move new-ray to spread-to;
					add new-ray to open-rays;
			otherwise:
				debug-log "Ray going towards [way] in [place] stops.";
		[repeat in case that activated new sources]
		now sources is the list of active switched on light sources.

Every turn:
	raytrace.

The Origin is a room.
The North Corridor is north of the Origin. The North End is north of the North Corridor.
The South Corridor is south of the Origin. The South End is south of the South Corridor.
The West Corridor is west of the Origin. The West End is west of the West Corridor.
The East Corridor is east of the Origin. The East End is east of the East Corridor.
The Northwest Corner is north of the West Corridor and west of the North Corridor.

A lamp is in Origin. The lamp is a light source. The emission-dir of the lamp is north.

A bucket is in Origin. The bucket is a container.

The player carries a screen. The screen is a light sink. The lightcatching-dirs of the screen are { north, east, south, west }.
The player carries a mirror called the small mirror.

A mirror called the reflector is in the Northwest Corner.

When play begins:
	orient the small mirror towards southwest;
	orient the reflector towards southeast.

