pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- not flappy bird
-- by nanikore

function _init()
	poke(0x5f2d, 1)
	parts={}
	shake=0
	clkp=false
	clkr=true
	bird={}
	bird.spr=1
	highscore=0
	startscreen()
	t=0
	lockout=0
end

function _update()

	t+=1
	
	doshake()

	if mode=="start" then
		update_start()
	elseif mode=="game" then
		update_game()
	elseif mode=="over" then
 	update_over()
 elseif mode=="bsod" then
 	update_bsod()
	end
	
end

function _draw()

	if mode=="start" then
		draw_start()
	elseif mode=="game" then
		draw_game()
		if debug==true then
		draw_debug()
		end
	elseif mode=="over" then
  draw_over()
 elseif mode=="bsod" then
 	draw_bsod()
	end
	
end

function startscreen()
	flap_spd=4
	y_flap=0
	gravity=0.5
	
	pipe_spd=2

	bird.x=32
	bird.y=40
	bird.colw=2
	bird.colh=2
	
	bird_flap={}
	flap_timer=0
	
	blink_add=0
	blink_timer=0

	mapx_top=0
	mapspeed_top=0.8
	mapx_bottom=0
	mapspeed_bottom=1
 mode="start"
 
end

function startgame()
	t=0

	score=0

	next_pipe=60
	spawn_interval=60
	min_interval=30
	level=0
	
	alive=true
	
	pipes={}
	pipes_top={}
	pipes_bottom={}
	
	diff_increase=false
	
	bsod=30
	bsod_timer=0
	rect_width=1
	can_restart=false
	
	-- dev tools
	invul=false
	debug=false
	free_mov=false
	
