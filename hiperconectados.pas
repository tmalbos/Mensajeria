unit hiperconectados;

interface
	uses conversaciones, arbol, crt;

	type
		// Estructuras relacionadas con la lista 'Hipcon'
		PuntHipcon = ^NodoHipcon;
		NodoHipcon = record
			nombre: PuntUsuarios;
			siguiente: PuntHipcon;
		end;

	// Funciones relacionadas con la lista 'Hipcon'
	procedure AgregarHipcon(var lista_hipcon: PuntHipcon; nodo_hipcon: PuntHipcon; lista_convers: PuntConvers);
	procedure CargarLista(var lista_hipcon: PuntHipcon; convers: PuntConvers; arbol: PuntUsuarios);

	procedure VerUsuariosHiperconectados(arbol: PuntUsuarios; convers: PuntConvers);

implementation
	function Hipcon(usuario: PuntUsuarios): PuntHipcon;
	var	nodo: PuntHipcon;
	begin
		new(nodo);
		nodo^.nombre := usuario;
		nodo^.siguiente := nil;
		Hipcon := nodo;
	end;

	procedure AgregarHipcon(var lista_hipcon: PuntHipcon; nodo_hipcon: PuntHipcon; lista_convers: PuntConvers);
	begin
		if (lista_hipcon = nil) or (CantidadConvers(nodo_hipcon^.nombre^.nombre, lista_convers) > CantidadConvers(lista_hipcon^.nombre^.nombre, lista_convers)) then begin
		 	nodo_hipcon^.siguiente := lista_hipcon;
		 	lista_hipcon := nodo_hipcon;
		end else
			AgregarHipcon(lista_hipcon^.siguiente, nodo_hipcon, lista_convers);
	end;

	procedure CargarLista(var lista_hipcon: PuntHipcon; convers: PuntConvers; arbol: PuntUsuarios);
	begin
		if arbol <> nil then begin
			CargarLista(lista_hipcon, convers, arbol^.menor);
			AgregarHipcon(lista_hipcon, Hipcon(arbol), convers);
			CargarLista(lista_hipcon, convers, arbol^.mayor);
		end;
	end;

	procedure PantallaHiperconectados(lista_hiper: PuntHipcon; lista_convers: PuntConvers);
	var cont: integer;
	begin
		Window(1, 1, 80, 255); // Esta es la ventana principal
		TextBackground(cyan); clrscr; // Se determinan colores para el fondo de pantalla y se actualiza la pantalla
		GotoXY(17, 2); write('Usuario');
		GotoXY(40, 2); write(chr(186));
		GotoXY(44, 2); write('Cantidad de conversaciones activas');
		GotoXY(2, 3);
		for cont := 1 to 78 do begin
			if cont = 39 then write(chr(206))
			else write(chr(205));
		end;
		cont := 4;
		while lista_hiper <> nil do begin
			GotoXY(3, cont); write(lista_hiper^.nombre^.nombre);
			GotoXY(40, cont); write(chr(186));
			GotoXY(43, cont); write(CantidadConvers(lista_hiper^.nombre^.nombre, lista_convers));
			cont := cont + 1; lista_hiper := lista_hiper^.siguiente;
		end;
		GotoXY(2, cont);
		for cont := 1 to 78 do begin
			if cont = 39 then write(chr(202))
			else write(chr(205));
		end;
		readln;
	end;

	procedure EliminarHipcons(var lista_hipcon: PuntHipcon);
	{ Borra toda la lista de usuarios hiperconectados }
	begin
		if lista_hipcon <> nil then begin // Verifica que la lista no este vacia
			if lista_hipcon^.siguiente <> nil then // Detecta si el nodo actual tiene un siguiente...
				EliminarHipcons(lista_hipcon^.siguiente) // Y si es asi recorre toda la lista para llegar al ultimo...
			else
				dispose(lista_hipcon); // Y borrar los elementos de atras para adelante
		end;
	end;

	procedure VerUsuariosHiperconectados(arbol: PuntUsuarios; convers: PuntConvers);
	var lista_hipcon: PuntHipcon;
	begin
		CargarLista(lista_hipcon, convers, arbol);
		PantallaHiperconectados(lista_hipcon, convers);
		EliminarHipcons(lista_hipcon);
	end;
end.