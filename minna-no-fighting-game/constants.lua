SPRITE_SIZE = 32
BOSS_SIZE = 48
MAX_PLAYERS = 12
Y_POS = 160
ORIG_WIDTH = 480
ORIG_HEIGHT = 320

KEYBOARD = "keyboard"
JOYSTICK = "joystick"

REGULAR_CLASS = "REGULAR"
ANIMAL_CLASS = "ANIMAL"
CLOSE_RANGE = "CLOSE"
NO_RANGE = "NONE"

CORRECT_SLASH = love.system.getOS() == "Windows" and "\\" or "/"

-- stage names
THE_SILO = 1
SUBWAY = 2

ASSETS_FOLDER = "assets"
BACKGROUNDS_FOLDER = ASSETS_FOLDER .. "/backgrounds"
MUSIC_FOLDER = ASSETS_FOLDER .. "/music"
SOUNDS_FOLDER = ASSETS_FOLDER .. "/sounds"
SPRITES_FOLDER = ASSETS_FOLDER .. "/sprites"
BOSSES_FOLDER = SPRITES_FOLDER .. "/bosses"
BOSS_CLASS_FOLDER = "classes/BossClasses"

CHARACTERS_FOLDER = "characters"

SITE_START = "http://www.minnalumni.org/goofanader"
SEARCH_API_URL = SITE_START .. "/api/v1_0/search.php"
IMAGES_URL = SITE_START .. ".media/images/CREATED_SPRITESHEETS"

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function convertToCorrectSlash(filename)
  return filename:gsub("/", CORRECT_SLASH)
end

---
-- Splits a string on the given pattern, returned as a table of the delimited strings.
-- @param str the string to parse through
-- @param pat the pattern/delimiter to look for in str
-- @return a table of the delimited strings. If pat is empty, returns str. If str is not given, aka '' is given, then it returns an empty table.
function split(str, pat)
   if pat == '' then
      return str
   end

   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
