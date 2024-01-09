unit messages;

interface
	uses arbol;

	type
		// Estructuras relacionadas a la lista 'Mensajes'
		PuntMensajes = ^NodoMensajes;
		NodoMensajes = record
			fechayhora: string;
			mensaje: string;
			leido: boolean;
			emisor: PuntUsuarios;
			siguiente: PuntMensajes;
		end;
		Mensajes = record
			fechayhora: string;
			mensaje: string;
			leido: boolean;
			emisor: string[8];
		end;
		ArchMensajes = file of Mensajes;

	// Funciones relacionadas con la lista 'Mensajes'
	function Datos_Mensajes(registro: Mensajes; emisor: PuntUsuarios): PuntMensajes;
	procedure AgregarMensaje(var lista_mensajes: PuntMensajes; nodo: PuntMensajes);
	procedure CargarMensajesDeArchivo(var archivo: ArchMensajes; var lista_mensajes: PuntMensajes; emisor: PuntUsuarios);

	function Mensaje(lista_mensajes: PuntMensajes; num: integer): PuntMensajes;
	procedure EliminarMensajes(var lista_mensajes: PuntMensajes);

	procedure CargarArchivoDeMensajes(var archivo: ArchMensajes; lista_mensajes: PuntMensajes);

implementation
	function Datos_Mensajes(registro: Mensajes; emisor: PuntUsuarios): PuntMensajes;
	{ Crea un nodo de mensajes a partir de un registro de archivo }
	var lista_mensajes: PuntMensajes;
	begin
		new(lista_mensajes);
		lista_mensajes^.fechayhora := registro.fechayhora;
		lista_mensajes^.mensaje := registro.mensaje;
		lista_mensajes^.leido := registro.leido;
		lista_mensajes^.emisor := emisor;
		lista_mensajes^.siguiente := nil;
		Datos_Mensajes := lista_mensajes;
	end;

	procedure AgregarMensaje(var lista_mensajes: PuntMensajes; nodo: PuntMensajes);
	{ Inserta un mensaje a la lista ordenado por mas reciente a mas antiguo }
	begin
		if (lista_mensajes = nil) or (nodo^.fechayhora > lista_mensajes^.fechayhora) then begin // Verfica que la lista sea nula o la fecha sea mas reciente
	 		nodo^.siguiente := lista_mensajes; // De ser asi insertamos el nodo a la lista
	 		lista_mensajes := nodo;
		end else // Sino simplemente llamamos a recursion para seguir recorriendo la lista
			AgregarMensaje(lista_mensajes^.siguiente, nodo);
	end;

	procedure CargarMensajesDeArchivo(var archivo: ArchMensajes; var lista_mensajes: PuntMensajes; emisor: PuntUsuarios);
	{ Pasa los registros del archivo como nodos a la lista Mensajes }
	var
		iguales: boolean;
		registro: Mensajes;
	begin
		iguales := True; // Define un booleano que representara la igualdad del emisor de los mensajes actuales junto con el emisor actual del archivo
		while (not eof(archivo)) and (iguales) do begin // Bucle que se repite hasta el final del archivo o hasta que los emisores anteriormente mencionados sean diferentes
			read(archivo, registro); // Lee el archivo
			iguales := (emisor^.nombre = registro.emisor); // Y redefine la condicion
			if iguales then
				AgregarMensaje(lista_mensajes, Datos_Mensajes(registro, emisor)) // Agrega un nodo a la lista
		end;
		if FileSize(archivo) <> 0 then
			seek(archivo, FilePos(archivo) - 1); // Retrocede una posicion en el archivo debido que, para poder saber la condicion 'iguales', hay que leer una vez mas de lo necesario el archivo, y por ende debemos retroceder una posicion
	end;

	function Mensaje(lista_mensajes: PuntMensajes; num: integer): PuntMensajes;
	{ Te devuelve un nodo de la lista Mensajes a partir de una posicion }
	var cont: integer;
	begin
		cont := 1; // Inicializa un contador
		while (lista_mensajes <> nil) and (cont <= num) do begin // Verifica que no hayamos llegado al final de la lista o a la posicion deseada
			lista_mensajes := lista_mensajes^.siguiente; // Se mueve a la siguiente posicion
			cont := cont + 1; // Y agrega uno al contador
		end;
		Mensaje := lista_mensajes;
	end;

	procedure EliminarMensajes(var lista_mensajes: PuntMensajes);
	{ Borra toda una lista de mensajes }
	begin
		if lista_mensajes <> nil then begin // Verifica que la lista no este vacia
			if lista_mensajes^.siguiente <> nil then // Detecta si el nodo actual tiene un siguiente...
				EliminarMensajes(lista_mensajes^.siguiente) // Y si es asi recorre toda la lista para llegar al ultimo...
			else
				dispose(lista_mensajes); // Y borrar los elementos de atras para adelante
		end;
	end;

	function Mensajes_Archivo(nodo_mensaje: PuntMensajes): Mensajes;
	{ Este procedimiento realiza una conversion de un nodo de mensaje, a un registro del archivo }
	var registro: Mensajes;
	begin
		registro.fechayhora := nodo_mensaje^.fechayhora;
		registro.mensaje := nodo_mensaje^.mensaje;
		registro.leido := nodo_mensaje^.leido;
		registro.emisor := nodo_mensaje^.emisor^.nombre;
		Mensajes_Archivo := registro;
	end;

	procedure CargarArchivoDeMensajes(var archivo: ArchMensajes; lista_mensajes: PuntMensajes);
	{ Carga en el archivo todos los mensajes }
	var registro: Mensajes;
	begin
		if lista_mensajes <> nil then begin
			registro := Mensajes_Archivo(lista_mensajes); // Convierte el nodo mensaje a un registro que el archivo puede contener
			write(archivo, registro); // Escribe el archivo
			CargarArchivoDeMensajes(archivo, lista_mensajes^.siguiente); // Se llama a si misma con el siguiente elemento de la lista
		end;
	end;
end.