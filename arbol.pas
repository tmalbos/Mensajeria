unit arbol;

interface
	type
		// Estructuras relacionadas al arbol 'Usuarios'
		PuntUsuarios = ^NodoUsuarios;
		NodoUsuarios = record
			nombre: string[8];
			contra: string[8];
			menor: PuntUsuarios;
			mayor: PuntUsuarios;
		end;
		Usuarios = record
			nombre: string[8];
			contra: string[8];
		end;
		ArchUsuarios = file of Usuarios;

	// Funciones relacionadas con el arbol 'Usuarios'
	function Datos_Arbol(registro: Usuarios): PuntUsuarios;
	procedure AgregarUsuario(var arbol: PuntUsuarios; nodo_arbol: PuntUsuarios);
	procedure CargarUsuariosDeArchivo(var archivo: ArchUsuarios; var arbol: PuntUsuarios);

	function Nombre(arbol: PuntUsuarios; usuario: string): PuntUsuarios;
	function Padre(nodo, anterior: PuntUsuarios): PuntUsuarios;
    procedure EliminarUsuario(var arbol: PuntUsuarios; nombre_eliminar: string);

	procedure CargarArchivoDeUsuarios(var archivo: ArchUsuarios; arbol: PuntUsuarios);
	procedure EliminarArbol(var arb_usuarios: PuntUsuarios);

