unit graficos;

interface
	uses crt, messages, conversaciones;

	const
		backspace = chr(8);
		enter = chr(13);
		cuadradito = chr(254);
		k_up = chr(72);
		k_down = chr(80);
		esc = chr(27);
		Menu1: array[1..4] of string = ('Crear Nuevo Usuario ',
										'Ingresar ',
										'Ver Usuarios Hiperconectados ',
										'Salir ');
		Menu2: array[1..8] of string = ('Mostrar Conversaciones No Leidas ',
										'Mostrar Todas Las Conversaciones ',
										'Ver Ultimos Mensajes De Conversaciones ',
										'Ver Conversacion ',
										'Constestar Mensaje ',
										'Nueva Conversacion ',
										'Borrar Usuario ',
										'Salir ');

	procedure PantallaMenu2(posicion: integer);
	procedure PantallaMenu1(posicion: integer);
	function PantallaEleccionConvers(lista_convers: PuntConvers; usuario: string; posicion: integer; noleido: boolean): PuntConvers;

	function PosicionMsjsNoLeidos(lista_mensajes: PuntMensajes; destinatario: string): integer;
	function DeterminarDest(nodo_convers: PuntConvers; usuario: string): string;
	procedure PantallaBusqueda(error: boolean);
	procedure PantallaConvers(emisor, destinatario: string; lista_mensajes: PuntMensajes; cantidad: integer);
	procedure PantallaLogin_Signup(casilla: boolean; error: integer; usuario: string);
	function Codificacion(clave: boolean): string;

