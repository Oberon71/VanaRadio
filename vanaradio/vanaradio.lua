addon.name = 'vanaradio';
addon.author = 'VanaRadio Project';
addon.version = '0.19.1';
addon.desc = 'Native FFXI jukebox with searchable accordion music catalog.';

require('common');
local imgui = require('imgui');

local visible = true;
local selected = 1;
local zone_override = false;
local persistent_mode = false;
local zone_count = 0;
local last_zone_status = 'No zone transition observed.';
local active_track = nil;
local status = 'Choose a song, then click Play Selected Track.';
local last_result = 'No playback request sent.';

-- Catalog IDs compiled from publicly documented FFXI music ID lists.
-- Availability depends on installed game audio assets and Phoenix client.
local tracks = {
    { id = 25, name = 'The Voracious Resurgence', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 26, name = 'The Devoured', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 27, name = 'Encroaching Perils', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 28, name = 'The Destiny Destroyers', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 29, name = 'Devils\' Delight', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 30, name = 'Sojourner', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 31, name = 'Black Stars Rise', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 32, name = 'All Smiles', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 33, name = 'Valhalla', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 34, name = 'We Are Vana\'diel', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 35, name = 'Goddessspeed', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 36, name = 'Good Fortune', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 37, name = 'All-Consuming Chaos', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 38, name = 'Your Choice', expansion = 'The Voracious Resurgence', activity = 'Story & Cutscenes' },
    { id = 40, name = 'Cloister of Time and Souls', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 41, name = 'Royal Wanderlust', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 42, name = 'Snowdrift Waltz', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 43, name = 'Troubled Shadows', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 44, name = 'Where Lords Rule Not', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 45, name = 'Summers Lost', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 46, name = 'Goddess Divine', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 47, name = 'Echoes of Creation', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 48, name = 'Main Theme', expansion = 'Rhapsodies / Other', activity = 'Title & Themes' },
    { id = 49, name = 'Luck of the Mog', expansion = 'Rhapsodies / Other', activity = 'Events & Special' },
    { id = 50, name = 'Feast of the Ladies', expansion = 'Rhapsodies / Other', activity = 'Events & Special' },
    { id = 51, name = 'Abyssea - Scarlet Skies, Shadowed Plains', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 52, name = 'Melodies Errant', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 53, name = 'Shinryu', expansion = 'Abyssea / Voidwatch', activity = 'Battle Arenas & Combat' },
    { id = 54, name = 'Everlasting Bonds', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 55, name = 'Provenance Watcher', expansion = 'Abyssea / Voidwatch', activity = 'Battle Arenas & Combat' },
    { id = 56, name = 'Where it All Begins', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 57, name = 'Steel Sings, Blades Dance', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 58, name = 'A New Direction', expansion = 'Abyssea / Voidwatch', activity = 'Story & Cutscenes' },
    { id = 59, name = 'The Pioneers', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 60, name = 'Into Lands Primeval - Ulbuka', expansion = 'Seekers of Adoulin', activity = 'Fields & Dungeons' },
    { id = 61, name = 'Water\'s Umbral Knell', expansion = 'Seekers of Adoulin', activity = 'Fields & Dungeons' },
    { id = 62, name = 'Keepers of the Wild', expansion = 'Seekers of Adoulin', activity = 'Fields & Dungeons' },
    { id = 63, name = 'The Sacred City of Adoulin', expansion = 'Seekers of Adoulin', activity = 'Towns & Cities' },
    { id = 64, name = 'Breaking Ground', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 65, name = 'Hades', expansion = 'Seekers of Adoulin', activity = 'Battle Arenas & Combat' },
    { id = 66, name = 'Arciela', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 67, name = 'Mog Resort', expansion = 'Seekers of Adoulin', activity = 'Towns & Cities' },
    { id = 68, name = 'Worlds Away', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 69, name = 'Distant Worlds (Nanaa Mihgo\'s version)', expansion = 'Seekers of Adoulin', activity = 'Events & Special' },
    { id = 70, name = 'Monstrosity', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 71, name = 'The Pioneers (Nanaa Mihgo\'s version)', expansion = 'Seekers of Adoulin', activity = 'Events & Special' },
    { id = 72, name = 'The Serpentine Labyrinth', expansion = 'Seekers of Adoulin', activity = 'Fields & Dungeons' },
    { id = 73, name = 'The Divine', expansion = 'Seekers of Adoulin', activity = 'Battle Arenas & Combat' },
    { id = 74, name = 'Clouds Over Ulbuka', expansion = 'Seekers of Adoulin', activity = 'Fields & Dungeons' },
    { id = 75, name = 'The Price', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 76, name = 'Forever Today', expansion = 'Seekers of Adoulin', activity = 'Story & Cutscenes' },
    { id = 77, name = 'Distant Worlds (Instrumental)', expansion = 'Seekers of Adoulin', activity = 'Events & Special' },
    { id = 78, name = 'Forever Today (Instrumental)', expansion = 'Seekers of Adoulin', activity = 'Events & Special' },
    { id = 79, name = 'Iroha', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 80, name = 'The Boundless Black', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 81, name = 'Isle of the Gods', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 82, name = 'Wail of the Void', expansion = 'Rhapsodies / Other', activity = 'Battle Arenas & Combat' },
    { id = 83, name = 'Rhapsodies of Vana\'diel', expansion = 'Rhapsodies / Other', activity = 'Title & Themes' },
    { id = 84, name = 'Full Speed Ahead!', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 85, name = 'Times Grow Tense', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 86, name = 'Shadow Lord (Record Keeper Remix)', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 87, name = 'For a Friend', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 88, name = 'Between Dreams and Reality', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 89, name = 'Disjoined One', expansion = 'Rhapsodies / Other', activity = 'Battle Arenas & Combat' },
    { id = 90, name = 'Winds of Change', expansion = 'Rhapsodies / Other', activity = 'Story & Cutscenes' },
    { id = 101, name = 'Battle Theme', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 102, name = 'Battle in the Dungeon #2', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 103, name = 'Battle Theme #2', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 104, name = 'A Road Once Traveled', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 105, name = 'Mhaura', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 106, name = 'Voyager', expansion = 'Original XI / Zilart-era', activity = 'Travel & Chocobo' },
    { id = 107, name = 'The Kingdom of San d\'Oria', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 108, name = 'Vana\'diel March', expansion = 'Original XI / Zilart-era', activity = 'Title & Themes' },
    { id = 109, name = 'Ronfaure', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 110, name = 'The Grand Duchy of Jeuno', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 111, name = 'Blackout', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 112, name = 'Selbina', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 113, name = 'Sarutabaruta', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 114, name = 'Batallia Downs', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 115, name = 'Battle in the Dungeon', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 116, name = 'Gustaberg', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 117, name = 'Ru\'Lude Gardens', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 118, name = 'Rolanberry Fields', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 119, name = 'Awakening', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 120, name = 'Vana\'diel March #2', expansion = 'Original XI / Zilart-era', activity = 'Title & Themes' },
    { id = 121, name = 'Shadow Lord', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 122, name = 'One Last Time', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 123, name = 'Hopelessness', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 124, name = 'Recollection', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 125, name = 'Tough Battle', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 126, name = 'Mog House', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 127, name = 'Anxiety', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 128, name = 'Airship', expansion = 'Original XI / Zilart-era', activity = 'Travel & Chocobo' },
    { id = 129, name = 'Hook, Line and Sinker', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 130, name = 'Tarutaru Female', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 131, name = 'Elvaan Female', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 132, name = 'Elvaan Male', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 133, name = 'Hume Male', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 134, name = 'Yuhtunga Jungle', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 135, name = 'Kazham', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 136, name = 'The Big One', expansion = 'Original XI / Zilart-era', activity = 'Battle Arenas & Combat' },
    { id = 137, name = 'A Realm of Emptiness', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 138, name = 'Mercenaries\' Delight', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 139, name = 'Delve', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 140, name = 'Wings of the Goddess', expansion = 'Wings of the Goddess', activity = 'Title & Themes' },
    { id = 141, name = 'The Cosmic Wheel', expansion = 'Wings of the Goddess', activity = 'Title & Themes' },
    { id = 142, name = 'Fated Strife - Besieged', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 143, name = 'Hellriders', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 144, name = 'Rapid Onslaught - Assault', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 145, name = 'Encampment Dreams', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 146, name = 'The Colosseum', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 147, name = 'Eastward Bound', expansion = 'Treasures of Aht Urhgan', activity = 'Travel & Chocobo' },
    { id = 148, name = 'Forbidden Seal', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 149, name = 'Jeweled Boughs', expansion = 'Treasures of Aht Urhgan', activity = 'Fields & Dungeons' },
    { id = 150, name = 'Ululations from Beyond', expansion = 'Treasures of Aht Urhgan', activity = 'Fields & Dungeons' },
    { id = 151, name = 'The Federation of Windurst', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 152, name = 'The Republic of Bastok', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 153, name = 'Prelude', expansion = 'Original XI / Zilart-era', activity = 'Title & Themes' },
    { id = 154, name = 'Metalworks', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 155, name = 'Castle Zvahl', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 156, name = 'Chateau d\'Oraguille', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 157, name = 'Fury', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 158, name = 'Sauromugue Champaign', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 159, name = 'Sorrow', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 160, name = 'Repression (Memoro de la Stono)', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 161, name = 'Despair (Memoro de la Stono)', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 162, name = 'Heavens Tower', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 163, name = 'Sometime, Somewhere', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 164, name = 'Xarcabard', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 165, name = 'Galka', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 166, name = 'Mithra', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 167, name = 'Tarutaru Male', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 168, name = 'Hume Female', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 169, name = 'Regeneracy', expansion = 'Original XI / Zilart-era', activity = 'Story & Cutscenes' },
    { id = 170, name = 'Buccaneers', expansion = 'Original XI / Zilart-era', activity = 'Travel & Chocobo' },
    { id = 171, name = 'Altepa Desert', expansion = 'Original XI / Zilart-era', activity = 'Fields & Dungeons' },
    { id = 172, name = 'Black Coffin', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 173, name = 'Illusions in the Mist', expansion = 'Treasures of Aht Urhgan', activity = 'Fields & Dungeons' },
    { id = 174, name = 'Whispers of the Gods', expansion = 'Treasures of Aht Urhgan', activity = 'Fields & Dungeons' },
    { id = 175, name = 'Bandits\' Market', expansion = 'Treasures of Aht Urhgan', activity = 'Towns & Cities' },
    { id = 176, name = 'Circuit de Chocobo', expansion = 'Treasures of Aht Urhgan', activity = 'Travel & Chocobo' },
    { id = 177, name = 'Run Chocobo, Run!', expansion = 'Treasures of Aht Urhgan', activity = 'Travel & Chocobo' },
    { id = 178, name = 'Bustle of the Capital', expansion = 'Treasures of Aht Urhgan', activity = 'Towns & Cities' },
    { id = 179, name = 'Vana\'diel March #4', expansion = 'Treasures of Aht Urhgan', activity = 'Title & Themes' },
    { id = 180, name = 'Thunder of the March', expansion = 'Wings of the Goddess', activity = 'Story & Cutscenes' },
    { id = 181, name = 'Dash de Chocobo (Low Quality)', expansion = 'Original XI / Zilart-era', activity = 'Travel & Chocobo' },
    { id = 182, name = 'Stargazing', expansion = 'Wings of the Goddess', activity = 'Story & Cutscenes' },
    { id = 183, name = 'A Puppet\'s Slumber', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 184, name = 'Eternal Gravestone', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 185, name = 'Ever-Turning Wheels', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 186, name = 'Iron Colossus', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 187, name = 'Ragnarok', expansion = 'Treasures of Aht Urhgan', activity = 'Battle Arenas & Combat' },
    { id = 188, name = 'Choc-a-bye Baby', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 189, name = 'An Invisible Crown', expansion = 'Treasures of Aht Urhgan', activity = 'Story & Cutscenes' },
    { id = 190, name = 'The Sanctuary of Zi\'Tah', expansion = 'Rise of the Zilart', activity = 'Fields & Dungeons' },
    { id = 191, name = 'Battle Theme #3', expansion = 'Rise of the Zilart', activity = 'Battle Arenas & Combat' },
    { id = 192, name = 'Battle in the Dungeon #3', expansion = 'Rise of the Zilart', activity = 'Battle Arenas & Combat' },
    { id = 193, name = 'Tough Battle #2', expansion = 'Rise of the Zilart', activity = 'Battle Arenas & Combat' },
    { id = 194, name = 'Bloody Promises', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 195, name = 'Belief', expansion = 'Rise of the Zilart', activity = 'Battle Arenas & Combat' },
    { id = 196, name = 'Fighters of the Crystal', expansion = 'Rise of the Zilart', activity = 'Battle Arenas & Combat' },
    { id = 197, name = 'To the Heavens', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 198, name = 'Eald\'narche', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 199, name = 'Grav\'iton', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 200, name = 'Hidden Truths', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 201, name = 'End Theme', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 202, name = 'Moongate (Memoro de la Stono)', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 203, name = 'Ancient Verse of Uggalepih', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 204, name = 'Ancient Verse of Ro\'Maeve', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 205, name = 'Ancient Verse of Altepa', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 206, name = 'Revenant Maiden', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 207, name = 'Ve\'Lugannon Palace', expansion = 'Rise of the Zilart', activity = 'Fields & Dungeons' },
    { id = 208, name = 'Rabao', expansion = 'Rise of the Zilart', activity = 'Towns & Cities' },
    { id = 209, name = 'Norg', expansion = 'Rise of the Zilart', activity = 'Towns & Cities' },
    { id = 210, name = 'Tu\'Lia', expansion = 'Rise of the Zilart', activity = 'Fields & Dungeons' },
    { id = 211, name = 'Ro\'Maeve', expansion = 'Rise of the Zilart', activity = 'Fields & Dungeons' },
    { id = 212, name = 'Dash de Chocobo', expansion = 'Rise of the Zilart', activity = 'Travel & Chocobo' },
    { id = 213, name = 'Hall of the Gods', expansion = 'Rise of the Zilart', activity = 'Story & Cutscenes' },
    { id = 214, name = 'Eternal Oath', expansion = 'Rise of the Zilart', activity = 'Events & Special' },
    { id = 215, name = 'Clash of Standards', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 216, name = 'On this Blade', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 217, name = 'Kindred Cry', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 218, name = 'Depths of the Soul', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 219, name = 'Onslaught', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 220, name = 'Turmoil', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 221, name = 'Moblin Menagerie - Movalpolos', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 222, name = 'Faded Memories - Promyvion', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 223, name = 'Conflict: March of the Hero', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 224, name = 'Dusk and Dawn', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 225, name = 'Words Unspoken - Pso\'Xja', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 226, name = 'Conflict: You Want to Live Forever?', expansion = 'Chains of Promathia', activity = 'Battle Arenas & Combat' },
    { id = 227, name = 'Sunbreeze Shuffle', expansion = 'Original XI / Zilart-era', activity = 'Events & Special' },
    { id = 228, name = 'Gates of Paradise - The Garden of Ru\'Hmet', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 229, name = 'Currents of Time', expansion = 'Chains of Promathia', activity = 'Travel & Chocobo' },
    { id = 230, name = 'A New Horizon - Tavnazian Archipelago', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 231, name = 'Celestial Thunder', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 232, name = 'The Ruler of the Skies', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 233, name = 'The Celestial Capital - Al\'Taieu', expansion = 'Chains of Promathia', activity = 'Fields & Dungeons' },
    { id = 234, name = 'Happily Ever After', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 235, name = 'First Ode: Nocturne of the Gods', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 236, name = 'Fourth Ode: Clouded Dawn', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 237, name = 'Third Ode: Memoria de la Stona', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 238, name = 'A New Morning', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 239, name = 'Jeuno - Starlight Celebration', expansion = 'Original XI / Zilart-era', activity = 'Towns & Cities' },
    { id = 240, name = 'Second Ode: Distant Promises', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 241, name = 'Fifth Ode: A Time for Prayer', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 242, name = 'Unity', expansion = 'Chains of Promathia', activity = 'Title & Themes' },
    { id = 243, name = 'Grav\'iton (CoP)', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 244, name = 'Revenant Maiden (CoP)', expansion = 'Chains of Promathia', activity = 'Story & Cutscenes' },
    { id = 245, name = 'The Forgotten City - Tavnazian Safehold', expansion = 'Chains of Promathia', activity = 'Towns & Cities' },
    { id = 246, name = 'March of the Allied Forces', expansion = 'Wings of the Goddess', activity = 'Story & Cutscenes' },
    { id = 247, name = 'Roar of the Battle Drums', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 248, name = 'Young Griffons in Flight', expansion = 'Wings of the Goddess', activity = 'Story & Cutscenes' },
    { id = 249, name = 'Run Maggot, Run!', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 250, name = 'Under a Clouded Moon', expansion = 'Wings of the Goddess', activity = 'Fields & Dungeons' },
    { id = 251, name = 'Autumn Footfalls', expansion = 'Wings of the Goddess', activity = 'Fields & Dungeons' },
    { id = 252, name = 'Flowers on the Battlefield', expansion = 'Wings of the Goddess', activity = 'Fields & Dungeons' },
    { id = 253, name = 'Echoes of a Zephyr', expansion = 'Wings of the Goddess', activity = 'Fields & Dungeons' },
    { id = 254, name = 'Griffons Never Die', expansion = 'Wings of the Goddess', activity = 'Battle Arenas & Combat' },
    { id = 900, name = 'Distant Worlds', expansion = 'Rhapsodies / Other', activity = 'Events & Special' },
};