implementation
	function Datos_Arbol(registro: Usuarios): PuntUsuarios;
	{ Crea un puntero a un nodo para el arbol a partir de un registro del archivo }
	var nodo_arbol: PuntUsuarios;
	begin
		new(nodo_arbol);
		nodo_arbol^.nombre := registro.nombre;
		nodo_arbol^.contra := registro.contra;
		nodo_arbol^.menor := nil;
		nodo_arbol^.mayor := nil;
		Datos_Arbol := nodo_arbol;
	end;

	procedure AgregarUsuario(var arbol: PuntUsuarios; nodo_arbol: PuntUsuarios);
	{ Agrega un nuevo usuario }
	begin
		if arbol <> nil then begin // Verifica que el arbol no sea nulo
		 	if nodo_arbol^.nombre < arbol^.nombre then // Recorre el mismo recursivamente...
		 		AgregarUsuario(arbol^.menor, nodo_arbol)
		 	else
		 		AgregarUsuario(arbol^.mayor, nodo_arbol);
		end else // ... hasta encontrar un nodo con algun puntero a vacio donde se pueda insertar
			arbol := nodo_arbol;
	end;

	procedure CargarUsuariosDeArchivo(var archivo: ArchUsuarios; var arbol: PuntUsuarios);
	{ Agrega al arbol todos los datos del archivo }

	var registro: Usuarios;
	begin
		seek(archivo, 0); // Coloca el cursor en el incio del archivo
		while not eof(archivo) do begin // Y lo recorre hasta el final
		 	read(archivo, registro); // Leyendo...
		 	AgregarUsuario(arbol, Datos_Arbol(registro)); // ... y agregando esos datos al arbol
		end;
	end;

	function Nombre(arbol: PuntUsuarios; usuario: string): PuntUsuarios;
	{ Busca un nombre dentro del arbol y devuelve el puntero que apunta al nodo donde se encuentra ese nombre }
	begin
		if arbol <> nil then begin // Analiza que el arbol no sea nulo
			if usuario < arbol^.nombre then // Verifica que el nombre a buscar sea menor al nombre del arbol
				Nombre := Nombre(arbol^.menor, usuario)
			else if usuario > arbol^.nombre then // O que sea mayor...
				Nombre := Nombre(arbol^.mayor, usuario)
			else // Analiza si estos valores son iguales (fin de la recursion)
				Nombre := arbol;
		end	else // Si fuera nulo significaria que el nombre no se encuentra dentro del arbol
			Nombre := nil;
	end;

	function Padre(nodo, anterior: PuntUsuarios): PuntUsuarios;
	{ Busca el padre de un nodo a traves del puntero que apunta al hijo }
	begin
		if (nodo <> nil) and (anterior <> nil) and (nodo <> anterior) then begin // Verifica que nodo y anterior no sean nulos o iguales
			if (anterior <> nodo^.menor) and (anterior <> nodo^.mayor) then begin // Analiza si alguna de las dos ramas del nodo son iguales a nuestro puntero a buscar
				if anterior^.nombre < nodo^.nombre then // Itera recursivamente a traves del arbol
					Padre := Padre(nodo^.menor, anterior)
				else Padre := Padre(nodo^.mayor, anterior);
			end	else // Determina quien es el padre
				Padre := nodo;
		end else // Si no se encuentra ningun nombre en el arbol o estamos buscando el padre de la raiz, entonces el resultado obtenido es un puntero nulo
			Padre := nil;
	end;

	procedure BorradoSimple(var arbol, usuario: PuntUsuarios);
	{ Elimina un nodo de un arbol con 1 o ningun descendiente }
	var nodoPadre, punt_intercambio: PuntUsuarios;
	begin
		nodoPadre := Padre(arbol, usuario); // Busca el padre del usuario a eliminar
		if usuario^.mayor = nil then // Analiza de que lado, el nodo nombre, tiene un hijo
			punt_intercambio := usuario^.menor
		else // Notese que el nodo usuario puede ser una hoja, pero se tiene esto en cuenta para poder generalizar
			punt_intercambio := usuario^.mayor;
		usuario^.menor := nil; // Limpia el posible hijo del nodo usuario
		usuario^.mayor := nil;

		if nodoPadre <> nil then begin // Verifica que el nodo padre no sea nulo (estariamos hablando de la raiz o de un elemento que no se encuentra en el arbol)
			if nodoPadre^.menor = usuario then // Descubre a que lado se debe realizar la conexion entre el padre del nodo a eliminar, y su posible hijo
				nodoPadre^.menor := punt_intercambio
			else
				nodoPadre^.mayor := punt_intercambio;
		end	else if arbol = usuario then
			arbol := punt_intercambio; // En el caso de que se quiera eliminar la raiz...
		dispose(usuario); // Toques finales
	end;

	function Maximal(usuario: PuntUsuarios): string;
	{ Busca el nombre mas 'grande' dentro de un subconjunto del arbol }
	begin
		if usuario^.mayor <> nil then // Itera recursivamente hacia los valores mayores...
			Maximal := Maximal(usuario^.mayor)
		else // Hasta que encuentra un nodo que no tiene valores mayores
			Maximal := usuario^.nombre;
	end;

	procedure EliminarUsuario(var arbol: PuntUsuarios; nombre_eliminar: string);
	{ Elimina un nodo que contiene el nombre del usuario a eliminar }
	var
		usuario, nuevo_nombre: PuntUsuarios;
		a_intercambiar: string[8];
	begin
		if arbol <> nil then begin // Corrobora que el arbol no este vacio
			usuario := Nombre(arbol, nombre_eliminar); // Busca el nombre a borrar en el arbol...
			if usuario <> nil then begin // ...y verifica que este en el mismo
				if (usuario^.mayor = nil) or (usuario^.menor = nil) then // Cuando el nodo a eliminar no tiene descendencia o tiene solo una
					BorradoSimple(arbol, usuario)
				else begin // O cuando el nodo a eliminar tiene dos hijos
					a_intercambiar := Maximal(usuario^.menor); // Busca el mayor de los menores
					nuevo_nombre := Nombre(arbol, a_intercambiar); // Busca el puntero donde esta almacenado este maximal
					usuario^.nombre := a_intercambiar; // Cambia el valor del nodo a eliminar por el del maximo
					BorradoSimple(arbol, nuevo_nombre); // Y borra el nodo que contiene al maximo
				end;
			end;
		end;
	end;

	function Arbol_Archivo(nodo_arbol: PuntUsuarios): Usuarios;
	{ Crea un registro que va en ArchUsuarios a partir de un nodo del arbol }
	var registro: Usuarios;
	begin
		registro.nombre := nodo_arbol^.nombre;
		registro.contra := nodo_arbol^.contra;
		Arbol_Archivo := registro;
	end;

	procedure CargarArchivoDeUsuarios(var archivo: ArchUsuarios; arbol:PuntUsuarios);
	{ Carga el archivo con los datos del arbol en pre order }
	begin
		if arbol <> nil then begin // Mientras que el nodo no sea nulo
		 	write(archivo, Arbol_Archivo(arbol)); // Escribe en el archivo los datos del mismo
		 	CargarArchivoDeUsuarios(archivo, arbol^.menor); // Y recorre todo el arbol
		 	CargarArchivoDeUsuarios(archivo, arbol^.mayor);
		end;
	end;

	procedure EliminarArbol(var arb_usuarios: PuntUsuarios);
	begin
		if arb_usuarios <> nil then begin
			EliminarArbol(arb_usuarios^.mayor);
			EliminarArbol(arb_usuarios^.menor);
			dispose(arb_usuarios);
		end;
	end;
end.