implementation
	procedure PantallaPrincipal();
	begin
		Window(1, 1, 80, 255); // Esta es la ventana principal
		TextBackground(cyan); // Se determina el color para el fondo de pantalla
		TextColor(black);
		clrscr; // Y se actualiza la pantalla
	end;

	procedure Casillero(x1, y1, x2, y2, fondo: integer);
	begin
		TextBackground(fondo);
		TextColor(black);
		Window(x1, y1, x2, y2);
		clrscr;
		GotoXY(2, 2);
	end;

	procedure PantallaMenu2(posicion: integer);
	var Ypos, opciones: integer;
	begin
		PantallaPrincipal();
		for opciones := 1 to 8 do begin
			if opciones <> posicion then begin
				Ypos := opciones * 3;
				GotoXY(4, Ypos);
				write(Menu2[opciones]);
			end;
		end;
		Ypos := posicion * 3;
		Casillero(2, Ypos - 1, 70, Ypos + 1, white);
		write(Menu2[posicion]);
	end;

	function DeterminarDest(nodo_convers: PuntConvers; usuario: string): string;
	var destinatario: string;
	begin
		destinatario := '';
		if nodo_convers <> nil then begin
			if nodo_convers^.usuario1^.nombre = usuario then
				destinatario := nodo_convers^.usuario2^.nombre
			else if nodo_convers^.usuario2^.nombre = usuario then
				destinatario := nodo_convers^.usuario1^.nombre;
		end;
		DeterminarDest := destinatario;
	end;

	function PosicionMsjsNoLeidos(lista_mensajes: PuntMensajes; destinatario: string): integer;
	var posicion, contador: integer;
	begin
		posicion := 0; contador := 1;
		while lista_mensajes <> nil do begin
			if (lista_mensajes^.emisor^.nombre = destinatario) and (lista_mensajes^.leido = false) then begin
				posicion := posicion + contador;
				contador := 1;
			end else
				contador := contador + 1;
			lista_mensajes := lista_mensajes^.siguiente;
		end;
		PosicionMsjsNoLeidos := posicion;
	end;

	function PantallaEleccionConvers(lista_convers: PuntConvers; usuario: string; posicion: integer; noleido: boolean): PuntConvers;
	var
		Ypos, opciones: integer;
		elegido: PuntConvers;
		user1, user2, leido: boolean;
		destinatario: string;
	begin
		PantallaPrincipal();
		opciones := 1; elegido := nil;
		while lista_convers <> nil do begin
			user1 := lista_convers^.usuario1^.nombre = usuario;
			user2 := lista_convers^.usuario2^.nombre = usuario;
			if (user1) or (user2) then begin
				destinatario := DeterminarDest(lista_convers, usuario);
				leido := False;
				if noleido then
					leido := PosicionMsjsNoLeidos(lista_convers^.mensajes, destinatario) = 0;
				if not leido then begin
					if opciones <> posicion then begin
						Ypos := opciones * 3;
						GotoXY(4, Ypos); write(lista_convers^.codigo);
						GotoXY(10, Ypos); write(destinatario);
					end else
						elegido := lista_convers;
					opciones := opciones + 1;
				end;
			end;
			lista_convers := lista_convers^.siguiente;
		end;
		if elegido <> nil then begin
			Ypos := posicion * 3;
			Casillero(2, Ypos - 1, 70, Ypos + 1, white);
			write(elegido^.codigo);
			GotoXY(8, 2); write(DeterminarDest(elegido, usuario));
		end;
		PantallaEleccionConvers := elegido;
	end;

	procedure PantallaBusqueda(error: boolean);
	begin
		PantallaPrincipal();
		GotoXY(23, 10); write('Ingrese el nombre del destinatario');
		if error then begin
			TextColor(red); GotoXY(11, 16);
			write('El nombre de usuario que eligio no existe, pruebe con otro');
		end;
		Casillero(18, 12, 61, 14, white);
	end;

	procedure PantallaConvers(emisor, destinatario: string; lista_mensajes: PuntMensajes; cantidad: integer);
	var Ypos: integer;
	begin
		PantallaPrincipal();
		GotoXY(30, 2); write(destinatario);
		Ypos := 4;
		while (Ypos < 253) and (lista_mensajes <> nil) and (cantidad > 0) do begin
			if lista_mensajes^.emisor^.nombre = emisor then
				Casillero(30, Ypos, 78, Ypos + 2, yellow)
			else
				Casillero(3, Ypos, 50, Ypos + 2, white);
			write(lista_mensajes^.fechayhora);
			write(' ' + lista_mensajes^.mensaje);
			if lista_mensajes^.emisor^.nombre = emisor then begin
				if lista_mensajes^.leido = false then
					TextColor(red)
				else
					TextColor(green);
				write(' ' + cuadradito);
			end;
			Ypos := Ypos + 4;
			cantidad := cantidad - 1;
			lista_mensajes := lista_mensajes^.siguiente;
		end;
		Casillero(1, Ypos, 80, Ypos + 2, white);
	end;

	procedure PantallaMenu1(posicion: integer);
	var Ypos, opciones: integer;
	begin
		PantallaPrincipal();
		for opciones := 1 to 4 do begin
			if opciones <> posicion then begin
				Ypos := opciones * 3;
				GotoXY(4, Ypos);
				write(Menu1[opciones]);
			end;
		end;
		Ypos := posicion * 3;
		Casillero(2, Ypos - 1, 70, Ypos + 1, white);
		write(Menu1[posicion]);
	end;

	procedure PantallaLogin_Signup(casilla: boolean; error: integer; usuario: string);
	begin
		PantallaPrincipal();
		GotoXY(19, 5); write('Nombre de usuario'); // Se mueve el cursor a la posicion donde sera escrito 'nombre de usuario'
		GotoXY(19, 13); write('Clave'); // Vuelve a mover el cursor...
		if error <> 0 then begin // Corrobora que no haya que enviar una addvertencia de algun error
			TextColor(red); GotoXY(11, 11); // Cambia el color del texto a rojo y muestra el error
			case error of
				1: write('El nombre de usuario que eligio ya existe, pruebe con otro');
				2: write('El nombre de usuario que ingreso no existe, pruebe a registrarse');
				3: begin
					GotoXY(11, 19);
					write('La contrase' + chr(164) + 'a que ingreso no es correcta, pruebe nuevamente');
				end;
			end;
		end;
		TextBackground(white); TextColor(black); // Se vuelve a cambiar el color del fondo y del texto (estos son los colores relacionados a las casillas donde se ingresan los datos)
		if casilla then begin // Si el usuario se encuentra en la primera casilla...
			Window(18, 15, 61, 17); clrscr; // Se ha de generar la segunda casilla primero
			Window(18, 7, 61, 9); clrscr; // Para asi el cursor quede dentro de la primera
		end else begin // Sino, es lo mismo pero a la inversa
			Window(18, 7, 61, 9); clrscr; GotoXY(2, 2); write(usuario);
			Window(18, 15, 61, 17); clrscr;
		end;
		GotoXY(2, 2); // Coloca el cursor en el centro de la casilla
	end;

	function Codificacion(clave: boolean): string;
	var
		tecla: char;
		cadena: string[8];
		posicion: integer;
	begin
		cadena := ''; posicion := 1; // Inicializa la cadena en blanco y la posicion en 1
		repeat // Bucle...
			if KeyPressed then begin // Pregunta constantemente si se ha presionado una tecla
				tecla := ReadKey; // Si es asi, se le asigna el valor a una variable
				if tecla = backspace then begin // Analiza si la tecla es backspace (borrar)
					posicion := posicion - 1; // Retrocede por una posicion
					if posicion < 1 then posicion := 1; // Evita que la posicion se vuelva un numero negativo
					cadena[posicion] := ' '; // Borra el caracter
					cadena[0] := chr(posicion); // Actualiza la longitud de la cadena
					GotoXY(1 + posicion, 2); write(' '); GotoXY(1 + posicion, 2); // Muestra el cambio en pantalla
				end else if tecla = esc then
					cadena := 'esc'
				else if (tecla <> enter) and (posicion < 9) then begin // Si la tecla es diferente a enter y no nos pasamos de 8 caracteres entonces
					cadena[posicion] := tecla; // Asignamos el valor de la tecla a la cadena
					cadena[0] := chr(posicion); // Actualizamos la longitud de esta
					if clave then begin // Determinamos si es una clave
						GotoXY(1 + posicion, 2); write('*'); // Y luego la reemplazamos con un asterisco
					end	else write(tecla); // Si no es una clave simplemente escribimos la letra pulsada
					posicion := posicion + 1; // Y sumamos uno a la posicion
				end;
			end;
		until (tecla = enter) or (tecla = esc); // El bucle se repite hasta que el usuario presione enter
		Codificacion := cadena; // Devuelve la cadena obtenida
	end;
end.