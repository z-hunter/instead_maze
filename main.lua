--- MAZE

instead_version "1.8.0"
require "xact";
require "sprites"

global {--{{{

	maz = {},	

}--}}}


maze = {

	t_room = 10, t_corr_horiz=1, t_corr_vert=2,

	create = function(xs, ys)		    -- возвращает maze размером xs на ys

		local i; local j;
		local maze = {};
		
		for i=1, xs do
		    maze[i] = {};
		    for j=1, ys do
			maze[i][j] = {};				
			-- maze[i][j].type 	-- тип клетки: nil = пусто, 1 = гориз. корридор 2 = верт. коридор, 10 = комната
			maze[i][j].dir = {};	-- стороны перехода: .l .u .r .d  .up .down
						  -->  nil = стена, 1 = проход, 2 = дверь закрыта, 3 = дверь открыта							-->  напр. -- maze[1][1].dir.w = 1 -- в ячейке 1.1 есть проход на запад 
		    end;
		end;
		maze.xs = xs; maze.ys = ys;
		return maze;

	end,


	dump = function (maz)				---  распечатка
		local i; local j;		
	
		for j=1, maz.ys do
		    for i=1, maz.xs do
			local M = maz[i][j].dir;
			local S = spr_cell;
			
			if maz[i][j].type == maze.t_room then
				if M.l and M.r and M.u and M.d  then S = spr_dlrud;
				 elseif M.l and M.u and M.r then S = spr_dlur;
				 elseif M.l and M.d and M.r then S = spr_dldr;
				 elseif M.u and M.r and M.d then S = spr_durd;
				 elseif M.u and M.l and M.d then S = spr_duld;
				 elseif M.d and M.r then S = spr_ddr;
				 elseif M.l and M.d then S = spr_dld;
				 elseif M.l and M.r then S = spr_dlr;
				 elseif M.u and M.d then S = spr_dud;
				 elseif M.u and M.r then S = spr_dur;
				 elseif M.l and M.u then S = spr_dlu;
				 elseif M.u then S = spr_du;
				 elseif M.r then S = spr_dr;
				 elseif M.d then S = spr_dd;
				 elseif M.l then S = spr_dl;
				end;
			-- else p(maze[i][j].type)
			end;
					    
			pr( img(S) );
		    end;
		    pn();
		end;
	end,


	gen_mine = function (M, x1,y1, x2,y2)		-- прогрызаем рандомный маршрут в maze M от точки 1 к 2
		
			
	    local tx = {}; local ty = {};  local ti=1;	-- массивы координат пройденных ячеек и индекс		
	    tx[ti] = x1; ty[ti]= y1;
	    local cx = x1; local cy = y1;				-- координаты текущей ячейки
	    local dir; local dir2; local x; local y;
	    local counter = 1;
				
	    local maxcounter = M.xs * M.ys - (M.xs + M.ys);
	    repeat

		    counter = counter + 1; -- rollback = false;		    

		    if cx == x2 and cy == y2 then
			return true;			
		    end;		    

		    repeat						
		        dir, dir2, x, y = maze.rnd_dir(M, cx, cy, 2);	-- выбираем направление			
		    until dir ~= oldir2					-- кроме того, откуда пришли			
		    
		    if M[cx][cy].dir[dir] then			-- если там уже есть дверь
			-- rollback = true;
			if ti > 1 then				-- и есть куда откатиться - откатываемся
			    ti = ti - 1;
			    cx = tx[ti]; cy = ty[ti];
			else
			    break
			end;
		    else			
			maze.gen_makedoor(M, cx, cy, dir);			
			ti = ti + 1; tx[ti] = cx ; ty[ti] = cy;	    -- запоминаем где мы были
			cx = x; cy = y;
			oldir2 = dir2;				    -- запоминаем откуда пришли	
		    end;

	    until counter > maxcounter;
		maze.gen_connect(M, cx, cy, x2, y2);
		return true;
	end,

	test = function ()		    
		    
	    local maxcounter = M.xs * M.ys - (M.xs + M.ys);
	    repeat

		    counter = counter + 1; -- rollback = false;		    

		    if cx == x2 and cy == y2 then
			return true;			
		    end;		    

		    repeat						
		        dir, dir2, x, y = maze.rnd_dir(M, cx, cy, 2);	-- выбираем направление			
		    until dir ~= oldir2					-- кроме того, откуда пришли			
		    
		    if M[cx][cy].dir[dir] then			-- если там уже есть дверь
			-- rollback = true;
			if ti > 1 then				-- и есть куда откатиться - откатываемся
			    ti = ti - 1;
			    cx = tx[ti]; cy = ty[ti];
			else
			    break
			end;
		    else			
			maze.gen_makedoor(M, cx, cy, dir);			
			ti = ti + 1; tx[ti] = cx ; ty[ti] = cy;	    -- запоминаем где мы были
			cx = x; cy = y;
			oldir2 = dir2;				    -- запоминаем откуда пришли	
		    end;

	    until counter > maxcounter;
	    maze.gen_connect(M, cx, cy, x2, y2);
	    return true;
	end;

	gen_connect = function ( M, x1,y1, x2,y2)
	    local cx = x2; local cy = y2;
    	    local c2;
	    local dir;
	    while cx ~= x1 do
		if cx > x1 then dir = "l"; c2 = cx-1;
		else dir = "r"; c2 = cx+1;
		end;
		if M[c2][cy].type then
		    maze.gen_makedoor (M, cx, cy, dir);
		    return true;		
		else
		    maze.gen_makedoor (M, cx, cy, dir);		
		    cx = c2;
		end;
	    end;
	    while cy ~= y1 do
		if cy > y1 then dir = "u"; c2 = cy - 1;
		else dir = "d"; c2 = cy + 1;
		end;
		if M[cx][c2].type then
		    maze.gen_makedoor (M, cx, cy, dir);
		    return true;
		else
		  maze.gen_makedoor (M, cx, cy, dir);
		  cy = c2;
		end;
	    end;

	end,

	

	gen_makedoor = function (M, x1,y1, dir)			-- соединяет две ячейки дверью и делает их room
	    local x2=x1; local y2=y1;
	    local dir2;
	    if dir == "u" then dir2 = "d"; y2 = y2-1;
	    elseif dir == "d" then dir2 = "u"; y2 = y2+1;
	    elseif dir == "l" then dir2 = "r"; x2 = x2-1;
	    elseif dir == "r" then dir2 = "l"; x2 = x2+1;
	    end;
	    M[x1][y1].dir[dir] = 2;
	    M[x1][y1].type = maze.t_room;
	    if  x2 > 0 and x2 <= M.xs and y2 > 0 and y2 <= M.ys then
		M[x2][y2].dir[dir2] = 2;
		M[x2][y2].type = maze.t_room;
	    end;
	end;


	_rnd_dir_track=0,
	_rnd_dir_rnd=0,
	
	rnd_dir = function (M, cx, cy, rep)			-- возвр. случайное направление в виде ключа (lurd)
								-- не допуская выход из ячейки cx/cy наружу M
		rep = rep or 1;					-- опциональный rep = кол-во повторов выбора
		local ret; local ret2				
		local x; local y;
		local r;
		repeat
		    if maze._rnd_dir_track == 0 then
			r = rnd (4);
			maze._rnd_dir_rnd = r;
			maze._rnd_dir_track = rep;
		    else
			r = maze._rnd_dir_rnd;
			maze._rnd_dir_track = maze._rnd_dir_track - 1;    
		    end;

		    x = cx; y = cy;
		    if r == 1  then ret = "l"; ret2 = "r"; x = x-1; 
		    elseif r == 2 then ret = "u"; ret2 = "d"; y = y-1;
		    elseif r == 3 then ret = "r"; ret2 = "l"; x = x+1;
		    elseif r == 4 then ret ="d"; ret2 = "u"; y = y+1;
		    end;		   
		until x > 0 and x <= M.xs and y > 0 and y <= M.ys;
		return ret, ret2, x, y;
	end,

};



