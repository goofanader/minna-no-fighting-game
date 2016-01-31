SPRITE_SIZE = 32
BOSS_SIZE = 48
MAX_PLAYERS = 12
Y_POS = 160

CHARACTERS_FOLDER = "characters"
SITE_START = "http://www.minnalumni.org/goofanader"
SEARCH_API_URL = SITE_START .. "/api/v1_0/search.php"
IMAGES_URL = SITE_START .. ".media/images/CREATED_SPRITESHEETS"

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end
