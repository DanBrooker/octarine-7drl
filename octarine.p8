pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- octarine
-- draconisnz
screen = 127
size=32
dev=false

function entity_create(x, y, spr, col, name, args)
  local new_entity = {
   name = name,
   x = x,
   y = y,
   ox = 0,
   oy = 0,
   hp = 2,
   flip = false,
   col = col,
   ani = {spr, spr+1, spr, spr+2},
   -- range = 1,
   flash = 0,
   -- smart = false,
   stun = 0,
   roots = 0,
   atk = 1
  }
  for k,v in pairs(args or {}) do
   new_entity[k] = v
  end
  add(entities, new_entity)
  return new_entity
end

function entity_draw(self)
 local col = self.col
 if self.flash>0 then
  self.flash-=1
  col=7
 end
 local frame = self.stun != 0 and self.ani[1] or getframe(self.ani)
 local x, y = self.x*8+self.ox, self.y*8+self.oy
 drawspr(frame, x, y,col,self.flp)
 if (self.stun !=0) draws(10, x, y, 0, false)
 if (self.roots !=0) draws(11, x, y, 0, false)
 if (self.linked) draws(12, x, y, 0, false)
end

function slime(x,y)
 return entity_create(x, y, 51, 11, 'slime', {})
end

function super_slime(x,y)
 return entity_create(x, y, 51, 10, 'suberb slime', {})
end

function mushroom(x,y)
 return entity_create(x,y, 35, 9, 'mushroom', {hp=3, stupid=true})
end

function super_mushroom(x,y)
 return entity_create(x,y, 35, 9, 'mega-shroom', {hp=3, atk=2})
end

function bat(x,y)
 return entity_create(x,y, 19, 5, 'bat', {flying=true})
end

function super_bat(x,y)
 return entity_create(x,y, 19, 13, 'death bat', {flying=true, atk=2})
end

function sprite(x,y)
 return entity_create(x,y, 3, 9, 'sprites', {flying=true, explodes=1, hp=1, atk=0})
end

function super_sprite(x,y)
 return entity_create(x,y, 3, 8, 'thermo-nuclear sprites', {flying=true, explodes=2, hp=1, atk=0})
end

function flame(x,y)
 return entity_create(x,y, 54, 9, 'flame', {trail="flame"})
end

function super_flame(x,y)
 return entity_create(x,y, 54, 12, 'pureflame', {trail="pureflame"})
end

function boss(x,y)
 return entity_create(x,y, 32, 14, 'boss', {boss=true, hp=8})
end

function _init()
 t=0

 dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}

 dirs = {{-1,0}, {1,0}, {0,-1}, {0,1}, {1, 1}, {-1, -1}, {1, -1}, {-1, 1}}
 magictiles = { 114, 115, 116, 117, 118, 119, 120, 121, 122}
 walltiles = {64, 64, 64, 64, 64, 64, 80, 96}
 walltiles2 = {64, 64, 64, 64, 64, 67, 80, 96, 113}
 magics = { "earth", "nature", "water", "air", "fire", "dark", "light", "octarine" }
 magiccols = { 4, 3, 12, 6, 8, 5, 7, 13 }
 items = { "wand", "staff", "tome" }
 levels = {
  "dungeon dimension",
  "ii",
  "iii",
  "iv",
  "v",
  "vi",
  "vii",
  "probably should not be here"
 }
 tips = {
  "earth can stun",
  "light can heal",
  "dark can link souls",
  "the void is best avoided",
  "water splashes",
  "nature binds",
  "remember to use all your wands"
 }
 room_count = { 4, 4, 6, 6, 8, 8, 8, 2 }
 monster_count = {1,2,2,3}
 monster_levels = {
  {slime, slime, mushroom},
  {slime, slime, super_slime, mushroom, mushroom},
  {mushroom, mushroom, super_mushroom, bat, sprite, sprite},
  {mushroom, super_mushroom, bat, super_bat, sprite, sprite, super_sprite},
  {super_mushroom, bat, super_bat, sprite, super_sprite, flame},
  {super_mushroom, super_bat, sprite, super_sprite, flame, super_flame},
  {sprite, super_sprite, flame, super_flame},
  {}
 }

 debug={}
 message = { ticks= 0 }
 palettes={earth={4,5,6}, nature={3,11}, water={1,12,13}, air={6,7}, fire={8,9,10}, dark={2,5}, light={6,7}, octarine={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}}

 startgame()
end

function _update60()
 t+=1
 _upd()
 dofloats()
 foreach(particles,update_part)
end

function _draw()
 _drw()
 -- drawind()
 checkfade()
 cursor(1,80)
 color(8)
 for txt in all(debug) do
  print(txt)
 end
end