for i, track in ipairs(tracks) do
    if track.id == 109 then selected = i; break; end
end

local search_text = { '' };
local browse_mode = 1; -- 1 = activity, 2 = expansion
local favorites = {};
local auto_play_selection = false;
-- Session playlist. Queue navigation is manual until track durations are verified.
local playlist = {}
local queue_pos = 0
local show_playlist = false
local queue_page = 1
local waveform_enabled = true
local waveform_phase = 0
local waveform_last_clock = os.clock()
local playlist_message = 'Queue is empty.'

local function queue_add(index)
    if not tracks[index] then return end
    playlist[#playlist + 1] = index
    playlist_message = 'Queued: ' .. tracks[index].name
end

local function queue_move(pos, delta)
    local other = pos + delta
    if pos < 1 or pos > #playlist or other < 1 or other > #playlist then return end
    playlist[pos], playlist[other] = playlist[other], playlist[pos]
    if queue_pos == pos then queue_pos = other
    elseif queue_pos == other then queue_pos = pos end
end

local function queue_remove(pos)
    if pos < 1 or pos > #playlist then return end
    table.remove(playlist, pos)
    if queue_pos > pos then queue_pos = queue_pos - 1
    elseif queue_pos == pos then queue_pos = 0 end
    playlist_message = #playlist == 0 and 'Queue is empty.' or 'Track removed.'
end

local category_order = {
    [1] = { 'Favorites', 'Towns & Cities', 'Fields & Dungeons', 'Battle Arenas & Combat', 'Travel & Chocobo', 'Story & Cutscenes', 'Title & Themes', 'Events & Special' },
    [2] = { 'Favorites', 'Original XI / Zilart-era', 'Rise of the Zilart', 'Chains of Promathia', 'Treasures of Aht Urhgan', 'Wings of the Goddess', 'Seekers of Adoulin', 'Abyssea / Voidwatch', 'Rhapsodies / Other', 'The Voracious Resurgence' },
};

local function request_track(index, automatic)
    local track = tracks[index];
    if not track then return false; end
    local ok_manager, pm = pcall(function () return AshitaCore:GetPacketManager(); end);
    if not ok_manager or not pm then
        status = 'Packet manager unavailable.';
        last_result = status;
        return false;
    end

    -- Windower SetBGM-style local 0x05F payload. Set all eight categories;
    -- this was the method that produced audible playback in Phoenix testing.
    for music_type = 0, 7 do
        local id = track.id;
        local bytes = { 0x5F, 0x04, 0x00, 0x00,
            music_type % 256, math.floor(music_type / 256),
            id % 256, math.floor(id / 256) };
        local ok, result = pcall(function ()
            return pm:AddIncomingPacket(0x05F, bytes);
        end);
        if not ok or result == false then
            status = string.format('Music request failed at type %d: %s', music_type, tostring(result));
            last_result = status;
            print('[VanaRadio] ' .. status);
            return false;
        end
    end
    active_track = index;
    last_result = string.format('Sent 8 music requests for %s (ID %d).', track.name, track.id);
    status = (automatic and 'Auto reapply: ' or 'Requested: ') .. track.name;
    if not automatic then print('[VanaRadio] ' .. last_result); end
    return true;
end

local function queue_play(pos)
    local index = playlist[pos]
    if not index then return false end
    if request_track(index, false) then
        queue_pos = pos
        selected = index
        return true
    end
    return false
end

local function queue_step(delta)
    if #playlist == 0 then return false end
    local next_pos = queue_pos + delta
    if queue_pos == 0 then next_pos = delta > 0 and 1 or #playlist end
    if next_pos < 1 or next_pos > #playlist then
        playlist_message = 'End of playlist.'
        return true
    end
    queue_play(next_pos)
    return true
end

-- Animated simulated waveform using ImGui's native plot widget.
-- This avoids draw-list API mismatches observed in Ashita v4.
-- The animation is decorative; it does not read FFXI audio samples.
local wave_plot_supported = nil
local function draw_waveform()
    if not waveform_enabled then return end
    local now = os.clock()
    local elapsed = math.max(0, math.min(now - waveform_last_clock, 0.1))
    waveform_last_clock = now
    waveform_phase = waveform_phase + elapsed * 3.2

    local samples = {}
    local count = 96
    for i = 1, count do
        local t = (i - 1) / (count - 1)
        local envelope = 0.18 + 0.82 * math.sin(math.pi * t)^2
        samples[i] = (math.sin(t * math.pi * 10 - waveform_phase) * 0.68
            + math.sin(t * math.pi * 21 + waveform_phase * 0.43) * 0.20) * envelope
    end
    local ok_avail, avail = pcall(imgui.GetContentRegionAvail)
    local width = 390
    if ok_avail and type(avail) == 'table' and type(avail[1]) == 'number' then
        width = math.max(150, math.min(avail[1] - 8, 520))
    end
    -- Ashita's ImGui bindings differ by version; probe the native PlotLines
    -- signatures safely. Unlike the old code, no literal tilde fallback.
    local attempts = {
        function() return imgui.PlotLines('##farplane_wave', samples, count, 0, '', -1.0, 1.0, { width, 44 }) end,
        function() return imgui.PlotLines('##farplane_wave', samples, count, 0, nil, -1.0, 1.0, { width, 44 }) end,
        function() return imgui.PlotLines('##farplane_wave', samples, count, 0, '', -1.0, 1.0) end,
        function() return imgui.PlotLines('##farplane_wave', samples) end,
    }
    for _, attempt in ipairs(attempts) do
        if pcall(attempt) then
            wave_plot_supported = true
            return
        end
    end
    wave_plot_supported = false
    imgui.Text('Waveform unavailable (ImGui PlotLines unsupported)')
end

local function write_music(e, offset, id)
    ashita.bits.pack_be(e.data_modified_raw, id, offset, 0, 16);
end

ashita.events.register('packet_in', 'vanaradio_packet', function (e)
    if e.injected then return; end
    if e.id == 0x00A then
        zone_count = zone_count + 1;
        last_zone_status = persistent_mode and 'Persistent zone override requested.' or 'Normal zone event observed.';
    end
    if not (persistent_mode or zone_override) then return; end
    local track = tracks[active_track or selected];
    if not track then return; end
    if e.id == 0x00A then
        if e.size and e.size < 0x5E then return; end
        write_music(e, 0x56, track.id);
        write_music(e, 0x58, track.id);
        write_music(e, 0x5A, track.id);
        write_music(e, 0x5C, track.id);
    elseif e.id == 0x05F then
        if e.size and e.size < 8 then return; end
        write_music(e, 0x06, track.id);
    end
end);

local function stop_control()
    persistent_mode = false;
    zone_override = false;
    active_track = nil;
    status = 'VanaRadio control off. Game music resumes at its next normal event.';
end

ashita.events.register('command', 'vanaradio_command', function (e)
    local args = e.command:args();
    local cmd = (args[1] or ''):lower();
    if cmd ~= '/vr' and cmd ~= '/vanaradio' then return; end
    e.blocked = true;
    local action = (args[2] or ''):lower();
    if action == 'play' or action == 'now' or action == 'all' then
        request_track(selected, false);
    elseif action == 'next' then
        if not queue_step(1) then
            selected = (selected % #tracks) + 1;
            request_track(selected, false);
        end
    elseif action == 'prev' then
        if not queue_step(-1) then
            selected = ((selected - 2) % #tracks) + 1;
            request_track(selected, false);
        end
    elseif action == 'on' then
        zone_override = true;
        status = 'Zone override ON.';
    elseif action == 'off' or action == 'stop' then
        stop_control();
    elseif action == 'persist' or action == 'auto' then
        persistent_mode = not persistent_mode;
        status = 'Persistent Music Mode ' .. (persistent_mode and 'ON: zone override enabled.' or 'OFF.');
    elseif action == 'help' then
        print('[VanaRadio] /vr UI | /vr play | /vr next | /vr prev | /vr persist | /vr on (zone override) | /vr off');
    else
        visible = not visible;
    end
end);

-- Farplane theme: midnight navy, ember orange, and warm gold.
-- Style pushes are guarded for compatibility with Ashita v4 ImGui builds.
local farplane_colors = {
    { ImGuiCol_WindowBg,       { 0.045, 0.105, 0.195, 0.98 } },
    { ImGuiCol_ChildBg,        { 0.065, 0.145, 0.255, 0.98 } },
    { ImGuiCol_PopupBg,        { 0.060, 0.120, 0.210, 0.98 } },
    { ImGuiCol_Border,         { 0.98, 0.48, 0.09, 0.85 } },
    { ImGuiCol_Text,           { 0.98, 0.94, 0.86, 1.00 } },
    { ImGuiCol_TextDisabled,   { 0.57, 0.58, 0.61, 1.00 } },
    { ImGuiCol_FrameBg,        { 0.095, 0.115, 0.180, 1.00 } },
    { ImGuiCol_FrameBgHovered, { 0.19, 0.15, 0.15, 1.00 } },
    { ImGuiCol_FrameBgActive,  { 0.28, 0.16, 0.12, 1.00 } },
    { ImGuiCol_TitleBg,        { 0.035, 0.095, 0.19, 1.00 } },
    { ImGuiCol_TitleBgActive,  { 0.075, 0.20, 0.34, 1.00 } },
    { ImGuiCol_Button,         { 0.42, 0.19, 0.055, 1.00 } },
    { ImGuiCol_ButtonHovered,  { 0.91, 0.37, 0.035, 1.00 } },
    { ImGuiCol_ButtonActive,   { 1.00, 0.55, 0.08, 1.00 } },
    { ImGuiCol_Header,         { 0.12, 0.24, 0.36, 1.00 } },
    { ImGuiCol_HeaderHovered,  { 0.82, 0.33, 0.045, 1.00 } },
    { ImGuiCol_HeaderActive,   { 0.98, 0.48, 0.07, 1.00 } },
    { ImGuiCol_CheckMark,      { 1.00, 0.60, 0.20, 1.00 } },
    { ImGuiCol_Separator,      { 0.45, 0.24, 0.12, 0.90 } },
    { ImGuiCol_ScrollbarBg,    { 0.045, 0.060, 0.100, 0.85 } },
    { ImGuiCol_ScrollbarGrab,  { 0.42, 0.24, 0.12, 0.90 } },
    { ImGuiCol_ScrollbarGrabHovered, { 0.70, 0.34, 0.10, 1.00 } },
    { ImGuiCol_ScrollbarGrabActive,  { 0.90, 0.45, 0.12, 1.00 } },
}
local function farplane_push_colors()
    local count = 0
    for _, entry in ipairs(farplane_colors) do
        if type(entry[1]) == 'number' then
            local ok = pcall(imgui.PushStyleColor, entry[1], entry[2])
            if ok then count = count + 1 end
        end
    end
    return count
end

-- Rounded, oversized radio-dial controls. No texture dependencies.
-- FrameRounding is ImGui style variable 12 in the standard ImGui enum.
-- If this Ashita build lacks the overload, fall back to its normal buttons.
local function radio_dial(label, width, height)
    local rounding = (type(ImGuiStyleVar_FrameRounding) == 'number') and ImGuiStyleVar_FrameRounding or 12
    local pushed = pcall(imgui.PushStyleVar, rounding, height / 2)
    local ok, clicked = pcall(imgui.Button, label, { width, height })
    if pushed then pcall(imgui.PopStyleVar, 1) end
    if ok then return clicked == true end
    return imgui.Button(label)
end

ashita.events.register('d3d_present', 'vanaradio_present', function ()
    if not visible then return; end
    local farplane_color_count = farplane_push_colors();
    imgui.SetNextWindowSize({ 540, 555 }, ImGuiCond_FirstUseEver);
    local open = { visible };
    if imgui.Begin('VanaRadio', open, 8 + 16) then
        imgui.Text('Library  (' .. tostring(#tracks) .. ' tracks)');
        if imgui.Button(browse_mode == 1 and '[By Activity]' or 'By Activity') then browse_mode = 1; end
        imgui.SameLine();
        if imgui.Button(browse_mode == 2 and '[By Expansion]' or 'By Expansion') then browse_mode = 2; end
        imgui.SameLine();
        imgui.Text('Search:');
        imgui.SameLine();
        imgui.InputText('##vr_search', search_text, 128);
        local query = tostring(search_text[1] or ''):lower();
        -- Ashita ImGui bindings differ between builds. Try supported overloads
        -- safely; never let a signature mismatch crash d3d_present.
        local child_started = false;
        local child_visible = true;
        local child_attempts = {
            function () return imgui.BeginChild('vr_tracklist', { 0, 215 }, true, 0); end,
            function () return imgui.BeginChild('vr_tracklist', { 0, 215 }, false, 0); end,
            function () return imgui.BeginChild('vr_tracklist', { 0, 215 }, true); end,
            function () return imgui.BeginChild('vr_tracklist', { 0, 215 }); end,
        };
        for _, attempt in ipairs(child_attempts) do
            local ok, result = pcall(attempt);
            if ok then
                child_started = true;
                child_visible = result ~= false;
                break;
            end
        end
        if child_started and child_visible then
            do
            for _, group in ipairs(category_order[browse_mode]) do
                local matching = {};
                for i, track in ipairs(tracks) do
                    local member = (group == 'Favorites' and favorites[track.id])
                        or (group ~= 'Favorites' and (browse_mode == 1 and track.activity == group or track.expansion == group));
                    if member and (query == '' or track.name:lower():find(query, 1, true)
                        or tostring(track.id):find(query, 1, true)) then
                        matching[#matching + 1] = i;
                    end
                end
                if #matching > 0 then
                    if imgui.CollapsingHeader(group .. ' (' .. #matching .. ')##vr_' .. group) then
                        for _, i in ipairs(matching) do
                            local track = tracks[i];
                            if imgui.Selectable(track.name .. '  [' .. track.id .. ']##vr_track_' .. group .. i, selected == i) then
                                selected = i;
                                status = 'Selected ' .. track.name .. '.';
                                if auto_play_selection then request_track(selected, false); end
                            end
                        end
                    end
                end
            end
            end
        end
        if child_started then imgui.EndChild(); else imgui.Text('Scrollable library unavailable: BeginChild binding mismatch.'); end
        if imgui.Button(favorites[tracks[selected].id] and 'Unfavorite' or 'Favorite') then
            favorites[tracks[selected].id] = not favorites[tracks[selected].id];
        end
        imgui.SameLine();
        if imgui.Button(auto_play_selection and 'Auto Play: ON' or 'Auto Play: OFF') then
            auto_play_selection = not auto_play_selection;
        end
        imgui.SameLine()
        if imgui.Button('Queue +') then queue_add(selected) end
        imgui.SameLine()
        if imgui.Button(show_playlist and 'Hide Queue' or 'Playlist (' .. #playlist .. ')') then
            show_playlist = not show_playlist
        end
        if show_playlist then
            imgui.Separator()
            imgui.Text('PLAYLIST  /  MANUAL QUEUE')
            if #playlist == 0 then imgui.Text('Queue empty - select a song and press Queue +') end
            -- Keep the list compact and avoid a second incompatible child-window API.
            local page_count = math.max(1, math.ceil(#playlist / 4))
            queue_page = math.max(1, math.min(queue_page, page_count))
            if page_count > 1 then
                if imgui.Button('< Page') then queue_page = math.max(1, queue_page - 1) end
                imgui.SameLine()
                imgui.Text(queue_page .. '/' .. page_count)
                imgui.SameLine()
                if imgui.Button('Page >') then queue_page = math.min(page_count, queue_page + 1) end
            end
            for pos = (queue_page - 1) * 4 + 1, math.min(queue_page * 4, #playlist) do
                local index = playlist[pos]
                local label = (queue_pos == pos and '> ' or '  ') .. pos .. '. ' .. tracks[index].name
                if imgui.Button(label .. '##queueplay' .. pos) then queue_play(pos) end
                imgui.SameLine()
                if imgui.Button('^##queueup' .. pos) then queue_move(pos, -1) end
                imgui.SameLine()
                if imgui.Button('v##queuedown' .. pos) then queue_move(pos, 1) end
                imgui.SameLine()
                if imgui.Button('X##queuedelete' .. pos) then queue_remove(pos) end
            end
            if #playlist > 0 then
                if imgui.Button('Play Queue') then queue_play(1) end
                imgui.SameLine()
                if imgui.Button('Clear Queue') then playlist = {}; queue_pos = 0; playlist_message = 'Queue cleared.' end
            end
            imgui.Text(playlist_message)
        end
        imgui.Separator();
        -- Farplane console: glowing track readout with compact brass-style dials.
        local now_name = (active_track and tracks[active_track] and tracks[active_track].name) or 'Idle'
        local function console_text(color, value)
            local ok = pcall(imgui.TextColored, color, value)
            if not ok then imgui.Text(value) end
        end
        -- Amber readout with separators, kept outside the scrolling library.
        console_text({ 1.00, 0.65, 0.22, 1.00 }, '--- FARPLANE  /  NOW PLAYING ---')
        console_text({ 1.00, 0.88, 0.60, 1.00 }, now_name)
        imgui.Text('Selected: ' .. tracks[selected].name .. '  [' .. tracks[selected].id .. ']')
        draw_waveform()
        console_text({ 0.72, 0.40, 0.16, 1.00 }, '--------------------------------------')
        imgui.Spacing()
        -- Center the entire dial bank as a group using available content width.
        -- 82 + 92 + 82 + 82 = 338, with three 20px gaps = 398px.
        local dial_bank_width = 398
        local ok_avail, available = pcall(imgui.GetContentRegionAvail)
        local ok_x, current_x = pcall(imgui.GetCursorPosX)
        if ok_avail and type(available) == 'table' and type(available[1]) == 'number'
            and ok_x and type(current_x) == 'number' and available[1] > dial_bank_width then
            pcall(imgui.SetCursorPosX, current_x + (available[1] - dial_bank_width) / 2)
        end
        if radio_dial('PREV##vr_prev', 82, 82) then
            if not queue_step(-1) then
                selected = ((selected - 2) % #tracks) + 1
                request_track(selected, false)
            end
        end
        imgui.SameLine(0, 20)
        if radio_dial('PLAY##vr_play', 92, 92) then
            if #playlist > 0 and queue_pos == 0 then queue_play(1)
            else request_track(selected, false) end
        end
        imgui.SameLine(0, 20)
        if radio_dial('STOP##vr_stop', 82, 82) then stop_control() end
        imgui.SameLine(0, 20)
        if radio_dial('NEXT##vr_next', 82, 82) then
            if not queue_step(1) then
                selected = (selected % #tracks) + 1
                request_track(selected, false)
            end
        end
        imgui.Spacing()
        imgui.Separator();
        if imgui.Button(persistent_mode and 'Persistent: ON' or 'Persistent: OFF') then
            persistent_mode = not persistent_mode;
            if persistent_mode then
                -- This uses the same zone-packet override proven in v0.13.
                -- No 60-second injection timer and no automatic song restarts.
                if not active_track then
                    status = 'Persistent mode ON. Select a track and press Play.';
                else
                    status = 'Persistent mode ON. Selected track will be applied when zoning.';
                end
            else
                status = 'Persistent mode OFF. Normal zone music will load on next zone.';
            end
        end
        imgui.SameLine();
        if imgui.Button(zone_override and 'Zone Override: ON' or 'Zone Override: OFF') then
            zone_override = not zone_override;
            status = 'Legacy Zone Override ' .. (zone_override and 'ON' or 'OFF');
        end
        imgui.SameLine()
        if imgui.Button(waveform_enabled and 'Wave: ON' or 'Wave: OFF') then waveform_enabled = not waveform_enabled end
        -- Diagnostics remain available in the console; keep the player compact.
    end
    imgui.End();
    if farplane_color_count > 0 then imgui.PopStyleColor(farplane_color_count); end
    visible = open[1];
end);