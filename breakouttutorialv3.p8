--breakout tutorial--

       --goals--
-- 1. sticky paddle --
-- 2. angle control --
-- 3. levels --
-- 4. different  bricks --
-- 5. combos --
-- 6. more game feel (particles/screenshake) --
-- 7. high score tracking --
-- 8. power ups --
-- 9. roguelike powers --
-- eamonrequest. colour scheme changes through gameplay --


function _init()
 cls()
 mode="start"
end

function _update60()
 if mode=="game" then
  update_game()
 elseif mode=="start" then
  update_start()
 elseif mode=="gameover" then
  update_gameover()
 end
end

function update_start()
 if btn(❎) then
  startgame()
 end
end

function startgame()
 
 mode="game"
 
 --ball variables--
 
 ball_r=2
 ball_dr=.5
 
 --ball variables--
 
 --pad variables--
 
 pad_x=52
 pad_y=115
 pad_dx=0
 
 pad_w=24 
 pad_h=3
 pad_c=8
 
 --pad variables--
 
 --brick variables--
 
 brick_w=9
 brick_h=3
 
 buildbricks()
  
 --brick variables--
 
 lives=3
 points=0

 sticky=true

 serveball()

end

function buildbricks()
 local i
 brick_x={}
 brick_y={}
 brick_v={}
 
 for i=1,66 do
  add(brick_x,4+((i-1)%11)*(brick_w+2))
  add(brick_y,12+flr((i-1)/11)*(brick_h+2))
  add(brick_v,true) 
 end
end

function serveball()
 ball_x=pad_x+pad_w/2
 ball_y=pad_y-ball_r
 ball_dx=-1
 ball_dy=-1
 sticky=true
end

function gameover()
 mode="gameover"
end

function update_gameover()
  if btn(❎) then
  startgame()
 end
end

function update_game()
 local buttpress=false
 local nextx,nexty,brickhit
 
--pad movement--

 if btn(⬅️) then 
  buttpress=true
  pad_dx=-3
 --pad_x-=5
 end
 if btn(➡️) then 
  buttpress=true
  pad_dx=3
 --pad_x+=5
 end
 
 if not(buttpress) then
  pad_dx=pad_dx/1.3
 end

  pad_x+=pad_dx
  pad_x=mid(0,pad_x,127-pad_w)

--pad movement--

  if sticky then
   ball_x=pad_x+pad_w/2
   ball_y=pad_y-ball_r
  else

  --regular ball physics0--
  nextx=ball_x+ball_dx
  nexty=ball_y+ball_dy
  --regular ball physics0--

  --limit of canvas collision--

  if nextx > 124 or nextx < 3 then
   nextx=mid(0,nextx,127)
   ball_dx = -ball_dx
   sfx(2)
  end
  
  if nexty < 10 then
   nexty=mid(0,nexty,127)
   ball_dy = -ball_dy
   sfx(2)
  end
 
  --limit of canvas collision--

--collision - paddle --

 --check if ball hit pad--
  if ball_box(nextx,nexty,pad_x,pad_y,pad_w,pad_h) then
  --check if ball hit pad--

  --find which direction to deflect--
  if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,pad_x,pad_y,pad_w,pad_h) then
   ball_dx = -ball_dx
   if ball_x < pad_x+pad_w/2 then
    nextx=pad_x-ball_r
   else
    nextx=pad_x+pad_w+ball_r
   end
  else
   ball_dy = -ball_dy
   if ball_y > pad_y then
    nexty=pad_y+pad_h+ball_r
   else
    nexty=pad_y-ball_r
   end
  end
  --collision actions--
  sfx(3)
  points+=1 
  --collision actions--
  end  

 
--collision - paddle --
  brickhit=false
 --collision - brick --
  for i=1,#brick_x do
   --check if ball hit pad--
   if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
    --check if ball hit pad--
    --find which direction to deflect--
    if not (brickhi) then
     if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
      ball_dx = -ball_dx
     else
      ball_dy = -ball_dy
     end
    end
    --collision actions--
    brickhit=true
    sfx(7)
    brick_v[i]=false
    points+=10 
    --collision actions--
   end
  end 
--collision - brick --

  ball_x=nextx
  ball_y=nexty
 
  if nexty > 124 then
    sfx(6)
    lives-=1
   if lives<0 then
    sfx(5)
    gameover()
   else
    serveball()
   end
  end
 end
end

function _draw()
 if mode=="game" then
  draw_game()
 elseif mode=="start" then
  draw_start()
 elseif mode=="gameover" then
  draw_gameover()
 end
end

function draw_start()
 cls(1)
 rectfill(0,37,128,57,8)
 print("pico hero breakout",30,40,1)
 print("press ❎ to start",32,50,1)
end

function draw_gameover()
 rectfill(0,60,128,76,8)
 print("game over",45,62,1)
 print("press ❎ to restart",25,69,1)
end

function draw_game()
 local i

 cls(1)
 circfill(ball_x,ball_y,ball_r,8)
 rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
 
 --draw bricks--
 
 for i=1,#brick_x do
  if brick_v[i] then
   rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,8)
  end
 end

 --draw bricks--
 
 --draw pad--
 --draw pad--
  
 rectfill(0,0,128,6,8)
 print("lives:"..lives,4,1,1)
 print("score:"..points,37,1,1)
end

--ball collision with pad--
function ball_box(bx,by,box_x,box_y,box_w,box_h)
 if by-ball_r > box_y+box_h then
  return false
 end
 if by+ball_r < box_y then
  return false
 end 
 if bx-ball_r > box_x+box_w then
  return false
 end
 if bx+ball_r < box_x then
  return false
 end 
 return true
end
--ball collision with pad--

--tutorial written function beware--
function deflx_ball_box(bx,by,bdx,bdy,tx,ty,tw,th)
    local slp = bdy / bdx
    local cx, cy
    if bdx == 0 then
        return false
    elseif bdy == 0 then
        return true
    elseif slp > 0 and bdx > 0 then
        cx = tx - bx
        cy = ty - by
        return cx > 0 and cy/cx < slp
    elseif slp < 0 and bdx > 0 then
        cx = tx - bx
        cy = ty + th - by
        return cx > 0 and cy/cx >= slp
    elseif slp > 0 and bdx < 0 then
        cx = tx + tw - bx
        cy = ty + th - by
        return cx < 0 and cy/cx <= slp
    else
        cx = tx + tw - bx
        cy = ty - by
        return cx < 0 and cy/cx >= slp
    end
end
--tutorial written function beware--