-- CTF Game Flags
-- 60 flags total: 15 per city (NYC, Chicago, Austin, SF)
-- Difficulty: 5 easy (100pts), 7 medium (150pts), 3 hard (200pts) per city

-- ============================================
-- NEW YORK CITY (15 flags)
-- ============================================

-- Easy Flags (5)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'The Crossroads',
  'Where a million dreams intersect daily',
  'The center of the world, or so they say. Look where the lights never sleep.',
  ST_SetSRID(ST_MakePoint(-73.9855, 40.7580), 4326),
  100,
  'NYC',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lady Liberty',
  'A beacon of freedom in the harbor',
  'She holds the torch high, welcoming millions to a new world.',
  ST_SetSRID(ST_MakePoint(-74.0445, 40.6892), 4326),
  100,
  'NYC',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Green Lung',
  'Urban oasis stretching for miles',
  '843 acres of green in the heart of Manhattan. Olmsted''s masterpiece.',
  ST_SetSRID(ST_MakePoint(-73.9654, 40.7829), 4326),
  100,
  'NYC',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Art Temple',
  'The Met holds treasures from millennia',
  'Five thousand years of art behind classical columns on Museum Mile.',
  ST_SetSRID(ST_MakePoint(-73.9632, 40.7794), 4326),
  100,
  'NYC',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Steel Web',
  'Gothic arches span the East River',
  'Walk where thousands cross between boroughs on cables of steel.',
  ST_SetSRID(ST_MakePoint(-73.9969, 40.7061), 4326),
  100,
  'NYC',
  'easy'
);

