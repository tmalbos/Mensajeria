unit conversaciones;

interface
	uses messages, arbol;

	type
		// Estructuras relacionadas a la lista 'Conversaciones'
		PuntConvers = ^NodoConvers;
		NodoConvers = record
			codigo: integer;
			usuario1: PuntUsuarios;
			usuario2: PuntUsuarios;
			mensajes: PuntMensajes;
			siguiente: PuntConvers;
		end;
		Convers = record
			codigo: integer;
			usuario1: string[8];
			usuario2: string[8];
		end;
		ArchConvers = file of Convers;

	// Funciones relacionadas con la lista 'Conversaciones'
	procedure AgregarConvers(var lista_convers: PuntConvers; conver: PuntConvers);
	procedure CargarConversDeArchivo(var archivo_conversaciones: ArchConvers; var archivo_mensajes: ArchMensajes; var lista_convers: PuntConvers; arbol: PuntUsuarios);

	function Datos_Convers(usuario1, usuario2: PuntUsuarios): PuntConvers;
	function CantidadConvers(usuario: string; convers: PuntConvers): integer;
	function Conversacion(lista_convers: PuntConvers; usuario1, usuario2: string): PuntConvers;
	procedure EliminarConversaciones(var lista_convers: PuntConvers; usuario: string);

	procedure CargarArchivoDeConvers(var archivo_convers: ArchConvers; var archivo_mensajes: ArchMensajes; lista_convers: PuntConvers);
	procedure EliminarListaConvers(var lista_convers: PuntConvers);

implementation
	function Archivo_Convers(registro: Convers; var archivo_mensajes: ArchMensajes; arbol: PuntUsuarios): PuntConvers;
	{ Conversor del tipo de datos del archivo al nodo conversacion }
	var	lista_convers: PuntConvers;
	begin
		new(lista_convers); // Crea la lista_convers
		lista_convers^.codigo := registro.codigo; // Y le asigna los valores correspondientes
		lista_convers^.usuario1 := Nombre(arbol, registro.usuario1);
		lista_convers^.usuario2 := Nombre(arbol, registro.usuario2);
		CargarMensajesDeArchivo(archivo_mensajes, lista_convers^.mensajes, lista_convers^.usuario1); // Llama a la carga de los mensajes referidos con la conversacion corriente
		lista_convers^.siguiente := nil;
		Archivo_Convers := lista_convers;
	end;

	procedure AgregarConvers(var lista_convers: PuntConvers; conver: PuntConvers);
	{ Inserta de manera ordenada una conversacion en la lista de conversaciones principal }
	begin
		if lista_convers <> nil then begin // Verifica que la lista no este vacia
			if lista_convers^.siguiente <> nil then // Analiza el valor del siguiente puntero
				AgregarConvers(lista_convers^.siguiente, conver) // Y si no es nula la pasa a la siguente
			else begin // Para llegar hasta el final...
				conver^.codigo := lista_convers^.codigo + 1; // Determina el valor del codigo
 				lista_convers^.siguiente := conver;	// Y poder agregar el nodo
			end
		end else
			lista_convers := conver;
	end;

	procedure CargarConversDeArchivo(var archivo_conversaciones: ArchConvers; var archivo_mensajes: ArchMensajes; var lista_convers: PuntConvers; arbol: PuntUsuarios);
	{ Crea la lista de conversaciones a partir de los datos guardados en el archivo }
	var
		nodo: PuntConvers;
		registro_conver: Convers;
	begin
		while (not eof(archivo_conversaciones)) do begin // Verifica no haber llegado al final del archivo
			read(archivo_conversaciones, registro_conver);
			nodo := Archivo_Convers(registro_conver, archivo_mensajes, arbol); // Convierte los datos del archivo a un nodo de conversaciones
			AgregarConvers(lista_convers, nodo); // Y lo inserta en la lista
		end;
	end;

	function Datos_Convers(usuario1, usuario2: PuntUsuarios): PuntConvers;
	{ Funcion que convierte los datos a un nodo de una conversacion }
	var	nodo: PuntConvers;
	begin
		new(nodo);
		nodo^.codigo := 1;
		nodo^.usuario1 := usuario1;
		nodo^.usuario2 := usuario2;
		nodo^.mensajes := nil;
		nodo^.siguiente := nil;
		Datos_Convers := nodo;
	end;

	function CantidadConvers(usuario: string; convers: PuntConvers): integer;
	{ Determina la cantidad de conversaciones en las que esta involucrado un usuario }
	begin
		if convers <> nil then begin // Verifica que la lista no este vacia
	 		if (convers^.usuario1^.nombre = usuario) or (convers^.usuario2^.nombre = usuario) then // Y analiza si el usuario esta en la conversacion
	 			CantidadConvers := 1 + CantidadConvers(usuario, convers^.siguiente)
	 		else
				CantidadConvers := 0 + CantidadConvers(usuario, convers^.siguiente);
		end else
			CantidadConvers := 0;
	end;

	function Conversacion(lista_convers: PuntConvers; usuario1, usuario2: string): PuntConvers;
	{ Busca una conversacion en la lista a partir de su codigo }
	begin
		if lista_convers <> nil then begin
			if ((lista_convers^.usuario1^.nombre = usuario1) and (lista_convers^.usuario2^.nombre = usuario2)) or ((lista_convers^.usuario1^.nombre = usuario2) and (lista_convers^.usuario2^.nombre = usuario1)) then
				Conversacion := lista_convers
			else
				Conversacion := Conversacion(lista_convers^.siguiente, usuario1, usuario2);
		end else
			Conversacion := nil;
	end;

	procedure EliminarConversaciones(var lista_convers: PuntConvers; usuario: string);
	{ Borra toda una lista de conversaciones }
	var a_borrar: PuntConvers;
	begin
		if lista_convers <> nil then begin // Verifica que la lista no este vacia
			if (lista_convers^.usuario1^.nombre = usuario) or (lista_convers^.usuario2^.nombre = usuario) then begin // Detecta si el nodo actual tiene un siguiente...
				a_borrar := lista_convers;
				EliminarMensajes(lista_convers^.mensajes);
				dispose(a_borrar);
			end;
			EliminarConversaciones(lista_convers^.siguiente, usuario);
		end;
	end;

	function Convers_Archivo(nodo_convers: PuntConvers): Convers;
	{ Crea un registro del archivo a partir de un nodo de convers }
	var registro: Convers;
	begin
		registro.usuario1 := nodo_convers^.usuario1^.nombre;
		registro.usuario2 := nodo_convers^.usuario2^.nombre;
		registro.codigo := nodo_convers^.codigo;
		Convers_Archivo := registro;
	end;

	procedure CargarArchivoDeConvers(var archivo_convers: ArchConvers; var archivo_mensajes: ArchMensajes; lista_convers: PuntConvers);
	{ Pasa los datos de la lista Convers al archivo }
	var registro: Convers;
	begin
		if lista_convers <> nil then begin
			registro := Convers_Archivo(lista_convers);
		 	write(archivo_convers, registro);
		 	CargarArchivoDeMensajes(archivo_mensajes, lista_convers^.mensajes);
		 	CargarArchivoDeConvers(archivo_convers, archivo_mensajes, lista_convers^.siguiente);
		end;
	end;

	procedure EliminarListaConvers(var lista_convers: PuntConvers);
	begin
		if lista_convers <> nil then begin // Verifica que la lista no este vacia
			EliminarListaConvers(lista_convers^.siguiente);
			EliminarMensajes(lista_convers^.mensajes);
			dispose(lista_convers);
		end;
	end;
end.