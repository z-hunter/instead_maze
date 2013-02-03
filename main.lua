--- MAZE

instead_version "1.8.0"
require "xact";
require "sprites"

global {--{{{

	maz = {},	

}--}}}


maze = {

	t_room = 10, t_corr_lr=1, t_corr_ud=2,

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


	dump = function (maz, herex, herey)				---  распечатка
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
			elseif maz[i][j].type == maze.t_corr_lr then


				if M.l and M.r==1 and M.u and M.d  then S = spr_cor_lr_dud;

   				 elseif M.l and not M.r and not M.u and not M.d then S = spr_cor_lr_cr;
				 elseif M.r and not M.l and not M.u and not M.d then S = spr_cor_lr_cl;
				 elseif M.u and M.l and M.d and not M.r then S = spr_cor_lr_dud_cr;
				 elseif M.u and M.r and M.d and not M.l then S = spr_cor_lr_dud_cl;

				 elseif M.d and M.r and not M.u and not M.l  then S = spr_cor_lr_dd_cl;
				 elseif M.d and M.l and not M.u and not M.r  then S = spr_cor_lr_dd_cr;
				 elseif M.u and M.r and not M.d and not M.l  then S = spr_cor_lr_du_cl;
				 elseif M.u and M.l and not M.d and not M.r  then S = spr_cor_lr_du_cr;				 
				 elseif M.l and M.u and M.r==1 then S = spr_cor_lr_du
				 elseif M.l and M.u and M.r==2 then S = spr_cor_lr_dur
				 
				 elseif M.l and M.d and M.r==1 then S = spr_cor_lr_dd;
				 elseif M.l and M.d and M.r==2 then S = spr_cor_lr_ddr;
				 else S = spr_cor_lr;				 
				end;
			end;
			    local SP = sprite.dup(S);
			    if i==herex and j==herey then
				sprite.copy(spr_heredot, SP, 1,1);			    
			    end;
			    pr( img(SP) );
			
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

	
	gen_corridorize = function(M)			-- лабиринт это советская власть + корридоризация всей страны
	    
	    local function chk_lr(M, x,y)
		if M[x][y].dir.r and M[x+1][y].dir.r and M[x+2][y].dir.r then
		    return true
		else return false;
		end;
	    end;

	    local function stall_r(M, x,y)
		while M[x][y].dir.r do
		    M[x][y].type = maze.t_corr_lr;
		    M[x][y].dir.r = 1;
		    x = x+1;
		end;
		M[x][y].type = maze.t_corr_lr;
		if M[x][y].dir.r then M[x][y].dir.r = 2 end;
		return x;
	    end;
	    
	    for y=1, M.ys do
		for x=1, M.xs-3 do
		    if chk_lr(M, x,y) then
			x = stall_r(M,x,y);
		    else x = x+1;
		    end;
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


	sprites_init = function()
		
	    local path = "./pic/"; local ext = ".png";
	    local names = {
		    
		"heredot",
		"cor_lr",
		"cor_lr_cl",
		"cor_lr_cr",
		"cor_lr_dd",
		"cor_lr_ddr",
		"cor_lr_dd_cl",
		"cor_lr_dd_cr",
		"cor_lr_dr",
		"cor_lr_du",
		"cor_lr_dud",
		"cor_lr_dud_cl",
		"cor_lr_dud_cr",
		"cor_lr_dur",
		"cor_lr_durd",
		"cor_lr_du_cl",
		"cor_lr_du_cr",
		"cor_ud",
		"cor_lr_du",
		"dd",
		"ddr",
		"dl",
		"dld",
		"dldr",
		"dlr",
		"dlrud",	-- doors lert & right & up & down 		
		"dlu",
		"dlur",
		"dr",
		"du",
		"dud",
		"duld",
		"dur",
		"durd",
		"cell",	-- пустая ячейка
	    };

	    for _, v in pairs(names) do
		_G["spr_"..v] = spriteload(path..v..ext);
	    end;	
        end,

};



init = function()
	M = maze.create(10,10);
	x1 = rnd(5); y1 = rnd(5);
	x2 = rnd(5)+5; y2 = rnd(5)+5;
	maze.sprites_init();
end;


main = room {
    	forcedsc = true,
	nam = "лабиринт",
	dsc = function(s)
	 
		maze.gen_mine(M, x1,y1, x2, y2)
		maze.gen_corridorize(M)
		

		-- maze.gen_connect(M, cx,cy, x2,y2)
		-- sprite_init();
		-- s.pic = spr_cell;	
		maze.dump(M,1,1);
		
	end,
	
};





function spriteload(pat)
    local ret = sprite.load(pat);
    if not ret then error ("spriteload(): Cannot load "..pat);  end;
    return ret;
end;
   
   



