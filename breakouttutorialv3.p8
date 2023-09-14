 --breakout tutorial--

        --goals--
 -- 4. different  bricks --
 -- 5. combos --
 -- 6. more game feel (particles/screenshake) --
 -- 7. high score tracking --
 -- 8. power ups --
 -- 9. roguelike powers --
 -- 10.arrow animations
 -- 11.text blinking
 -- eamonrequest. colour scheme changes through gameplay --


 function _init()
  cls()
  mode="start"
  level="p9/x9/b9"
  debug=""
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
  pad_y=120
  pad_dx=0
  
  pad_w=24 
  pad_h=3
  pad_c=8
  
  --pad variables--
  
  --brick variables--
  
  brick_w=9
  brick_h=3
  
  buildbricks(level)
   
  --brick variables--
  
  lives=3
  points=0

  sticky=true

  chain=1 --chain multiplier

  serveball()

 end

 function buildbricks(lvl)
  local i,j,o,chr,last
  brick_x={}
  brick_y={}
  brick_v={}
  brick_c={}
  hitstobreak={}
  j=0

  for i=1,#lvl do
   j+=1
   chr=sub(lvl,i,i)

   if chr=="b" then
    last="b"
    add(brick_x,4+((j-1)%11)*(brick_w+2))
    add(brick_y,30+flr((j-1)/11)*(brick_h+2))
    add(brick_v,true) 
    add(brick_c,8)
   elseif chr=="x" then
    last="x"
   elseif chr=="/" then
    j=(flr((j-1)/11)+1)*11
   elseif chr=="p" then
    last="p"
    add(brick_x,4+((j-1)%11)*(brick_w+2))
    add(brick_y,30+flr((j-1)/11)*(brick_h+2))
    add(brick_v,true) 
    add(brick_c,10)
   elseif chr>="1" and chr<="9" then
    for o=1,chr+0 do
     if last=="b" then
      add(brick_x,4+((j-1)%11)*(brick_w+2))
      add(brick_y,20+flr((j-1)/11)*(brick_h+2))
      add(brick_v,true)
      add(brick_c,8)
     elseif last=="p" then
      add(brick_x,4+((j-1)%11)*(brick_w+2))
      add(brick_y,20+flr((j-1)/11)*(brick_h+2))
      add(brick_v,true)
      add(brick_c,10)
      add(hitstobreak,2)
     elseif last=="x" then
     end
     j+=1
     end
    j-=1
   end
  end
 end

 function check_level_finish()
   for i=1,#brick_v do
     if brick_v[i] then
       return false  -- there's at least one active brick, so the level isn't finished.
     end
   end
   return true  -- all bricks are destroyed; the level is finished.
 end

 function serveball()
  ball_x=pad_x+flr(pad_w/2) 
  ball_y=pad_y-ball_r
  ball_dx=1
  ball_dy=-1
  ball_ang=1
  sticky=true
 end

 function setang(ang)
  ball_ang=ang
  if ang==2 then
   ball_dx=0.50*sign(ball_dx)
   ball_dy=1.30*sign(ball_dy)  
  elseif ang==0 then
   ball_dx=1.30*sign(ball_dx)
   ball_dy=0.50*sign(ball_dy) 
  else
   ball_dx=1*sign(ball_dx)
   ball_dy=1*sign(ball_dy)
  end
 end

 function sign(n)
  if n<0 then
   return -1
  elseif n>0 then
   return 1
  else
   return 0
  end
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
   pad_dx=-2.5
  --pad_x-=5
   if sticky then
    ball_dx=-1
   end
  end
  if btn(➡️) then 
   buttpress=true
   pad_dx=2.5
  --pad_x+=5
   if sticky then
    ball_dx=1
   end
  end

  if sticky and btn(❎) then
   sticky=false
   sfx(8)
  end
  
  if not(buttpress) then
   pad_dx=pad_dx/1.3
  end

   pad_x+=pad_dx
   pad_x=mid(0,pad_x,127-pad_w)

 --pad movement--

   if sticky then
    ball_x=pad_x+pad_w/2
    ball_y=pad_y-ball_r-1
   else

   --regular ball physics--
   nextx=ball_x+ball_dx
   nexty=ball_y+ball_dy
   --regular ball physics--

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
    --ball hit paddle on the side--
    ball_dx = -ball_dx
    if ball_x < pad_x+pad_w/2 then
     nextx=pad_x-ball_r
    else
     nextx=pad_x+pad_w+ball_r
    end
   else
    --ball hit paddle on the top/bottom--
    ball_dy = -ball_dy
    if ball_y > pad_y then
     --bottom of paddle---
     nexty=pad_y+pad_h+ball_r
    else
     --top of paddle---
     nexty=pad_y-ball_r
     if abs(pad_dx)>2 then
      --change angle--
      if sign(pad_dx)==sign(ball_dx) then
       --flatten angle
       setang(mid(0,ball_ang-1,2))
      else
       --raise angle
       if ball_ang==2 then
        ball_dx=-ball_dx
       else
        setang(mid(0,ball_ang+1,2))
       end
      end
     end 
    end
   end
   --collision actions--
   chain=1
   sfx(3)
   --collision actions--
   end  

  
 --collision - paddle --

   brickhit=false

  -- collision - brick --
   for i=1,#brick_x do
    --check if ball hit brick--
    if brick_v[i] and ball_box(nextx,nexty,brick_x[i],brick_y[i],brick_w,brick_h) then
    --check if ball hit brick--
     --find which direction to deflect--
     if not (brickhit) then
      if deflx_ball_box(ball_x,ball_y,ball_dx,ball_dy,brick_x[i],brick_y[i],brick_w,brick_h) then
       ball_dx = -ball_dx
      else
       ball_dy = -ball_dy
      end
     end
       --collision actions--
       brickhit=true
       sfx(9+chain)
       brick_v[i]=false
       points+=10*chain
       chain+=1
       chain=mid(1,chain,8)
       --collision actions--
       if hitstobreak==2 then
        hitstobreak=1
       elseif hitstobreak==1 then
     end
      end
    end
   end 
 -- collision - brick --

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
   -- check if the level is finished
   if check_level_finish() then
     -- handle level finish here
     -- for example, you can load the next level or display a "level complete" message.
     -- for simplicity, let's just restart the same level.
     buildbricks(level)
     serveball()
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
  if sticky then
   print("press ❎ to serve ball",20,100,8)
  --serve preview--
   line(ball_x+ball_dx*4,ball_y+ball_dy*4,ball_x+ball_dx*8,ball_y+ball_dy*8,8)
  --serve preview-- 
  end
   rectfill(pad_x,pad_y,pad_x+pad_w,pad_y+pad_h,pad_c)
  
  --draw bricks--
  
  for i=1,#brick_x do
   if brick_v[i] then
    rectfill(brick_x[i],brick_y[i],brick_x[i]+brick_w,brick_y[i]+brick_h,brick_c[i])
   end
  end

  --draw bricks--
  
  --draw pad--
  --draw pad--
   
   rectfill(0,0,128,6,8)
  if debug!="" then 
   print(debug,1,1,7)
  else
   print("lives:"..lives,4,1,1)
   print("score:"..points,37,1,1)
   print("combo:"..chain,77,1,1)
  end
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

 --tutorial written0function beware--
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