end
-->8
-- tools
function draw_debug()
	print("y="..bird.y,7)
	--print("y_flap="..y_flap)
	--print("pipes="..#pipes)
	--print("time="..flr(t/30))
	--print("level="..level)
	--print("bird_flap="..#bird_flap)
	print("t="..t)
	print("next_pipe="..next_pipe)
	--print("interval="..spawn_interval)
	--print("bsod="..bsod)
	--print("pipe_spd="..pipe_spd)
	--[[
	for mypipe in all(pipes) do
		if col(bird,mypipe) or
			col(bird,mypipe.top) or col(bird,mypipe.bottom) then
				print("colliding")
		else
			print("no collision")
		end
	end
	]]--
	
end

function movement_debug()
	-- free bird movement
	local bird_spd=1
	if btn(⬆️) then bird.y-=bird_spd end
	if btn(⬇️) then bird.y+=bird_spd end
	if btn(⬅️) then bird.x-=bird_spd end
	if btn(➡️) then bird.x+=bird_spd end
	
	-- pipe freezing
	if btnp(❎) then freeze=false end
	if btnp(🅾️) then freeze=true end
	
	for mypipe in all(pipes) do
		if not freeze then
			pipe_movement(mypipe)
		else
			t-=1
		end
	end
end

function pipe_movement(pipe)
	local mypipe=pipe
	
	mypipe.x-=pipe_spd
	mypipe.top.x-=pipe_spd
	mypipe.bottom.x-=pipe_spd
	
end

function spawn_pipe()
	local newpipe={}
	newpipe.x=132
 newpipe.y=flr(rnd(80))+8
 newpipe.colw=16
 newpipe.colh=32
 newpipe.collide=false
 newpipe.pass=false
 
 newpipe.top={}
 newpipe.top.x=newpipe.x-4
 newpipe.top.y=newpipe.y-128
 newpipe.top.colw=24
 newpipe.top.colh=128
 
 newpipe.bottom={}
 newpipe.bottom.x=newpipe.x-4
 newpipe.bottom.y=newpipe.y+32
 newpipe.bottom.colw=24
 newpipe.bottom.colh=128
 
 add(pipes,newpipe)
end

function col(a,b)
 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1

 if a_top>b_bottom then return false end
 if b_top>a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
 return true
end

-- print text with outline
function outline(text,x,y,bold,col1,col2)
	if col2==nil then col2=0 end
	if col1==nil then col1=7 end
	
	print(text,x-1,y,col2)
	print(text,x+1,y,col2)
	print(text,x,y-1,col2)
	print(text,x,y+1,col2)
	
	if bold then
		print(text,x-1,y-1,col2)
		print(text,x+1,y+1,col2)
		print(text,x-1,y+1,col2)
		print(text,x+1,y-1,col2)
	end
	
	print(text,x,y,col1)
end

function sproutline(spr_id,x,y,bold,flap)
	if flap then
		for i=0,15 do
			pal(i,12)
		end
	else
		for i=0,15 do
			pal(i,0)
		end
	end
	
	spr(spr_id,x-1,y)
	spr(spr_id,x+1,y)
	spr(spr_id,x,y-1)
	spr(spr_id,x,y+1)
	
	if bold then
		spr(spr_id,x-1,y-1)
		spr(spr_id,x+1,y+1)
		spr(spr_id,x-1,y+1)
		spr(spr_id,x+1,y-1)
	end
	
	pal()
	palt(0,false)
	palt(14,true)
	spr(spr_id,x,y)
end

function game_over()
	if score>highscore then
		highscore=score
	end
	explode(bird.x-3,bird.y-3)
	mapspeed_top=0.08
	mapspeed_bottom=0.1
	mode="over"
	alive=false
	sfx(1)
	lockout=t+30
	shake=10
end

function draw_background()
	mapx_top+=1*mapspeed_top
	mapx_bottom+=1*mapspeed_bottom
	for i=0,1 do
		map(0,0,i*128-mapx_top%128,0,16,16)
		map(16,0,i*128-mapx_bottom%128,0,16,16)
	end
end

function flap()
	-- update position
	y_flap=flap_spd
	bird.y-=y_flap
	
	-- animate flap
	anim_flap(bird.x,bird.y,7)
	flap_timer=6
end

function bird_gravity()
	y_flap-=gravity
	bird.y-=y_flap
end

function draw_bird()
	palt(0,false)
	palt(14,true)
	
	-- falling
	if y_flap<=-4 then
		spr(bird.spr+5,bird.x-3,bird.y-3)
		return
	end
	if y_flap<=-2 then
		spr(bird.spr+4,bird.x-3,bird.y-3)
		return
	end
	
	-- blinking
	if y_flap>=0 then
		sproutline(bird.spr,bird.x-3,bird.y-3,false,true)
		return
	else
		sproutline(bird.spr+blink_add,bird.x-3,bird.y-3,false,true)
		return
	end
	pal()
	
end

function touchscreen()
	if stat(34)==1 and clkr==true then
		clkp=true
		clkr=false
	end
	if stat(34)==0 then
		clkr=true
	end
	if clkp then
		clkp=false
		return true
	end
end

function anim_flap(x,y,flap_spr)
	local newflap={}
	newflap.x=x-3
 newflap.y=y-3
 if flap_spr==nil then
 	flap_spr=23
 end
 newflap.spr=flap_spr
 
 add(bird_flap,newflap)
end

function flap_animation()
	local anim_spd=0.25
	
	for myflap in all(bird_flap) do
		palt(14,true)
		sproutline(myflap.spr,myflap.x,myflap.y,false,true)
		if mode!="over" then
			myflap.x-=pipe_spd
		end
		myflap.spr+=anim_spd
		if myflap.spr==11 then
			del(bird_flap,myflap)
		end
		if myflap.spr==27 then
			del(bird_flap,myflap)
		end
	end
	
end

function draw_blinking()
	local blink=flr(rnd(300))
	if blink==1 then
		blink_timer=10
		blink_add=2
	end
	blink_timer-=1
	if blink_timer<=0 then
		blink_timer=0
		blink_add=0
	end
end

function doshake()

 local shakex=rnd(shake)-(shake/2)
 local shakey=rnd(shake)-(shake/2)
 
 camera(shakex,shakey)
 
 if shake>10 then
  shake*=0.9
 else
  shake-=1
  if shake<1 then
   shake=0
  end
 end
end

function explode(expx,expy)
 
 local myp={}
 myp.x=expx
 myp.y=expy
 
 myp.sx=0
 myp.sy=0
 
 myp.age=0
 myp.size=10
 myp.maxage=0
 
 add(parts,myp)
	
 for i=1,30 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=rnd()*6-3
	 myp.sy=rnd()*6-3
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 
	 add(parts,myp)
 end
 
 for i=1,20 do
	 local myp={}
	 myp.x=expx
	 myp.y=expy
	 
	 myp.sx=(rnd()-0.5)*10
	 myp.sy=(rnd()-0.5)*10
	 
	 myp.age=rnd(2)
	 myp.size=1+rnd(4)
	 myp.maxage=10+rnd(10)
	 myp.spark=true
	 
	 add(parts,myp)
 end
 
end

function page(page)
 local col=7
 
 if page>5 then
  col=7
 end
 if page>10 then
  col=15
 end
 if page>15 then
  col=6
 end
 
 return col
end

-->8
-- updating

function update_game()

	-- player flap
	if not free_mov then
		if btnp(🅾️) or btnp(❎) or btnp(⬆️) or touchscreen() then
			flap()
			sfx(2)
		end
		bird_gravity()
	else
		movement_debug()
	end
	
	-- update flap animation
	flap_timer-=1
	if flap_timer>=0 then
		if flap_timer%3==0 then
			anim_flap(bird.x,bird.y)
		end
	end
	
	-- screen collision
	if bird.y>132 then
		game_over()
		--bird.y=132
	end
	if bird.y<-6 then
		game_over()
		--bird.y=-6
	end
	
	-- pipe spawning
	if t>=next_pipe then
		spawn_pipe()
		next_pipe=t+spawn_interval
	end
	
	-- pipe movement
	if not free_mov then
		for mypipe in all(pipes) do
			pipe_movement(mypipe)
		end
	end
	
	-- pipe despawning
	for mypipe in all(pipes) do
		if mypipe.x<-24 then
			del(pipes,mypipe)
		end
	end
	
	-- collision bird x pipes
	if not invul then
		for mypipe in all(pipes) do
			if col(bird,mypipe.top) or
			 col(bird,mypipe.bottom) then
			 	game_over()
			end
		end
	end
	
	-- scoring
	if alive==true then
		for mypipe in all(pipes) do
			if col(bird,mypipe) then
				mypipe.collide=true
			end
		end
		for mypipe in all(pipes) do
			if not(col(bird,mypipe)) and mypipe.collide==true and mypipe.pass==false then
				mypipe.pass=true
				score+=1
				diff_increase=true
				if score%10==0 then
					sfx(4)
				else
					sfx(3)
				end
			end
		end
	end
	
	-- difficulty increase
	if diff_increase then
		spawn_interval-=0.3
		diff_increase=false
	end
	if spawn_interval<=min_interval then
		spawn_interval=min_interval
	end
	
	-- lol
	if #pipes>=10 then
		bsod-=1
	end
	if bsod<=0 then
		mode="bsod"
	end
	
end

function update_start()
	
	-- skin selection
	if btnp(⬅️) then
		bird.spr-=16
	end
	if btnp(➡️) then
		bird.spr+=16
	end
	if bird.spr<=0 then
		bird.spr=1
	end
	if bird.spr>=55 then
		bird.spr=49
	end
	
	-- auto flap
	if bird.y>70 then
		flap()
	end
	bird_gravity()
	
	-- update flap animation
	flap_timer-=1
	if flap_timer>=0 then
		if flap_timer%3==0 then
			anim_flap(bird.x,bird.y)
		end
	end

	if btn(🅾️)==false and btn(❎)==false then
  btnreleased=true
 end

 if btnreleased then
  if btnp(🅾️) or btnp(❎) or btnp(⬆️) or touchscreen() then
  	mode="game"
   startgame()
   btnreleased=false
   flap()
   sfx(2)
  end
 end
end

function update_over()
	if t<lockout then
  return
 end
 
 if btn(🅾️)==false and btn(❎)==false then
  btnreleased=true
 end

 if btnreleased then
  if btnp(🅾️) or btnp(❎) or btnp(⬆️) or touchscreen() then
   startscreen()
   btnreleased=false
  end
 end
end

function update_bsod()
	if score>highscore then
		highscore=score
	end
	
	bsod_timer+=1
	
	rect_width+=1
	if rect_width>126 then
		rect_width-=1
		can_restart=true
	end
	
	if can_restart then
	 if btnp(🅾️) or btnp(❎) or btnp(⬆️) or touchscreen() then
	  startscreen()
	 end
	end
 
end

-->8
-- drawing
function draw_game()

	cls(0)
	
	-- scrolling background
	draw_background()
	
	-- drawing pipes
	for mypipe in all(pipes) do
		for i=1,6 do
			spr(43,mypipe.x,mypipe.y-16*i,2,2)
			spr(43,mypipe.x,mypipe.y+16*i+16,2,2)
		end
		spr(11,mypipe.x,mypipe.y+48,2,2)
		
		spr(45,mypipe.x-4,mypipe.y-16,3,2)
		spr(45,mypipe.x-4,mypipe.y+32,3,2)
	end
	
	-- bird blinking
	draw_blinking()
	
	--drawing particles
 for myp in all(parts) do
  local pc=7

  pc=page(myp.age)
  
  if myp.spark then
   pset(myp.x,myp.y,7)
  else
   circfill(myp.x,myp.y,myp.size,pc)
  end
  
  myp.x+=myp.sx
  myp.y+=myp.sy
  
  myp.sx=myp.sx*0.85
  myp.sy=myp.sy*0.85
  
  myp.age+=1
  
  if myp.age>myp.maxage then
   myp.size-=0.5
   if myp.size<0 then
    del(parts,myp)
   end
  end
 end
	
	-- flap animation
	flap_animation()
	
	-- drawing bird
	if alive then
		draw_bird()
	end
	pal()
	
	-- drawing score
	print("highscore:"..highscore,7)
	print("score:"..score,7)
	
end

function draw_start()
	cls(0)
	
	draw_background()
	
	flap_animation()
	
	draw_blinking()
	
	draw_bird()
	
	if btn(⬅️) then
		sproutline(14,47,119,true)
	else
		sproutline(13,47,119,true)
	end
	if btn(➡️) then
		sproutline(30,66,119,true)
	else
		sproutline(29,66,119,true)
	end
	palt(0,false)
	palt(14,true)
	spr(bird.spr,56,119)
	
	outline("not flappy bird",33,20,true)
	outline("press button to start",22,100,true)
end

function draw_over()
	draw_game()
	if debug==true then
		draw_debug()
	end
	outline("game over",47,40,true,8,2)
	outline("press button to continue",17,80,true)
end

function draw_bsod()
	cls(1)
	
	if bsod_timer>=1 then
		print("flappy os",45,1,7) end
	if bsod_timer>=2 then
		print("a problem has been detected and",1,7) end
	if bsod_timer>=3 then
		print("flappy os needs to restart to",7) end
	if bsod_timer>=4 then
		print("continue playing",7) end
	if bsod_timer>=5 then
		print("error_score_too_high",1,30,7) end
	if bsod_timer>=6 then
		print("if this is the first time you've",1,40,7) end
	if bsod_timer>=7 then
		print("seen this error screen and wish",7) end
	if bsod_timer>=8 then
		print("to continue playing, press any",7) end
	if bsod_timer>=9 then
		print("button",7) end
	if bsod_timer>=10 then
		print("score="..score,1,70,7) end
	if bsod_timer>=11 then
		print("*** stop = 0x0001 0x0002 0x0003",1,80,7) end
	if bsod_timer>=12 then
		print("*** rebooting...",1,90,7)	end
	
	if bsod_timer>=13 then
		rectfill(1,96,rect_width,100,7)
	end
	
	if can_restart then
		print("press ❎ or 🅾️",34,105,7)
		print("to continue",40,111,7)
	end
	
end

__gfx__
00000000e2ee222eeeee222ee2ee222eeeee222e22eeeeeee2eeeeeee7ee777eeeee7e7eeeeeeeeeeeeeeeee1333333333333331eeeeeeeeeeeeeeee00000000
00000000242244422222444224224442222244422422222e2422eeee77777777e7e7e7e7e7e7e7e7eeeeeeee1333333333333331e77777eeeeeeeeee00000000
0070070024444049244440492444444924444449244444422444222e777777777e7e7e7eeeeeeeeeeeeeeeee1333333333333b357770077eecccccee00000000
000770001ff44442144444421ff44442144444421ff440421ff4444277777777e7e7e7e7e7e7e7e7eeeeeeee133b3333333bbb357700077eccc00cce00000000
000770001ffff41e1f44441e1ffff41e1f44441e1ffff4491ff440427777777e7e7e7e7eeeeeeeeeeeeeeeee133b3bbb777bbb357770077ecc000cce00000000
00700700e1fff1eee1f441eee1fff1eee1f441eee1fff11e1fff4049e77777eee7e7e7eee7e7e7eeeeeeeeee133b3bbb777bbb356777776eccc00cce00000000
00000000ee111eeeee141eeeee111eeeee141eeeee111eeee1ff441eee777eeeee7e7eeeeeeeeeeeeeeeeeee133b3bbb777bbb35e66666eeecccccee00000000
00000000eeeeeeeeeee1eeeeeeeeeeeeeee1eeeeeeeeeeeeee1111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee133b3bbb777bbb35eeeeeeeeeeeeeeee00000000
00000000e2ee222eeeee222ee2ee222eeeee222e22eeeeeee2eeeeeeeeee777eeeee7e7eeeeeeeeeeeeeeeee133b3bbb777bbb35eeeeeeeeeeeeeeee00000000
00000000282288822222888228228882222288822822222e2822eeee77777777e7e7e7e7e7e7e7e7eeeeeeee133b3bbb777bbb35e77777eeeeeeeeee00000000
0000000028888089288880892888888928888889288888822888222e777777777e7e7e7eeeeeeeeeeeeeeeee133b3bbb777bbb357700777eecccccee00000000
000000001ff88882188888821ff88882188888821ff880821ff8888277777777e7e7e7e7e7e7e7e7eeeeeeee133b3bbb777bbb357700077ecc00ccce00000000
000000001ffff81e1f88881e1ffff81e1f88881e1ffff8891ff880827777777e7e7e7e7eeeeeeeeeeeeeeeee133b3bbb777bbb357700777ecc000cce00000000
00000000e1fff1eee1f881eee1fff1eee1f881eee1fff11e1fff8089e77777eee7e7e7eee7e7e7eeeeeeeeee133b3bbb777bbb356777776ecc00ccce00000000
00000000ee111eeeee181eeeee111eeeee181eeeee111eeee1ff881eee777eeeee7e7eeeeeeeeeeeeeeeeeee133b3bbb777bbb35e66666eeecccccee00000000
00000000eeeeeeeeeee1eeeeeeeeeeeeeee1eeeeeeeeeeeeee1111eeeee7eeeeeee7eeeeeee7eeeeeeeeeeee133b3bbb777bbb35eeeeeeeeeeeeeeee00000000
00000000e3ee333eeeee333ee3ee333eeeee333e33eeeeeee3eeeeee00000000000000000000000000000000133b3bbb777bbb35055555555555555555555550
000000003b33ccc33333ccc33b33ccc33333ccc33b33333e3b33eeee00000000000000000000000000000000133b3bbb777bbb35113333bbbbbbb7777bbb3355
000000003bbcc0c93bccc0c93bbcccc93bccccc93bbcccc33bbc333e00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
000000001ffbbcc31bccccc31ffbbcc31bccccc31ffbb0c31ffbccc300000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
000000001ffffb1e1fbccc1e1ffffb1e1fbccc1e1ffffcc91ffbc0c300000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000e1fff1eee1fbc1eee1fff1eee1fbc1eee1fff11e1fffb0c900000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000ee111eeeee1b1eeeee111eeeee1b1eeeee111eeee1ffcc1e00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000eeeeeeeeeee1eeeeeeeeeeeeeee1eeeeeeeeeeeeee1111ee00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000edeedddeeeeedddeedeedddeeeeedddeddeeeeeeedeeeeee00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000daddaaadddddaaaddaddaaadddddaaaddadddddedaddeeee00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000daaaa0a9daaaa0a9daaaaaa9daaaaaa9daaaaaaddaaaddde00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000177aaaad1aaaaaad177aaaad1aaaaaad177aa0ad177aaaad00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
0000000017777a1e17aaaa1e17777a1e17aaaa1e17777aa9177aa0ad00000000000000000000000000000000133b3bbb777bbb351333b3bbbbbbb7777bbbb335
00000000e17771eee17aa1eee17771eee17aa1eee177711e1777a0a900000000000000000000000000000000133b3bbb777bbb35133333bbbbbbb7777bbb3335
00000000ee111eeeee1a1eeeee111eeeee1a1eeeee111eeee177aa1e00000000000000000000000000000000133b3bbb777bbb35113333333333333333333311
00000000eeeeeeeeeee1eeeeeeeeeeeeeee1eeeeeeeeeeeeee1111ee00000000000000000000000000000000133b3bbb777bbb35011111111111111111111110
1111111111111111111111111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111ccc11111111111c11111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111c1111111c111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111c11111ccc111111111111111111111
1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ccccc11111111111111111111
11111111111111111111111111111111ccc1111111111111111111111111111111111111111111c111111111111cccccc111111ccccc11111111111111111111
11111111111111111111111cccc111ccccccc1111111111111111111111111111111111111111ccc1111111111ccccccccc1111ccccc111c1111111111111111
111111111111111cc11111cccccc1cccccccc1c111111111111111111111111111111111111111c1111111c1cccccccccccc1111ccc111111111111111111111
11111111111111cccc111ccccccccccccccccc11111111c1111111111111111111111111111111111111111cccccccccccccc111111111111111111111111111
11c11111111111cccc11ccccccccccccccccccccc11111111111111111111111111111111111111ccccc11ccccccccccccccc1111111cccc1111111111c11111
111111111111111cc111cccccccccccccccccccccc11111111111111111ccc1111111111111111ccccccc111ccccccccccccc11c1ccccccccc1111111ccc1111
11111111111111111111ccccccccccccccccccccccc111111c11111111ccccc1111111111111cccccccccccc1ccccccccccccc11ccccccccccc1111111c11111
11111111111111111111ccccccccccccccccccccccc11111ccc111111ccccccc11111111111cccccccccccccccccccccccccccc11ccccccccccc11c111111111
1111111c111111cccc111cccccccccc111ccccccccc111111c1111111ccccccc11111111111ccccccccccccccc1cccccccccccccc1ccccccccccc11111111111
111111111111cccccccc11ccccccc11ccccccccccccc1111111111111ccccccc111111c111ccccccccccccccccc1cccccccccccccccccccccccccc1111111111
111111111111cccccccccc1ccccc1cccccccccccccccc1111111111111ccccc11111111111cccccccccccccccccccccccccccccccccccccccccccc1111111111
11111111111cccccccccccc1ccccccccccccccccccccc1c111111111111ccc111111111111ccccccccccc111cccccccccccccccccccccccccccccc1111111111
11111111111ccccccccccccccccccccccccccccccccccc1111111111111111111111111111ccccccccc11cccccccccccccccccccccccccccccccccc111111111
11111ccc111ccccccccccccccccccccccccccccccccc11cccc111111111111111111cccc111ccccccc1cccccccccccccccccccccccccccccccccc11ccccc1111
1111ccccc11ccccccccc1cccccccccccccccccccccc1ccccccc1111111111111c1cccccccc1cccccc1cccccccccccccccccccccccccccccccccc1cccccccc111
1111ccccc111cccccc11cccccccccccccccccccccccccccccccc1111111111111ccccccccc11cccccccccccccccccccccccccccccccccccccccccccccccccc11
1111ccccc111ccccc1ccccccccccccccccccccccccccccccccccc11111111111cccccccccccc1ccccccccccccccccccccccccccccccccccccccccccccccccc11
11111ccc1111ccccccccccccccccccccccccccccccccccccccccc111ccc11111cccccccccccc1ccccccccccccccccccccccccccccccccccccccccccccccccc11
11111111111ccccccccccccccccccccccccccccccccccccccccc11ccccccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11
1c11111c11cccccccccccccccccccccccccccccccccccccccc1ccccccccccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccc11ccccccc11
111ccc11ccccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccccccccccccccccccccccccccccccccccccccccccccccccccccc11cccc111
11ccccc11cccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccccccccccccccccccccccccccccccccccccccccccccccccccccccc1ccc1c1
1cccccccc1cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc11
1ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccc7ccccccccc7ccccccccccccccccccccccccccccccccccccccccccccc7cccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc777cccccccccccccccc7cccccccc7777cccccccccccccc777ccccccccccccccccccccc
ccccccccccccccc777ccccccccccc7ccccccccccccccccccccccccccccc7cccccccccccccccccccccccc77777777ccccccccccccc7cccccccccccccccc7ccccc
cccccccccccccc77777cccccccccccccccc7777ccccccccccccccccccccccccccccccccccccccccccccc77777777ccccccccccccccccccccccccccccc777cccc
cccccccccccccc77777ccccc7777ccccc7777777ccccccccccccccccccccccccccccccccccccccccc7c7777777777ccc7ccccccccccccccccccccccccc7ccccc
cccccccccccccc77777cccc7777777cc777777777cccccccccccccccccccccccccccccccccccc777cc77777777777cccccccccccccccccc7777ccccccccccccc
ccccccccccccccc777cccc777777777c7777777777cccccccccc7777cccccccccccccccccccc777777c777777777777ccc77777ccccccc777777cccccccccccc
ccccccccccccccccccccc777777777777777777777cc7cccccc777777cccccccccc7ccccccc777777777777777777777c7777777ccccc77777777ccccccccccc
cccccccccc7cccccccc7c777777777777777777777cccccccc77777777cccccccc777cccccc77777777777777777777c777777777cccc77777777ccccccccccc
cccccccccccccc7777cc7777777777777cc777777c7777cccc77777777ccccccccc7ccccccc77777777777777777777c7777777777ccc77777777cccccccccc7
ccccccccccccc7777777777777777777777cc7777777777ccc77777777cccccccccccccccc77777777777777777777777777777777ccc77777777ccccccccccc
cccccccccccc7777777777777777777777777c7777777777cc77777777cccccccccccc7777cc777777777777777777777777777777cccc777777cccccccccccc
cccccccccccc777777777777777777777777777777777777ccc777777ccc7cccccccc7777777c77777777777777777777777777777ccccc7777ccccccccccccc
cccccccccccc77777777cc77777777777777777777777777cccc7777cccccccccccc77777777777777777777777777ccc7777777777ccccccccccccccccccccc
cccccccccccc7777777c7777777777777777777777777777cccccccccccccccc777c77777777777777777777777777777cc777777777cccccccccccccccccccc
ccccccccccccc77777c7777777777777777777777777777cc77777cccccccc7777777777777777777777777777777777777c77777777c7cccccccccc7ccccccc
ccccccccccc7ccc7777777777777777777777777777777c777777777cccccc77777777777777777777777777777777777777777777777cc7777ccccccccccccc
c7cccccccccc777cc7777777777777777777777777777777777777777c7cc7777777777777cc77777777777777777777777777777777c77777777ccccccccccc
ccccc77cccc777777c7777777777777777777777777777777777777777ccc7777777777777777777777777777777777777777777777c777777777cccccc7cccc
cccc7777cc777777777777777777777777777777777777777777777777cc7777777777c777777777777777777777777777777777777c7777777777cccc777ccc
cccc7777cc7777777777777777777777777777777777777777777777777c777777777c777777777777777777777777777777777777777777777777ccccc7cccc
ccccc77ccc7777777777777777777777777777777777777777777777777c777777777c7777777777777777777777777777777777777777777777777ccccccccc
ccccccccccc7777777777777777777777777777777777777777777777777c7777777c77777777777777777777777777777777777777777777777777ccccccccc
cccccccccc777777777777777777777777777777777777777777777777777c777777c77777777777777777777777777777777777777777777777777ccccccccc
cccc7777c77777777777777777777777777777777777777777777777777777777777c7777777777777777777777777777777777777777777777777cc777ccccc
cc7777777cc7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777c7777777c7c
c7777777777c777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777cc
777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777cc
7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777c
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
__map__
4040404040404040404040404040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
404142434445464748494a4b4c4d4e4f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
505152535455565758595a5b5c5d5e5f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
606162636465666768696a6b6c6d6e6f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
707172737475767778797a7b7c7d7e7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000080808080808080808080808080808080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000808182838485868788898a8b8c8d8e8f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000909192939495969798999a9b9c9d9e9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000a0a1a2a3a4a5a6a7a8a9aaabacadaeaf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000b0b1b2b3b4b5b6b7b8b9babbbcbdbebf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
110100002b5513554135541335512e5512954127531225311b5211852113521115210f5110a511075110551105511035110351100511005110051100511005010050100501005010050100501005010050100501
0001000023021280312d0412f05100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001
000400001105018050130501f05018050240500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400001155018550135501f55018550245501d505295051153518535135351f535185352453500505005051150518525135051f525185052452500505005051150518515135051f51518505245150050500505
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
