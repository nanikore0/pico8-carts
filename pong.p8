pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- todo:
-- ------------
-- add ult bullet
--

function _init()
	startscreen()
	p1_score=0
	p2_score=0
end

function _update60()
	if mode=="start" then
		update_start()
	elseif mode=="game" then
		update_game()
	end
end

function _draw()
	if mode=="start" then
		draw_start()
	elseif mode=="game" then
		draw_game()
	end
end

function startscreen()
 mode="start"
end

function startgame()
	-- game properties
	debug=true
	
	-- screen properties
	ytop=7
	ybot=120
	
	-- ball
	ball_size=4
	ball_xadd=0.05 --speed increase
	ball_yadd=0.03 --after hit
	ball_xmax=5 -- maximun x speed
	ball_ymax=5 -- maximun y speed
	
	ball={}
	ball.x=64-(ball_size/2)
	ball.y=64-(ball_size/2)
	ball.colw=ball_size
	ball.colh=ball_size
	ball.xspd=1
	ball.yspd=0.5
	-- complicated function below
	-- will choose between -1 or 1
	ball.xd=(-1*flr(rnd(2))*2)+1 -- x direction
	ball.yd=(-1*flr(rnd(2))*2)+1 -- y direction
		
	-- player properties
	spd=2
	height=24
	width=4
	
	-- player 1
	p1={}
	p1.x=128-width
	p1.y=64-(height/2)
	p1.colw=width
	p1.colh=height
	p1.sy=0
	p1.sym=0.25 --smooth slow
	
	-- player 2
	p2={}
	p2.x=0
	p2.y=64-(height/2)
	p2.colw=width
	p2.colh=height
	p2.sy=0
	p2.sym=0.25
end
-->8
-- tools

function update_debug()
	--[[
	-- ball movement
	if btn(⬅️) then ball.x-=1 end
	if btn(➡️) then ball.x+=1 end
	]]--
end

function draw_debug()
	--print(ball.x,1,1,7)
	--print(p1.sy,1,1,7)
end

function col(a,b)
	-- collision system from shmup
	-- tutorial by lazy devs
	
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

function cprint(txt,x,y,c)
	print(txt,x-#txt*2,y,c)
end

function col_ball(player)
	if player==1 then
		-- player 1 after hit
		ball.xd=-1
		ball.x=p1.x-width
		-- directional hit
		if p1.sy<0 then
			ball.yd=-1
		elseif p1.sy>0 then
			ball.yd=1
		end
	else
		-- player 2 after hit
		ball.xd=1
		ball.x=p2.x+width
		-- directional hit
		if p2.sy<0 then
			ball.yd=-1
		elseif p2.sy>0 then
			ball.yd=1
		end
	end
	
	-- speed increase
	ball.xspd+=ball_xadd
	ball.yspd+=ball_yadd
	if ball.xspd>=ball_xmax then
		ball.xspd=ball_xmax
	end
	if ball.yspd>=ball_ymax then
		ball.yspd=ball_ymax
	end
end
-->8
-- updating

function update_game()
	-- updating player 1 movement
	if p1.sy>0 then p1.sy-=p1.sym end
	if p1.sy<0 then p1.sy+=p1.sym end
	if btn(⬆️) then p1.sy=spd*-1 end
	if btn(⬇️) then p1.sy=spd end
	p1.y+=p1.sy
	
	-- updating player 2 movement
	if p2.sy>0 then p2.sy-=p2.sym end
	if p2.sy<0 then p2.sy+=p2.sym end
	if btn(⬆️,1) then p2.sy=spd*-1 end
	if btn(⬇️,1) then p2.sy=spd end
	p2.y+=p2.sy
	
	-- player x screen collision
	if p1.y<ytop+1 then
		p1.y=ytop+1
	end
	if p2.y<ytop+1 then
		p2.y=ytop+1
	end
	if p1.y>ybot-height then
		p1.y=ybot-height
	end
	if p2.y>ybot-height then
		p2.y=ybot-height
	end
	
	-- updating ball position
	ball.x+=ball.xspd*ball.xd
	ball.y+=ball.yspd*ball.yd
	
	-- collision player x ball
	if col(p1,ball) then
		col_ball(1)
	elseif ball.x+ball_size>128 then
		startgame()
		p2_score+=1
	end
	if col(p2,ball) then
		col_ball(2)
	elseif ball.x<0 then
		startgame()
		p1_score+=1
	end
	
	-- collision ball x screen
	if ball.y+ball_size>ybot then
		ball.yd=-1
		ball.y=ybot-ball_size
	end
	if ball.y<ytop+2 then
		ball.yd=1
		ball.y=ytop+2
	end
	
	-- debugging
	if debug then
		update_debug()
	end

end

function update_start()
	if btnp(❎) or btnp(🅾️) then
		startgame()
		mode="game"
	end
end
-->8
-- drawing

function draw_game()
	cls()
	
	-- drawing game outline
	line(0,ytop,128,ytop,7)
	line(0,ybot,128,ybot,7)
	
	-- drawing players
	rectfill(p1.x,p1.y,p1.x+width-1,p1.y+height-1,7)
	rectfill(p2.x,p2.y,p2.x+width-1,p2.y+height-1,7)
	
	-- drawing ball
	rectfill(ball.x,ball.y,ball.x+ball.colw-1,ball.y+ball.colh-1,7)
	
	-- drawing score
	cprint(p2_score..":"..p1_score,64,1,7)
	
	-- debugging
	if debug then
		draw_debug()
	end
	
end

function draw_start()
	cls()
	cprint("press button to start",64,80,7)
	cprint("player 1: ⬆️ and ⬇️",64-4,116,7)
	cprint("player 2: e and d",64,122,7)
end
__gfx__
00000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
