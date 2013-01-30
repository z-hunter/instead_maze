--- MAZE

instead_version "1.8.0"
require "xact";
require "sprites"

global {--{{{

	spa,
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


	gen = function (M, x1,y1, x2,y2)		-- генерируем рандомный лабиринт в maze M от точки 1 к 2
		
			
		local tx = {}; local ty = {};  local ti=1;	-- массивы координат пройденных ячеек и индекс		
		tx[ti] = x1; ty[ti]= y1;
		local cx = x1; local cy = y1;				-- координаты текущей ячейки
		local dir; local dir2; local x; local y;
		counter = 1;
				
		--while cx ~= x2 and cy ~= y2 do			-- пока не пришли
		    
		    counter = counter + 1
		    -- if counter > 100 then break end;

		    dir, dir2, x, y = maze.rnd_dir(M, cx, cy);	-- выбираем направление
		    if M[cx][cy].dir[dir] then			-- если там уже есть дверь
			if ti > 1 then
			    ti = ti - 1;
			    cx = tx[ti]; cy = ty[ti];
			end;
		    else			
			M[cx][cy].dir[dir] = true;		-- делаем дверь
			ti = ti + 1; tx[ti] = cx ; ty[ti] = cy;
			cx = x; cy = y;
			M[cx][cy].dir[dir2] = true;		-- дверь в обратном направлении
		    end;
		--end;

	end,

	test = function ()		    
		    counter = counter + 1; rollback = false;		    
			
		    repeat						
		        dir, dir2, x, y = maze.rnd_dir(M, cx, cy, 2);	-- выбираем направление			
		    until dir ~= oldir2					-- кроме того, откуда пришли			
		    
		    if M[cx][cy].dir[dir] then			-- если там уже есть дверь
			rollback = true;
			if ti > 1 then
			    ti = ti - 1;
			    cx = tx[ti]; cy = ty[ti];
			end;
		    else			
			M[cx][cy].dir[dir] = true;		-- делаем дверь
			M[cx][cy].type = maze.t_room;		-- помечаем как комнату
			ti = ti + 1; tx[ti] = cx ; ty[ti] = cy;
			cx = x; cy = y;
			oldir2 = dir2;
			M[cx][cy].dir[dir2] = true;		-- дверь в обратном направлении
			M[cx][cy].type = maze.t_room;		-- помечаем как комнату
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
	x1 = 2; y1 = 1;--}}}
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
		maze.test()
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