init = function()
	M = maze.create(10,10);--{{{
	x1 = rnd(5); y1 = rnd(5);--}}}
	x2 = rnd(5)+5; y2 = rnd(5)+5;
	tx = {}; ty = {};  ti=1;	-- массивы координат пройденных ячеек и индекс		
	tx[ti] = x1; ty[ti]= y1;
	cx = x1; cy = y1;				-- координаты текущей ячейки
	track = 0;
	-- dir; dir2; x; y;
	counter = 1;

	-- maz[2][4].dir.u = true;
	sprites_init();
end;


main = room {
    	forcedsc = true,
	nam = "лабиринт",
	dsc = function(s)
			maze.gen_mine(M, x1,y1,)

		-- maze.gen_connect(M, cx,cy, x2,y2)
		-- sprite_init();
		-- s.pic = spr_cell;	
		maze.dump(M);
		p(counter);
		pn(cx, ":", cy);
		p ("ti=",ti);
		if rollback then p " rollback" end;
		p(" dir=",dir, " dir2=",dir2);
	end,
	
};


function sprites_init()
	local i;
	
	spr_cell = sprite.load("./pic/spr_cell.png"); 	-- пустая ячейка
	
	spr_dlrud = sprite.load("./pic/dlrud.png")	-- doors lert & right & up & down 		
	spr_dlur = sprite.load("./pic/dlur.png")		
	spr_dldr = sprite.load("./pic/dldr.png")
	spr_durd = sprite.load("./pic/durd.png")
	spr_duld = sprite.load("./pic/duld.png")
	spr_ddr = sprite.load("./pic/ddr.png")		
	spr_dld = sprite.load("./pic/dld.png")		
	spr_dlr = sprite.load("./pic/dlr.png")		
	spr_dud = sprite.load("./pic/dud.png")		
	spr_dur = sprite.load("./pic/dur.png")
	spr_dlu = sprite.load("./pic/dlu.png")
	spr_du = sprite.load("./pic/du.png")		-- door up
	spr_dr = sprite.load("./pic/dr.png")		-- door right
	spr_dd = sprite.load("./pic/dd.png")		
	spr_dl = sprite.load("./pic/dl.png")		


end;