-- Medium Flags (7)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Angel Waters',
  'Where the guardian watches over the fountain',
  'In the heart of green, beneath bronze wings, waters flow eternal.',
  ST_SetSRID(ST_MakePoint(-73.9712, 40.7722), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'High Line',
  'Rails to trails above the streets',
  'What once carried freight now carries tourists, elevated above the Meatpacking.',
  ST_SetSRID(ST_MakePoint(-74.0048, 40.7480), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Wall Street Bull',
  'Bronze beast of prosperity',
  'Touch the horns for luck. Tourists love him, locals tolerate him.',
  ST_SetSRID(ST_MakePoint(-74.0134, 40.7055), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Grand Central',
  'Where all lines meet under painted stars',
  'Look up at the celestial ceiling. The stars are backwards, and that''s intentional.',
  ST_SetSRID(ST_MakePoint(-73.9772, 40.7527), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Oculus',
  'Phoenix rising from ground zero',
  'White ribs reach skyward where towers once stood. The PATH awaits below.',
  ST_SetSRID(ST_MakePoint(-74.0119, 40.7116), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Coney Island',
  'Where the city meets the sea',
  'Ride the Cyclone, eat a Nathan''s hot dog, walk the boardwalk. Summer never dies here.',
  ST_SetSRID(ST_MakePoint(-73.9771, 40.5755), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Flatiron',
  'The building that defined a neighborhood',
  'A triangle where Broadway meets Fifth. Daniel Burnham''s iron masterpiece.',
  ST_SetSRID(ST_MakePoint(-73.9897, 40.7411), 4326),
  150,
  'NYC',
  'medium'
);

-- Hard Flags (3)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Whispering Gallery',
  'Secrets travel across ceramic arches',
  'Stand in opposite corners underground. Your whisper crosses 30 feet of tile.',
  ST_SetSRID(ST_MakePoint(-73.9772, 40.7527), 4326),
  200,
  'NYC',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Green-Wood Heights',
  'Where history sleeps on the hill',
  'Half a million souls rest here. Find the highest point in Brooklyn among the monuments.',
  ST_SetSRID(ST_MakePoint(-73.9952, 40.6563), 4326),
  200,
  'NYC',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Roosevelt Island Tram',
  'Cable car over the East River',
  'Your MetroCard works here. Rise above the 59th Street Bridge for the best view.',
  ST_SetSRID(ST_MakePoint(-73.9493, 40.7590), 4326),
  200,
  'NYC',
  'hard'
);

-- ============================================
-- CHICAGO (15 flags)
-- ============================================

-- Easy Flags (5)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mirror Sky',
  'Where the city reflects itself in silver',
  'A bean that holds the skyline in its curves. Selfie capital of the Midwest.',
  ST_SetSRID(ST_MakePoint(-87.6233, 41.8827), 4326),
  100,
  'Chicago',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Skyline Giant',
  'Once the world''s tallest',
  'Stand on glass 103 floors up at the Skydeck. Don''t look down if you''re scared.',
  ST_SetSRID(ST_MakePoint(-87.6359, 41.8789), 4326),
  100,
  'Chicago',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Navy Pier',
  'Where the city meets Lake Michigan',
  'Ferris wheel views and carnival vibes. Tourists love it, locals avoid it.',
  ST_SetSRID(ST_MakePoint(-87.6056, 41.8919), 4326),
  100,
  'Chicago',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Millennium Park',
  'Where art meets public space',
  'The Bean''s home. Frank Gehry''s bandshell. Lurie Garden blooms.',
  ST_SetSRID(ST_MakePoint(-87.6226, 41.8826), 4326),
  100,
  'Chicago',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Art Institute',
  'Lions guard the entrance to masterpieces',
  'Nighthawks and Gothic American hang inside. The lions get Cubs hats in October.',
  ST_SetSRID(ST_MakePoint(-87.6236, 41.8796), 4326),
  100,
  'Chicago',
  'easy'
);

-- Medium Flags (7)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Buckingham Fountain',
  'Water dances in Grant Park',
  'Versailles-inspired, twice as large. Light shows after dark in summer.',
  ST_SetSRID(ST_MakePoint(-87.6189, 41.8758), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Wrigley Field',
  'Where ivy grows on outfield walls',
  'The friendly confines. Cubs fans bleed blue. Rooftop seats across the street.',
  ST_SetSRID(ST_MakePoint(-87.6553, 41.9484), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'The Riverwalk',
  'Bars and kayaks line the Chicago River',
  'Where they dye the river green once a year. Walk from Lake Street to the Lake.',
  ST_SetSRID(ST_MakePoint(-87.6244, 41.8883), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  '360 Chicago',
  'Tilt out over Michigan Avenue',
  'Formerly Hancock. TILT lets you lean over the edge at 1,000 feet.',
  ST_SetSRID(ST_MakePoint(-87.6230, 41.8987), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Field Museum',
  'Where Sue the T-Rex reigns',
  'The largest, most complete T-Rex ever found. Natural history for days.',
  ST_SetSRID(ST_MakePoint(-87.6170, 41.8663), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lincoln Park Zoo',
  'Free animals since 1868',
  'One of the oldest zoos in America. Lions, apes, and polar bears—no admission.',
  ST_SetSRID(ST_MakePoint(-87.6335, 41.9212), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Museum of Science',
  'Where a U-boat rests in Hyde Park',
  'German submarine U-505. Coal mine. Giant pendulum proves Earth spins.',
  ST_SetSRID(ST_MakePoint(-87.5830, 41.7906), 4326),
  150,
  'Chicago',
  'medium'
);

-- Hard Flags (3)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'The Pedway',
  'Miles of tunnels connect the Loop',
  'Winter escape beneath the streets. Follow the signs through basements and lobbies.',
  ST_SetSRID(ST_MakePoint(-87.6298, 41.8819), 4326),
  200,
  'Chicago',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Graceland Cemetery',
  'Where Chicago''s elite rest',
  'Architects, tycoons, and legends. Find Louis Sullivan''s own masterpiece here.',
  ST_SetSRID(ST_MakePoint(-87.6608, 41.9539), 4326),
  200,
  'Chicago',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Garfield Park Conservatory',
  'A jungle under glass on the West Side',
  'Free tropical paradise year-round. Chihuly glass among the palms.',
  ST_SetSRID(ST_MakePoint(-87.7171, 41.8862), 4326),
  200,
  'Chicago',
  'hard'
);

-- ============================================
-- AUSTIN (15 flags)
-- ============================================

-- Easy Flags (5)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lone Star Dome',
  'Pink granite under a copper dome',
  'Taller than the US Capitol. Texas makes sure you know it.',
  ST_SetSRID(ST_MakePoint(-97.7407, 30.2747), 4326),
  100,
  'Austin',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Spring Eternal',
  'Nature''s pool in Zilker Park',
  '68 degrees year-round. Three acres of spring-fed swimming.',
  ST_SetSRID(ST_MakePoint(-97.7701, 30.2638), 4326),
  100,
  'Austin',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Congress Bridge',
  'Where 1.5 million bats emerge at dusk',
  'Largest urban bat colony in North America. Sunset show from March to October.',
  ST_SetSRID(ST_MakePoint(-97.7450, 30.2628), 4326),
  100,
  'Austin',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Sixth Street',
  'Where the music never stops',
  'The heartbeat of live music capital. Neon, honky-tonks, and bachelorettes.',
  ST_SetSRID(ST_MakePoint(-97.7397, 30.2672), 4326),
  100,
  'Austin',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Zilker Park',
  '350 acres of Austin''s backyard',
  'ACL Festival. Kite flying. Blues on the Green. The city''s living room.',
  ST_SetSRID(ST_MakePoint(-97.7711, 30.2672), 4326),
  100,
  'Austin',
  'easy'
);

-- Medium Flags (7)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mount Bonnell',
  'Climb 106 steps for the view',
  'Highest point in Austin. Proposals happen here. Bring water.',
  ST_SetSRID(ST_MakePoint(-97.7722, 30.3179), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'LBJ Library',
  'Presidential history on UT campus',
  'The 36th President''s legacy in glass and limestone. His limo sits in the lobby.',
  ST_SetSRID(ST_MakePoint(-97.7281, 30.2853), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Bullock Museum',
  'Texas history from the Alamo to oil',
  'Story of Texas in artifacts and IMAX. Bob Bullock''s tribute to the state.',
  ST_SetSRID(ST_MakePoint(-97.7392, 30.2804), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Graffiti Park',
  'Hope Outdoor Gallery closed, Castle Hill remains',
  'Spray paint paradise on Baylor Street. HOPE letters gone but art lives on.',
  ST_SetSRID(ST_MakePoint(-97.7611, 30.2738), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lady Bird Lake',
  'Where Austin runs, kayaks, and paddles',
  'Ten miles of hike-and-bike trail circling the water. Sunset from Lamar Bridge.',
  ST_SetSRID(ST_MakePoint(-97.7556, 30.2559), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Franklin BBQ',
  'Wait in line for brisket perfection',
  'Aaron Franklin''s temple to smoke. Four-hour waits. Worth every minute.',
  ST_SetSRID(ST_MakePoint(-97.7280, 30.2704), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Continental Club',
  'Honky-tonk on South Congress since 1955',
  'Where legends play intimate sets. Red vinyl, neon signs, dancing till 2am.',
  ST_SetSRID(ST_MakePoint(-97.7497, 30.2548), 4326),
  150,
  'Austin',
  'medium'
);

-- Hard Flags (3)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Cathedral of Junk',
  'Vince Hannemann''s backyard masterpiece',
  'Sixty tons of found objects, spiraling to the sky. Call ahead for a tour.',
  ST_SetSRID(ST_MakePoint(-97.8647, 30.2120), 4326),
  200,
  'Austin',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Treaty Oak',
  'The last of the Council Oaks',
  'Five hundred years old, poisoned, survived. Stephen F. Austin''s treaty tree.',
  ST_SetSRID(ST_MakePoint(-97.7564, 30.2701), 4326),
  200,
  'Austin',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mayfield Park',
  'Peacocks roam among cottage gardens',
  'West Austin secret. Free-roaming peafowl and lily ponds. Mary Mayfield''s gift.',
  ST_SetSRID(ST_MakePoint(-97.7790, 30.3124), 4326),
  200,
  'Austin',
  'hard'
);

-- ============================================
-- SAN FRANCISCO (15 flags)
-- ============================================

-- Easy Flags (5)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Red Gateway',
  'International orange spans the strait',
  'The bridge that defines the Bay. Art Deco towers in perpetual fog.',
  ST_SetSRID(ST_MakePoint(-122.4783, 37.8199), 4326),
  100,
  'SF',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Alcatraz',
  'The Rock that held Capone',
  'Federal prison turned tourist trap. Book weeks ahead for the ferry.',
  ST_SetSRID(ST_MakePoint(-122.4230, 37.8267), 4326),
  100,
  'SF',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Cable Cars',
  'Rolling National Historic Landmarks',
  'Grip the pole, lean out, feel the hill. Powell-Hyde is the best line.',
  ST_SetSRID(ST_MakePoint(-122.4116, 37.7946), 4326),
  100,
  'SF',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Fisherman''s Wharf',
  'Where sea lions bark and tourists flock',
  'Pier 39, clam chowder, sourdough bread bowls. Authentic tourist trap.',
  ST_SetSRID(ST_MakePoint(-122.4156, 37.8087), 4326),
  100,
  'SF',
  'easy'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Chinatown Gate',
  'Where Grant Avenue begins',
  'Oldest Chinatown in North America. Dragons guard the entrance.',
  ST_SetSRID(ST_MakePoint(-122.4058, 37.7907), 4326),
  100,
  'SF',
  'easy'
);

-- Medium Flags (7)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Serpent Road',
  'Eight hairpin turns down Russian Hill',
  'The world''s crookedest street. One block of switchbacks and hydrangeas.',
  ST_SetSRID(ST_MakePoint(-122.4187, 37.8021), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Painted Ladies',
  'Victorian postcards at Alamo Square',
  'Seven sisters facing the skyline. Full House made them famous.',
  ST_SetSRID(ST_MakePoint(-122.4330, 37.7762), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Coit Tower',
  'Art Deco lighthouse on Telegraph Hill',
  'WPA murals inside, 360 views outside. Parrots live in the trees below.',
  ST_SetSRID(ST_MakePoint(-122.4059, 37.8024), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Palace of Fine Arts',
  'Beaux-Arts romance by the Marina',
  'Built for 1915 Expo, rebuilt for love. Swans glide in the lagoon.',
  ST_SetSRID(ST_MakePoint(-122.4486, 37.8028), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mission Dolores',
  'Oldest building in San Francisco',
  'Founded 1776. Adobe walls, hand-painted ceiling, cemetery of pioneers.',
  ST_SetSRID(ST_MakePoint(-122.4269, 37.7648), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Twin Peaks',
  'Where the city spreads below you',
  'Drive, hike, or Uber to 1,000 feet. Fog permitting, you can see it all.',
  ST_SetSRID(ST_MakePoint(-122.4475, 37.7544), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Ferry Building',
  'Farmers market meets food hall',
  'The clock tower survived 1906. Oysters, cheese, and artisan everything.',
  ST_SetSRID(ST_MakePoint(-122.3933, 37.7956), 4326),
  150,
  'SF',
  'medium'
);

-- Hard Flags (3)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Wave Organ',
  'Acoustic sculpture plays with the tide',
  'PVC pipes and stone create music from the Bay. Best at high tide.',
  ST_SetSRID(ST_MakePoint(-122.4351, 37.8074), 4326),
  200,
  'SF',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Lands End Labyrinth',
  'Stone spiral above the Pacific',
  'Hidden trail art overlooking the Golden Gate. Rebuilt by strangers when vandalized.',
  ST_SetSRID(ST_MakePoint(-122.5071, 37.7854), 4326),
  200,
  'SF',
  'hard'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Seward Street Slides',
  'Concrete slides hidden in a neighborhood',
  'Bring cardboard. Built in 1973. A secret Castro playground for all ages.',
  ST_SetSRID(ST_MakePoint(-122.4364, 37.7605), 4326),
  200,
  'SF',
  'hard'
);

-- ============================================
-- RESTAURANT FLAGS (Mom & Pop Spots)
-- ============================================

-- NYC Restaurants (4 additions)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Red Sauce Legend',
  'Little Italy holdout since 1896',
  'Lombardi''s coal oven has been firing pies longer than anyone. First pizzeria in America.',
  ST_SetSRID(ST_MakePoint(-73.9958, 40.7214), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Pastrami Pilgrimage',
  'Where tourists and locals both wait in line',
  'Katz''s has been hand-cutting since 1888. Meg Ryan made it famous, but the pastrami keeps you coming back.',
  ST_SetSRID(ST_MakePoint(-73.9874, 40.7223), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Soup Master',
  'No soup for you if you don''t follow the rules',
  'Seinfeld immortalized him, but the soup speaks for itself. Midtown, cash only, strict ordering.',
  ST_SetSRID(ST_MakePoint(-73.9857, 40.7629), 4326),
  150,
  'NYC',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Noodle Dynasty',
  'Hand-pulled noodles in Chinatown',
  'Xi''an Famous Foods started in a basement. Now the lamb burgers are legendary across the city.',
  ST_SetSRID(ST_MakePoint(-73.9972, 40.7156), 4326),
  150,
  'NYC',
  'medium'
);

-- Chicago Restaurants (4 additions)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Deep Dish Temple',
  'Lou Malnati''s butter crust since 1971',
  'The Malnati Chicago Classic with sausage. Locals debate, but the line doesn''t lie.',
  ST_SetSRID(ST_MakePoint(-87.6319, 41.8902), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Italian Beef Kingdom',
  'Al''s has been dipping since 1938',
  'Get it wet, with hot peppers. The gravy-soaked roll is a Chicago sacrament.',
  ST_SetSRID(ST_MakePoint(-87.6421, 41.9067), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Hot Dog Sanctuary',
  'No ketchup allowed at Superdawg',
  'Drive-in with mascots on the roof since 1948. The Whoopercheesie is non-negotiable.',
  ST_SetSRID(ST_MakePoint(-87.7156, 41.9968), 4326),
  150,
  'Chicago',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Tamale Treasure',
  'Pilsen''s 5 Rabanitos feeds the neighborhood',
  'Abuelita recipes, homemade tortillas, cash only. The mole poblano is legendary.',
  ST_SetSRID(ST_MakePoint(-87.6697, 41.8564), 4326),
  150,
  'Chicago',
  'medium'
);

-- Austin Restaurants (4 additions)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Tex-Mex Royalty',
  'Matt''s El Rancho since 1952',
  'Bob Armstrong dip was born here. LBJ ate here. You should too.',
  ST_SetSRID(ST_MakePoint(-97.7565, 30.2652), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Taco Trailer Legend',
  'Veracruz All Natural started at a farmers market',
  'Migas tacos on handmade tortillas. Lines form before they open.',
  ST_SetSRID(ST_MakePoint(-97.7501, 30.2545), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Breakfast Kingdom',
  'Juan in a Million invented the Don Juan',
  'A tortilla wrapped around everything breakfast. East side institution since 1980.',
  ST_SetSRID(ST_MakePoint(-97.7170, 30.2620), 4326),
  150,
  'Austin',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Soul Food Sanctuary',
  'Hoover''s feeds comfort on Manor Road',
  'Chicken fried steak, collard greens, jalapeño cheese grits. Texas soul with a side of biscuits.',
  ST_SetSRID(ST_MakePoint(-97.7177, 30.2809), 4326),
  150,
  'Austin',
  'medium'
);

-- San Francisco Restaurants (4 additions)
INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Swan Oyster Legacy',
  'Counter seats only since 1912',
  'Polk Street seafood shrine. Dungeness crab, oysters on ice, no reservations.',
  ST_SetSRID(ST_MakePoint(-122.4215, 37.7938), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Mission Burrito Wars',
  'La Taqueria wins the debate',
  'No rice in the burrito. Carnitas or carne asada. James Beard agreed.',
  ST_SetSRID(ST_MakePoint(-122.4184, 37.7494), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Dim Sum Dynasty',
  'Hong Kong Lounge serves carts till they''re empty',
  'Chinatown hole-in-wall. Get there early, point at what looks good, cash only.',
  ST_SetSRID(ST_MakePoint(-122.4077, 37.7949), 4326),
  150,
  'SF',
  'medium'
);

INSERT INTO flags (name, description, hint, location, points, city, difficulty)
VALUES (
  'Sourdough Source',
  'Boudin Bakery has been baking since 1849',
  'The mother dough survived the 1906 earthquake. Clam chowder in a bread bowl at the Wharf.',
  ST_SetSRID(ST_MakePoint(-122.4156, 37.8087), 4326),
  150,
  'SF',
  'medium'
);