function ui()
 camera(0,0)
 rectfill(0,screen-6,screen, screen, 7)

 -- health
 rectfill(0, 0, 11, 22, 0)
 local hearts = ""
 for i=1,player.hp do
  hearts = hearts .. "\x87"
 end
 print(hearts, 1, 1, 8)

 -- ammo
 local activemagic = magiccols[ stored[item] ]
 local chargesleft = charges[item]
 local col = activemagic
 if (chargesleft == 0) col = 15
 local chargec = ""
 for i=1,chargesleft do
  print( "\x85", 1, 2+ (8*i), col)
 end
 spr(13, 4, 7)

 -- instructions
 if dev then
   print("" .. player.x .. ", " .. player.y , 2, screen-5, 0)
 elseif aiming then
   print("\x8b\x91\x94\x83 to zap", 2, screen-5, 0)
 elseif charges[item] == 0 then
   print("z to recharge", 2, screen-5, 0)
 else
   print("z to aim, x change item", 2, screen-5, 0)
 end

 if message.ticks > 0 then
  local text = message.text
  rectfill(0,vcenter(text)-7,screen, vcenter(text)-1, 7)
  print(text, hcenter(text), vcenter(text)-6, 0)
  message.ticks -= 1
 end
end

function minimap_draw()
  for x=0, size-1 do
    for y=0, size-1 do
			  if mget(x,y) then
	      pset(x, y, mget(x,y) % 15 + 1)
			  end
    end
  end

	foreach(entities, function(entity)
		pset(entity.x,entity.y,8)
	end)

 pset(player.x,player.y,8)
end

function startgame()
 fadeperc=1
 buttbuff=-1
 shake=0
 shakex=0
 shakey=0

 killer = nil

 charges = { 7, 7, 7 }
 stored = { 1,2,3 }
 item = 1
 aiming = false
 linked = {}
 player=entity_create(6, 4, 48, 8, 'yourself', {hp=3})
 -- player.hp = 3
 p_t=0

 mapgen(1)
 _upd=update_game
 _drw=draw_game
end

function mapgen(level)
 lvl = level
 enemies={}
 enviro={}
 particles={}
 float={}
 entities={player}
 -- map gen should go here

 for i=0,size do
  for j=0,size do
   mset(i,j, 81)
  end
 end

 rooms = {}
 area = 26
 roomc = room_count[lvl]
 for i=1,roomc do
  local width = rand(4, 10)
  local height = rand(4, area/width)
  local x, y = rand(2, 28-width), rand(2, 28-height)
  room = {
   x=x,
   y=y,
   mx=x+width,
   my=y+height,
   w=width,
   h=height,
   i=i
  }
  add(rooms, room)
  for i=room.x,room.mx do
   for j=room.y,room.my do
    local tile = 113
    if i == room.x or i == room.mx then
     tile = lvl <= 4 and randa(walltiles) or randa(walltiles2)
    elseif j == room.y or j == room.my then
     tile = lvl <= 4 and 68 or randa({68,68, 113, 113, 67})
    elseif rand(1,10) > 8 then -- 20%
     tile = randa(magictiles)
    end
    mset(i,j, tile)
   end
  end
 end

 player.x = rooms[1].x + 1
 player.y = rooms[1].y + 1

 local notend = lvl != 7

 for i=1,#rooms do
   local room = rooms[i]
   local next = rooms[i % #rooms+1]

   local rx1, ry1 = room.x + flr(room.w/2), room.y + flr(room.h/2)
   local rx2, ry2 = next.x + flr(next.w/2), next.y + flr(next.h/2)
   local path = astar({rx1, ry1}, {rx2, ry2}, prefer_walkable)
   for point in all(path) do
    if not walkable(point[1],point[2]) then
     mset(point[1],point[2], 113)
    elseif mget(point[1],point[2]) == 81 then
     mset(point[1],point[2], 113)
    end
   end

   decorate(room)
   if (i > 1) infest(room)
 end

 if notend then

  local exx, exy = rooms[#rooms].x + 1, rooms[#rooms].y + 1
  -- add(debug, "exit " .. exx .. ", " .. exy)

  local path = astar({player.x, player.y}, {exx, exy}, prefer_walkable)
  for point in all(path) do
   if not walkable(point[1],point[2]) then
    mset(point[1],point[2], 113)
   elseif mget(point[1],point[2]) == 81 then
    mset(point[1],point[2], 113)
   end
  end
  mset(exx, exy, 97)
 else

  local x, y = random_in_room(rooms[#rooms])
  local monster_func = randa(monster_levels[lvl])
  local boss = boss(x,y)

 end

 banner(levels[level])
end

function nothing(room)
end

function plants(room)
 for i=room.x,room.mx do
  for j=room.y,room.my do
   if (rand(0,4) > 3) mset(i,j, 67)
  end
 end
end

function holes(room)
 for i=room.x,room.mx do
  for j=room.y,room.my do
   if (rand(0,4) > 3) mset(i,j, 81)
  end
 end
end

roomtypes = { plants, holes, nothing, nothing }
function decorate(room)
 randa(roomtypes)(room)
end

function random_in_room(room)
 -- add(debug, "room " .. room.x .. "," .. room.y .. "," .. room.w .. "," .. room.h )
 local n, x, y = 2, 0, 0
 repeat
  x, y = rand(room.x+1, room.w-2), rand(room.y+1, room.h-2)
  n += 1
  -- add(debug, "rnd " .. x .. "," .. y )
  if (not walkable(x, y, "entities")) x = 0
 until x > 0 or n == 0

 return x, y
end

-- add(enemies, entity_create(12, 3, 51, 8, 'red slime', {}))
-- add(enemies, entity_create(10, 5, 35, 9, 'orange mushroom'), {hp=3})
-- add(enemies, entity_create(12, 5, 19, 5, 'bat', {flying= true}))

-- add(enemies, entity_create(9, 10, 35, 12, 'blue mushroom', {}))
--
-- add(enemies, entity_create(6, 13, 35, 12, 'blue mushroom', {hp=3}))
-- add(enemies, entity_create(13, 12, 35, 2, 'purple mushroom', {hp=3}))
-- add(enemies, entity_create(10, 15, 35, 14, 'pink mushroom', {hp=3}))

function infest(room)
 -- number of enemies from level list
 local count = randa(monster_count)
 -- add(debug, "infest " ..count)
 for i=1,count  do
  local x, y = random_in_room(room)
  local dist = distance(x, y, player.x, player.y)

  if x and dist > 8 then
   local monster_func = randa(monster_levels[lvl])
   local m = monster_func(x,y)
   -- printh("spawn " .. m.name .. " " .. x .. "," .. y .. " dist=" .. dist, "debug.txt")
  end
 end
end

function banner(text)
	message = { text=text, ticks=90 }
end

function endgame()
 tip = randa(tips)
  _upd, _drw = update_endgame, draw_endgame
  fadeout(0.01)
end

function inmap(tx,ty)
	return tx > 0 and ty > 0 and tx < size and ty < size
end

function update_endgame()
  if getbutt() >= 0 then
   -- sfx(54)
   -- add(debug, "new game")
   fadeout()
   startgame()
  end
 end

function draw_endgame()
 cls()
 -- palt(12,true)
 -- spr(gover_spr,gover_x,30,gover_w,2)
 if win then
  local msg = "dimension mastered!"
  print(msg, hcenter(msg), vcenter(msg),2)
 else
  local msg = "lost to ".. killer
  print(msg, hcenter(msg), vcenter(msg),2)
  print(tip, hcenter(tip), vcenter(tip)+6, 6)
 end
 -- palt()
 color(5)
 cursor(40,56)
 -- if not win then
 --  print("floor: "..floor)
 -- end
 -- print("steps: "..st_steps)
 -- print("kills: "..st_kills)
 -- print("meals: "..st_meals)

 print("press ❎",46,90,5)
end

function update_ai()
  buffer()

  for entity in all(entities) do
   if entity != player then
    if entity.stun > 0 then
     entity.stun -= 1
    else
     -- add(debug, "action " .. entity.name)
     if entity.boss then
      boss_action(entity)
     else
      ai_action(entity)
     end
    end
    if (entity.roots > 0) entity.roots -= 1
   end
  end

  animate()
end

function env_at(x,y)
  for m in all(enviro) do
   if m.x==x and m.y==y then
    return m
   end
  end
end

function update_end_turn()
 for entity in all(entities) do
   entity.mov = nil
   local tile = mget(entity.x,entity.y)
   if tile == 97 and entity == player then
     mapgen(lvl + 1)
   elseif fget(tile, 5) then
    -- tip = 'watch your step'
    if (not entity.flying) dmg(entity, 2, 'the void')
   else
    local env = env_at(entity.x,entity.y)
    if env then
     -- add(debug, entity.name .. "=" .. env.type)
     if (entity.name != env.type) dmg(entity, 1, env.name)
    end
   end
  if (entity.hp <= 0) then
   on_death(entity)
  end
 end
 for env in all(enviro) do
  env.turns -= 1
  if(env.turns <= 0) del(enviro, env)
 end
 _upd = update_ai
end

function update_game()
  buffer()
  local endturn = input(buttbuff)
  buttbuff=-1

  if endturn then
    animate(update_end_turn)
    -- _upd = update_ai
  end
end

function draw_game()
 cls(0)
 do_shake()
 -- map()
 map(0, 0, 0, 0, size, size)

 player.col = magiccols[ stored[item] ]
 player.ani = player_ani( item )
 for entity in all(entities) do
   entity_draw(entity)
 end
 foreach(enviro,draw_enviro)
 foreach(particles,draw_part)
 for f in all(float) do
  oprint8(f.txt,f.x,f.y,f.c,0)
 end
 ui()
 if(dev) minimap_draw()
end

function player_ani( item )
 if item == 1 then
  return {48,49,48,50}
 elseif item == 2 then
  return {16,17,16,18}
 elseif item == 3 then
  return {32,33,32,34}
 end
end

function on_death(entity)
 if (entity.explodes) then
  explosion(entity.x * 8, entity.y * 8, 8, palettes.fire, {98, 102, 103})
  for i=1,4 do
   local dir = dirs[i]
   local dx, dy = dir[1], dir[2]

   for i=1,entity.explodes do
    local ddx, ddy = dx * i, dy * i
    local ent = entity_at(entity.x + ddx, entity.y + ddy)

    if(ent) then
     explosion(ent.x +ddx * 8, ent.y +ddy * 8, 4*i, palettes.fire, {98, 102, 103})
     dmg(ent, 1+entity.explodes-i, "explosion")
    end
   end

  end
 end

 local isLinked = false
 for ent in all(linked) do
  if ent==entity then
   isLinked = true
   break
  end
 end

 if isLinked then
  for ent in all(linked) do
   explosion(ent.x * 8, ent.y * 8, 4, palettes.dark, {98, 102, 103})
   ent.hp = 0
  end
  linked = {}
 end

 if entity.boss then
  win=true
  endgame()
 end

 del(entities, entity)
end

function update_animate()
 buffer()
 p_t=min(p_t+0.125,1)

 for entity in all(entities) do
  if entity.mov then
   entity:mov()
  end
 end

 if p_t==1 then
  -- if (_push_wait) wait(_push_wait)
  _upd=_push_upd or update_game

  for entity in all(entities) do
   entity.mov = nil
   if (entity.hp <= 0) then
    on_death(entity)
   end
  end
  if (player.hp <= 0) endgame()

 end
end

function buffer()
 if buttbuff==-1 then
  buttbuff=getbutt()
 end
end

function getbutt()
 for i=0,5 do
  if (btnp(i)) return i
 end
 return -1
end

function animate(push_upd)
 p_t=0
 _push_upd = push_upd
 _upd=update_animate
end

function moveplayer(dir)
 local dx, dy = dir[1], dir[2]
 local destx,desty=player.x+dx,player.y+dy
 local tle=mget(destx,desty)

 if walkable(destx,desty, "entities") then
  -- sfx(63)
  mobwalk(player,dx,dy)
  -- animate()
 else
  -- sfx(63)
  mobbump(player,dx,dy)
  -- animate()
 end
 return true
end

function move_towards(entity)
 local shuffled = shuffle({1,2,3,4})
 local moves = {}
 for i in all(shuffled) do
  local dir = dirs[i]
  local dx,dy = dir[1], dir[2]
  local x, y = entity.x + dx, entity.y + dy
  local dist = distance(x, y, player.x, player.y)
  if dist == 0 then
   mobbump(entity, dx, dy)
   dmg(player, entity.atk, entity.name)
   return
  elseif walkable(x, y, "entities") then
   if (entity.roots > 0) return
   if (mget(x,y) != 81 or entity.stupid) insert(moves, dir, dist)
  end
 end

 if #moves > 0 then
  local move = pop(moves)[1]
  -- add(debug, "move " .. move[1])
  if (entity.trail) add_enviro(entity.x, entity.y, entity.trail, 2)
  mobwalk(entity, move[1], move[2])
 end
end

function boss_action(entity)
 local dist = distance(entity.x, entity.y, player.x, player.y)
 local xa = entity.x == player.x
 local ya = entity.y == player.y
 if (dist <= 8 and (xa or ya)) then
  local dx, dy = normalise(player.x - entity.x, player.y - entity.y)
  local hx, hy = aimtile(entity, dx, dy)

  octarine(hx, hy, player, entity)
 else
  move_towards(entity)
 end

end

function ai_action(entity)
 if (distance(entity.x, entity.y, player.x, player.y) > 10) return
 move_towards(entity)
end

function push(stack,item)
	stack[#stack+1]=item
end

function pop(stack)
	local r = stack[#stack]
	stack[#stack]=nil
	return r
end

function insert(t, val, p)
	if #t >= 1 then
		add(t, {})
		for i=(#t),2,-1 do
			local next = t[i-1]
		 	if p < next[2] then
		  	t[i] = {val, p}
		  	return
		 	else
		  	t[i] = next
		 	end
		end
		t[1] = {val, p}
	else
		add(t, {val, p})
	end
end

function distance(ax, ay, bx, by)
  return abs(ax - bx) + abs(ay - by)
end

function walkable(x, y, mode)
 local mode = mode or ""
 local floor = not fget(mget(x,y), 7)
 if mode == "entities" then
  if (floor) return entity_at(x,y) == nil
 end
 if mode == "player" then
  if (floor) return player.x == x and player.y == y
 end
 return floor
end

function mobwalk(mb,dx,dy)
 mb.x+=dx --?
 mb.y+=dy

 mobflip(mb,dx)
 mb.sox,mb.soy=-dx*8,-dy*8
 mb.ox,mb.oy=mb.sox,mb.soy
 mb.mov=mov_walk
end

function mobbump(mb,dx,dy)
 mobflip(mb,dx)
 mb.sox,mb.soy=dx*8,dy*8
 mb.ox,mb.oy=0,0
 mb.mov=mov_bump
end

function mobflip(mb,dx)
 mb.flp = dx==0 and mb.flp or dx<0
end

function mov_walk(self)
 local tme=1-p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function mov_bump(self)
 local tme= p_t>0.5 and 1-p_t or p_t
 self.ox=self.sox*tme
 self.oy=self.soy*tme
end

function input(butt)
 if butt<0 then return false end
 if butt<4 then
  if aiming then
   return fireprojectile(player, dirs[butt+1])
  else
   return moveplayer(dirs[butt+1])
  end
 elseif butt==4 then
  return toogleshoot()
 elseif butt==5 then
  if aiming then
   return false -- maybe discharge if #enemies == 0
  else
   return switchitem()
  end
 end
end

function toogleshoot()
 if charges[item] == 0 then
  return reload()
 else
  aiming = not aiming
  return false
 end
end

function reload()
  local tile = mget(player.x, player.y)
  local m = fget(tile)
  -- add(debug, "m " .. m)
  if (magics[m]) then
   stored[item] = m
   mset(player.x, player.y, 113)
  elseif m == 9 then
   if (player.hp < 8) dmg(player, -1)
   mset(player.x, player.y, 113)
   return
  else
   -- m = stored[item]
   addfloat('no rune', player.x * 8, player.y * 8, '2')
   return
  end
  -- add(debug, "reload " .. magics[m])
  addfloat(magics[m], player.x * 8, player.y * 8, magiccols[m])
  charges[item] = 7
  return true
end

function switchitem()
 item = (item % #items) + 1
end

function fireprojectile(entity, dir)
 mobflip(entity, dir[1])
 aiming = false
 charges[item] -= 1
 hx, hy = throwtile(dir[1], dir[2])

 local m = magics[stored[item]]
 local hit = entity_at(hx, hy)
 -- if (hit) dmg(hit, 1)
 -- debug[1]= magics[stored[item]]
 effects[m](hx, hy, hit, entity)
 return true
end

function normalise(dx, dy)
 if dx > 0 then
  return 1, 0
 elseif dx < 0 then
  return -1, 0
 elseif dy > 0 then
  return 0, 1
 elseif dy < 0 then
  return 0, -1
 end
end

function air(hx, hy, target, caster)
 local x, y = hx * 8 + 4, hy * 8 + 4
 explosion(x, y, 2, palettes.air, {98, 100})
 if (target == nil) return
 -- knockback
 local dx, dy = normalise(target.x - caster.x, target.y - caster.y)
 -- check if hitting solid
 local nx, ny = target.x + dx, target.y + dy
 local damage = 1
 if walkable(nx, ny, 'entities') then
  mobwalk(target, dx, dy)
 else
  mobbump(target, dx, dy)
  damage = 2
 end
 -- animate()
 dmg(target, damage)
end

function earth(hx, hy, target, caster)
 local x, y = hx * 8 + 4, hy * 8 + 4
 explosion(x, y, 2, palettes.earth, {98, 100})
 if (target == nil) return
 -- knockback
 local dx, dy = normalise(target.x - caster.x, target.y - caster.y)

 -- check if hitting solid
 local nx, ny = target.x + dx, target.y + dy

 if not walkable(nx, ny, 'entities') then
   if target.hp > 1 then
    target.stun = 2
    addfloat("stun", target.x * 8 + 10, target.y * 8, 8)
   end
   local hit = entity_at(nx, ny)
   if hit then
    hit.stun = 2
    addfloat("stun", hit.x * 8 + 10, hit.y * 8, 8)
   end
 end
 mobbump(target, dx, dy)

 dmg(target, 1)
 -- animate()
end

function nature(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 explosion(x, y, 2, palettes.nature, {98, 102, 103})

 if (target == nil) return
 dmg(target, 1)
 if (target.flying) return
 target.roots = 3
 if (target.hp > 0) addfloat("tangled", target.x * 8 + 10, target.y * 8, 8)

 -- animate()
end

function water(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 explosion(x, y, 8, palettes.water, {98, 102, 103})

 if (target) dmg(target, 1)
 for i=1,4 do
  local dir = dirs[i]
  local dx, dy = dir[1], dir[2]
  local entity = entity_at(hx + dx, hy + dy)

  if entity then
   explosion(entity.x * 8, entity.y * 8, 8, palettes.water, {98, 102, 103})
   -- check is walkable
   if walkable(entity.x + dx, entity.y + dy, "entities") then
    mobwalk(entity, dx, dy)
   end
  end
 end

 -- animate()
end

enviro_animations = {
 flame={54,55,56},
 pureflame={54,55,56}
}
enviro_colours = {
 flame=10,
 pureflame=12
}
function add_enviro(x, y, type, turns)
 local new_effect = {
  x=x,
  y=y,
  ani=enviro_animations[type],
  type=type,
  col=enviro_colours[type],
  turns=turns + 1 or 2
 }
 add(enviro, new_effect)
end

function fire(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 -- todo; add tile effect to hx, hy
 if target == nil then
  local dx, dy = hx - caster.x, hy - caster.y
  local ox, oy = normalise(dx,dy)

  if walkable(hx,hy) then
   explosion(x, y, 2, palettes.fire, {98, 102, 103})
   add_enviro(hx, hy, "flame", 2)
  else
   explosion(x - ox * 8, y - oy * 8, 2, palettes.fire, {98, 102, 103})
   add_enviro(hx - ox, hy - oy, "flame", 2)
  end
 else
  explosion(x, y, 2, palettes.fire, {98, 102, 103})
  add_enviro(hx, hy, "flame", 1)
  -- dmg(target, 1)
 end
 -- animate()
end

function dark(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 explosion(x, y, 2, palettes.dark, {98, 102, 103})
 -- todo; add tile effect to hx, hy
 if (target == nil) return
 add(linked, target)
 target.linked = true
 dmg(target, 1)
 -- animate()
end

function light(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 explosion(x, y, 2, palettes.light, {101})

 if (target == nil) return
 if(target.hp < 8) dmg(target, -1)
 if(caster.hp < 8) dmg(caster, -1)
end

function octarine(hx, hy, target, caster)
 local x, y = hx * 8, hy * 8
 explosion(x, y, 2, palettes.octarine, {98, 102, 103})

 if target == nil then
  if mget(hx, hy) == 81 then
   dmg(caster, 2)
   explosion(caster.x, caster.y, 6, palettes.octarine, {98, 102, 103})
  else
   local dx, dy = hx - caster.x, hy - caster.y
   local ox, oy = normalise(dx,dy)
   mobwalk(caster, dx - ox, dy - oy)
  end
 else
  local dx, dy = target.x - caster.x, target.y - caster.y
  local cx, cy = caster.x - target.x, caster.y - target.y
  mobwalk(target, cx, cy)
  mobwalk(caster, dx, dy)
  dmg(target, 1, 'magic')
 end
 -- animate()
end

effects = {
 earth=earth,
 nature=nature,
 water=water,
 air=air,
 fire=fire,
 dark=dark,
 light=light,
 octarine=octarine
}

function dmg(entity, amount, cause)
 if amount < 0 then
  addfloat('+'.. abs(amount), entity.x * 8, entity.y * 8, 11)
 else
  addfloat('-'.. amount, entity.x * 8, entity.y * 8, 8)
 end
 entity.hp -= amount
 entity.flash = 10
 if (entity == player) killer = cause or "something"
end

function aimtile(entity, dx, dy)
 local tx,ty,i = entity.x,entity.y,0
 repeat
  tx += dx
  ty += dy
  i += 1
 until not walkable(tx,ty, "player") or i >= 8
 return tx,ty
end

function throwtile(dx, dy)
 local tx,ty,i = player.x,player.y,0
 repeat
  tx += dx
  ty += dy
  i += 1
 until not walkable(tx,ty, "entities") or i >= 8
 return tx,ty
end

function entity_at(x,y)
 for m in all(entities) do
  if m.x==x and m.y==y then
   return m
  end
 end
end

function getframe(ani)
 return ani[flr(t/15)%#ani+1]
end

function drawspr(_spr,_x,_y,_c,_flip)
 palt(0,false)
 draws(_spr,_x,_y,_c,_flip)
end

function draws(_spr,_x,_y,_c,_flip)
 pal(7,_c)
 spr(_spr,_x,_y,1,1,_flip)
 pal()
end

function addfloat(_txt,_x,_y,_c)
 add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function dofloats()
 for f in all(float) do
  f.y+=(f.ty-f.y)/10
  f.t+=1
  if f.t>50 then
   del(float,f)
  end
 end
end

function do_shake()
 shakex=8-rnd(16)
 shakey=8-rnd(16)

 shakex*=shake
 shakey*=shake

 local x, y = player.x*8+player.ox, player.y*8+player.oy
 camera(x-64 + shakex, y-64 + shakey)

 shake*=0.8
 if(shake<=0.05)shake=0
end

function create_part(x,y,dx,dy,sprite,life,sz,col)
 local p = {
  x=x,
  y=y,
  dx=dx,
  dy=dy,
  sprite=sprite,
  life=life,
  sz=sz,
  col=col
 }
 add(particles,p)
 return p
end

function update_part(p)
 if(p.life<=0)del(particles,p)

 if p.sz !=nil then
  p.sz-=0.2
 end

 p.x+=p.dx
 p.y+=p.dy

 p.life-=1
end

function draw_enviro(e)
 -- if e.type == "fire" then
  draws(getframe(e.ani), e.x * 8, e.y * 8, e.col)
 -- end
end

function draw_part(p)
 if p.sprite != 0 then
  draws(p.sprite, p.x, p.y, p.col)
  -- spr(p.sprite,p.x,p.y)
 else
  circfill(p.x,p.y,p.sz,p.col)
 end
end

function rand(min, max)
 return flr(rnd(max)+min)
end

function randf(min, max)
 return rnd(max)+min
end

function randa(array)
 return array[rand(1, #array)]
end

function smoke(x,y)
 create_part(x,y,rnd(1)-0.5,rnd(0.5)-1,0,rnd(30)+10,rnd(4)+2,5)
end

function explosion(x, y, sz, palette, particles)
 for i=1,sz*4 do
  create_part(x,y,(rnd(16)-8)/16,(rnd(16)-8)/16, randa(particles), rnd(30)+10,rnd(sz)+3,randa(palette))
 end
 shake=sz/6
end

function dofade()
 local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
 for j=1,15 do
  col = j
  kmax=flr((p+j*1.46)/22)
  for k=1,kmax do
   col=dpal[col]
  end
  pal(j,col,1)
 end
end

function checkfade()
 if fadeperc>0 then
  fadeperc=max(fadeperc-0.04,0)
  dofade()
 end
end

function wait(_wait)
 repeat
  _wait-=1
  flip()
 until _wait<0
end

function fadeout(spd,_wait)
 if (spd==nil) spd=0.04
 if (_wait==nil) _wait=0
 repeat
  fadeperc=min(fadeperc+spd,1)
  dofade()
  flip()
 until fadeperc==1
 wait(_wait)
end

function oprint8(_t,_x,_y,_c,_c2)
 for i=1,8 do
  print(_t,_x+dirs[i][1],_y+dirs[i][2],_c2)
 end
 print(_t,_x,_y,_c)
end

function shuffle(a)
	local n = count(a)
	for i=1,n do
		local k = -flr(-rnd(n))
		a[i],a[k] = a[k],a[i]
	end
	return a
end

function hcenter(s)
	return (screen / 2)-flr((#s*4)/2)
end

function vcenter(s)
	return (screen /2)-flr(5/2)
end

function adjacent(point)
	local x, y = point[1], point[2]

	local adj = {}
	local v = {{x-1,y},{x,y-1},{x+1,y},{x,y+1}}
	for i in all(v) do
		if inmap(i[1],i[2]) then
			add(adj,{i[1],i[2],mget(i[1],i[2])})
		end
	end
	return adj
end

function astar(start, goal, cost)
	-- printh("astar " .. start[1] .. "," .. start[2] .. " -> " .. goal[1] .. "," .. goal[2] ,"debug.txt")
 if vec(start)==vec(goal) then
  return {start}
 end

 local frontier = {}
	insert(frontier, start, 0)
	local came_from = {}
	came_from[vec(start)] = nil
	local cost_so_far = {}
	cost_so_far[vec(start)] = 0

	while (#frontier > 0 and #frontier < 1000) do
		local popped = pop(frontier)
		local current = popped[1]

	 	if vec(current) == vec(goal) then
	 		break
	 	end

	 	local neighbours = adjacent(current)
	 	for next in all(neighbours) do

	  	local nextindex = vec(next)

		  local new_cost = cost_so_far[vec(current)] + cost(current, next)

		  if (cost_so_far[nextindex] == nil) or (new_cost < cost_so_far[nextindex]) then
				cost_so_far[nextindex] = new_cost
				local priority = new_cost + heuristic(goal, next)
				insert(frontier, next, priority)

				came_from[nextindex] = current
		  end

	  end
	end
 -- printh("building path" ,"debug.txt")
	current = came_from[vec(goal)]
	path = {}
	local cindex = vec(current)
	local sindex = vec(start)

	add(path, goal)

	while cindex != sindex do
	 add(path, current)
	 current = came_from[cindex]
	 cindex = vec(current)
	end
	add(path, start)
	reverse(path)
 -- printh("path " .. #path ,"debug.txt")

	return path
end

function reverse(t)
	for i=1,(#t/2) do
		local temp = t[i]
		local oppindex = #t-(i-1)
		t[i] = t[oppindex]
		t[oppindex] = temp
	end
end

function prefer_walkable(a, b)
	if walkable(b[1],b[2]) then
		return 1
	elseif mget(b[1],b[2]) == 81 then
		return 2
	end
	return rand(2,4)
end

function heuristic(a, b)
	return distance(a[1], a[2], b[1], b[2])
end

function vec(point)
	return flr(point[2])*256+flr(point[1])%256
end

function vec2xy(v)
	local y = flr(v/256)
	local x = v-flr(y*256)
	return {x,y}
end

function floodfill(x,y,comp,action)
	local queue = {vec(x,y)}
	local seen = {}
	while #queue > 0 do
		local v = pop(queue)
		local x,y = vec2xy(v)
		if not (x <= 0 or x >= size or y <= 0 or y >= size) then
			push(seen,v)
			if action(x,y) == true then break end
			for adj in all(adjacent(x,y)) do
				local ax,ay = adj[1],adj[2]
				local av = vec(ax,ay)
				if not inlist(seen,av) and comp(ax,ay) then
					push(queue,av)
				end
			end
		end
	end
end

function assert(a,text)
	if not a then
		error(text or "assertion failed")
	end
end

function error(text)
	cls()
	print(text)
	_update = function() end
	_draw = function() end
end


__gfx__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000050000000000000000000000000
000000000000000000000000007000700070000000000070000000000000000000000000000000000000ddd00000000000000505000000000000000000000000
0070070000000000000000000000000000000070007000000000000000000000000000000000000000000d000000000000000050000000000000000000000000
000770000000000000000000000070000000700000000700000000000000000000000000000000000000000000bb000000000505000000000000000000000000
000770000000000000000000007000000070000000000000000000000000000000000000000000000000000000bb0bb000000050000000000000000000000000
0070070000000000000000000000700000000700007070000000000000000000000000000000000000000000bb0b0bb000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bb0b00b000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b0b00b000000000000000000000000000000000
07700000077000000770000070000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770000007700700077007077000770007070007000007000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777070077770700777707007777700077777007700077000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770070007700700077007000777000770707700777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770070007700700077777000070000700700700077700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777770007777700077007000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770070077700700777007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00707070007070000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000077000000770000000777000000000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770000007700000077000007077700007770000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777000077770000777700007770700070777000707070000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770070007707700077077077777770077707007777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770070007707700077077000000000777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007777000077777000777000007770000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000
07770000077700000777000007777700077777000777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00707000007070000070700000707000007070000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000
07700000077000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00770000007700000077000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000000000000000000000
07777000077770000777700000000000000000000007700000007000000700000007700000000000000000000000000000000000000000000000000000000000
00770000007700000077000000077000000000000007070000077000000770000007700000000000000000000000000000000000000000000000000000000000
00770070007707000077000000700700007777000070070000777700007777000077770000000000000000000000000000000000000000000000000000000000
00777700007777000077777007777770777777700077770000777700007777000077770000000000000000000000000000000000000000000000000000000000
07770000077700000777000000000000000000000000000000077000000770000007700000000000000000000000000000000000000000000000000000000000
00707000007070000070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
666606605555555000000000333000007777077000000000c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000303033307777077055550050c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
666066000000000000000000003030300000077055500550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000303000307707077055505500c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
660666600000000000000000303030307700000055500050c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000100000010000303030307707777055000550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
666066600000000000000000303330307707777055555550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000055555550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
663303600000000000000000000000000000000000000000c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
003033000000000000008000000000000000000000505550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
633633000000000000808800000011100000000050505550c00c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
003030000000500000888800000011100000000050050550cc0c0cc0000000000000000000000000000000000000000000000000000000000000000000000000
663366600005000000888000000000000555555055005550ccccccc0000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000000008888001110001155555550550555500ccc0c00000000000000000000000000000000000000000000000000000000000000000000000000
66630660000000000888888011100011555555505550555000c00000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000555555505555555000000000000000000000000000000000000000000000000000000000000000000000000000000000
63030660dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03330000dd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60336600dd0dd0000000770000000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00033000dd0dd0000007770000077000007777000007000000007000000700000000000000000000000000000000000000000000000000000000000000000000
66336660dd0dd0d00007700000077000007777000077700000070000000070000000000000000000000000000000000000000000000000000000000000000000
00033000dd0dd0d00000000000000000000770000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66603360dd0dd0d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66660770110001104400044033000330cc000cc066000660880008805500055077000770dd000dd0ee000ee00000000000000000000000000000000000000000
66660770100000104000004030300030c00000c060060060800000805000005070000070d00000d0e00000e00000000000000000000000000000000000000000
0000000000000000000440000003000000cc000000606000000800000005000000070000000d000000e0e0000000000000000000000000000000000000000000
660666600000000004044000030003000c0c0c000000060000880000000000000070700000d0d0000eeeee000000000000000000000000000000000000000000
66066660000000000040000000303000000cc0000000600000888000005050000007000000dd000000eee0000000000000000000000000000000000000000000
00000000100000104000004030000030c00000c060060060800000805005005070000070d00000d0e00e00e00000000000000000000000000000000000000000
66660770110001104400044033000330cc000cc066000660880008805500055077000770dd000dd0ee000ee00000000000000000000000000000000000000000
66660770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000808000000000000000000000802040008080000000000000000000008000000000000000000800000000000080000102030405060708090000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5151515151515151515151515151515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151445151515144444444515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515144404444464450604040515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151726040564071717740515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151717171747171717150515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151517171717173717140515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151517371757171787940515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151514444447144444450515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151447144515151515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151447144515151515151515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151444444444444447144444444444444515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151445040405040447140604040504044515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151447178737171727171727375787144515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151447172717372717578717171737144515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151444444444440717171714044444444515151515151515151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000050717971614000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000040444444445000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
