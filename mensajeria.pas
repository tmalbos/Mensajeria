program Mensajeria;
uses messages, conversaciones, arbol, hiperconectados, graficos, crt, sysutils;

function ExisteArchivo(nombre: string): boolean;
var  arch: text;
begin
	assign(arch, nombre);
	{$I-}
	reset(arch);
	{$I+}
	if IOresult = 0 then begin
		close(arch);
		ExisteArchivo := true
	end	else
		ExisteArchivo := false;
end;

procedure Iniciar(var arb_usuarios: PuntUsuarios; var lista_convers: PuntConvers);
var
	archivo_usuarios: ArchUsuarios;
	archivo_convers: ArchConvers;
	archivo_mensajes: ArchMensajes;
begin
	arb_usuarios := nil; lista_convers := nil; // Inicia los nodos en nil
	assign(archivo_usuarios, 'C:\Program Files\ArchUsuarios.dat'); // Asigna a cada variable cada uno de los archivos correspondientes
	assign(archivo_mensajes, 'C:\Program Files\ArchMensajes.dat');
	assign(archivo_convers, 'C:\Program Files\ArchConversaciones.dat');
	if ExisteArchivo('C:\Program Files\ArchUsuarios.dat') then
		reset(archivo_usuarios)
	else
		rewrite(archivo_usuarios);
	if ExisteArchivo('C:\Program Files\ArchMensajes.dat') then
		reset(archivo_mensajes)
	else
		rewrite(archivo_mensajes);
	if ExisteArchivo('C:\Program Files\ArchConversaciones.dat') then
		reset(archivo_convers) // Los abre
	else
		rewrite(archivo_convers);
	CargarUsuariosDeArchivo(archivo_usuarios, arb_usuarios); // Carga el arbol
	CargarConversDeArchivo(archivo_convers, archivo_mensajes, lista_convers, arb_usuarios); // Carga las conversaciones
	close(archivo_usuarios); close(archivo_convers); close(archivo_mensajes); // Cierra los archivos
end;

procedure LeerMensajes(destinatario: string; lista_mensajes: PuntMensajes);
var cursor: PuntMensajes;
begin
	cursor := lista_mensajes;
	while cursor <> nil do begin
		if cursor^.emisor^.nombre = destinatario then
			cursor^.leido := true;
		cursor := cursor^.siguiente;
	end;
end;

procedure MostrarConversacionesNoLeidas(lista_convers: PuntConvers; usuario: string);
var lista: PuntConvers;
begin
	lista := PantallaEleccionConvers(lista_convers, usuario, 1, true);
	if lista <> nil then
		readln;
end;

procedure MostrarTodasLasConvers(lista_convers: PuntConvers; usuario: string);
var lista: PuntConvers;
begin
	lista := PantallaEleccionConvers(lista_convers, usuario, 1, false);
	if lista <> nil then
		readln;
end;

function EleccionConvers(lista_convers: PuntConvers; usuario: string): PuntConvers;
var
	cursor: PuntConvers;
	posicion, cantidad: integer;
	tecla: char;
begin
	posicion := 1; cantidad := CantidadConvers(usuario, lista_convers);
	cursor := PantallaEleccionConvers(lista_convers, usuario, posicion, false);
	if cursor <> nil then
		repeat
			if KeyPressed() then begin
				tecla := ReadKey;
				if (tecla = k_up) and (posicion > 1) then posicion := posicion - 1;
				if (tecla = k_down) and (posicion < cantidad) then posicion := posicion + 1;
				cursor := PantallaEleccionConvers(lista_convers, usuario, posicion, false);
			end;
		until (tecla = enter) or (tecla = esc);
	EleccionConvers := cursor;
end;

procedure VerUltimosMensajesDeConvers(lista_convers: PuntConvers; usuario: string);
var
	conver: PuntConvers;
	destinatario: string;
	lista_mensajes: PuntMensajes;
	a_mostrar: integer;
begin
	conver := EleccionConvers(lista_convers, usuario);
	if conver <> nil then begin
		destinatario := DeterminarDest(conver, usuario);
		lista_mensajes := conver^.mensajes;
		a_mostrar := PosicionMsjsNoLeidos(lista_mensajes, destinatario);
		if a_mostrar < 10 then
			a_mostrar := 10;
		LeerMensajes(destinatario, lista_mensajes);
		PantallaConvers(usuario, destinatario, lista_mensajes, a_mostrar);
		readln;
	end;
end;

procedure VerConversacion(lista_convers: PuntConvers; usuario: string);
var
	conver: PuntConvers;
	destinatario: string;
	lista_mensajes: PuntMensajes;
begin
	conver := EleccionConvers(lista_convers, usuario);
	if conver <> nil then begin
		destinatario := DeterminarDest(conver, usuario);
		lista_mensajes := conver^.mensajes;
		LeerMensajes(destinatario, lista_mensajes);
		PantallaConvers(usuario, destinatario, lista_mensajes, 255);
		readln;
	end;
end;

procedure ContestarMensaje(usuario: PuntUsuarios; destinatario: string; var lista_mensajes: PuntMensajes);
var registro: Mensajes;
begin
	PantallaConvers(usuario^.nombre, destinatario, lista_mensajes, 5);
	LeerMensajes(destinatario, lista_mensajes);
	readln(registro.mensaje);
	while registro.mensaje <> '' do begin
		registro.fechayhora := DateTimeToStr(Now);
		registro.leido := false;
		AgregarMensaje(lista_mensajes, Datos_Mensajes(registro, usuario));
		PantallaConvers(usuario^.nombre, destinatario, lista_mensajes, 5);
		readln(registro.mensaje);
	end;
end;

function BuscarDestinatario(arbol: PuntUsuarios): string;
var destinatario: string[8];
begin
	PantallaBusqueda(false);
	destinatario := Codificacion(false);
	while Nombre(arbol, destinatario) = nil do begin
		PantallaBusqueda(true);
		destinatario := Codificacion(false);
	end;
	BuscarDestinatario := destinatario;
end;

procedure NuevaConversacion(arbol: PuntUsuarios; var lista_convers: PuntConvers; usuario: string);
var
	destinatario: string[8];
	convers: PuntConvers;
begin
	destinatario := BuscarDestinatario(arbol);
	if Conversacion(lista_convers, usuario, destinatario) = nil then begin
		convers := Datos_Convers(Nombre(arbol, usuario), Nombre(arbol, destinatario));
		AgregarConvers(lista_convers, convers);
		ContestarMensaje(Nombre(arbol, usuario), destinatario, convers^.mensajes);
	end else
		ContestarMensaje(Nombre(arbol, usuario), destinatario, Conversacion(lista_convers, usuario, destinatario)^.mensajes);
end;

procedure BorrarUsuario(var arb_usuarios: PuntUsuarios; var lista_convers: PuntConvers; usuario: string);
begin
	EliminarConversaciones(lista_convers, usuario);
	EliminarUsuario(arb_usuarios, usuario);
end;

procedure Menu2(var arb_usuarios: PuntUsuarios; var lista_convers: PuntConvers; usuario: string);
var
	posicion: integer;
	tecla: char;
	destinatario: string[8];
	convers: PuntConvers;
begin
	posicion := 1;
	PantallaMenu2(posicion);
	repeat
		if KeyPressed() then begin
			tecla := ReadKey;
			if (tecla = k_up) and (posicion > 1) then posicion := posicion - 1;
			if (tecla = k_down) and (posicion < 8) then posicion := posicion + 1;
			if tecla = enter then
				case posicion of
					1: MostrarConversacionesNoLeidas(lista_convers, usuario);
					2: MostrarTodasLasConvers(lista_convers, usuario);
					3: VerUltimosMensajesDeConvers(lista_convers, usuario);
					4: VerConversacion(lista_convers, usuario);
					5: begin
						convers := EleccionConvers(lista_convers, usuario);
						if convers <> nil then begin
							destinatario := DeterminarDest(convers, usuario);
							ContestarMensaje(Nombre(arb_usuarios, usuario), destinatario, convers^.mensajes);
						end;
					end;
					6: NuevaConversacion(arb_usuarios, lista_convers, usuario);
					7: BorrarUsuario(arb_usuarios, lista_convers, usuario);
				end;
			PantallaMenu2(posicion);
		end;
	until ((tecla = enter) and ((posicion = 8) or (posicion = 7))) or (tecla = esc);
end;

procedure CrearNuevoUsuario(var arbol: PuntUsuarios);
var	registro: Usuarios;
begin
	PantallaLogin_Signup(true, 0, '');
	registro.nombre := Codificacion(false);
	if registro.nombre <> 'esc' then begin
		while (registro.nombre <> 'esc') and (Nombre(arbol, registro.nombre) <> nil) do begin
			PantallaLogin_Signup(true, 1, '');
			registro.nombre := Codificacion(false);
		end;
		if registro.nombre <> 'esc' then begin
			PantallaLogin_Signup(false, 0, registro.nombre);
			registro.contra := Codificacion(true);
			if registro.contra <> 'esc' then
				AgregarUsuario(arbol, Datos_Arbol(registro));
		end;
	end;
end;

procedure Ingresar(var arbol: PuntUsuarios; var lista: PuntConvers);
var
	usuario, contra: string;
	nodo_usuario: PuntUsuarios;
begin
	PantallaLogin_Signup(true, 0, '');
	usuario := Codificacion(false);
	if usuario <> 'esc' then begin
		nodo_usuario := Nombre(arbol, usuario);
		while (usuario <> 'esc') and (nodo_usuario = nil) do begin
			PantallaLogin_Signup(true, 2, '');
			usuario := Codificacion(false);
			nodo_usuario := Nombre(arbol, usuario);
		end;
		if usuario <> 'esc' then begin
			PantallaLogin_Signup(false, 0, usuario);
			contra := Codificacion(true);
			while (contra <> 'esc') and (nodo_usuario^.contra <> contra) do begin
				PantallaLogin_Signup(false, 3, usuario);
				contra := Codificacion(true);
			end;
			if contra <> 'esc' then
				Menu2(arbol, lista, usuario);
		end;
	end;
end;

procedure Cerrar(var arb_usuarios: PuntUsuarios; var lista_convers: PuntConvers);
var
	archivo_usuarios: ArchUsuarios;
	archivo_convers: ArchConvers;
	archivo_mensajes: ArchMensajes;
begin
	assign(archivo_usuarios, 'C:\Program Files\ArchUsuarios.dat');
	assign(archivo_mensajes, 'C:\Program Files\ArchMensajes.dat');
	assign(archivo_convers, 'C:\Program Files\ArchConversaciones.dat');
	rewrite(archivo_usuarios); rewrite(archivo_mensajes); rewrite(archivo_convers);
	CargarArchivoDeUsuarios(archivo_usuarios, arb_usuarios);
	CargarArchivoDeConvers(archivo_convers, archivo_mensajes, lista_convers);
	close(archivo_usuarios); close(archivo_convers); close(archivo_mensajes);
	EliminarArbol(arb_usuarios); EliminarListaConvers(lista_convers);
end;

procedure Menu1(var arb_usuarios: PuntUsuarios; var lista_convers: PuntConvers);
var
	posicion: integer;
	tecla: char;
begin
	posicion := 1;
	PantallaMenu1(posicion);
	repeat
		if KeyPressed() then begin
			tecla := ReadKey;
			if (tecla = k_up) and (posicion > 1) then posicion := posicion - 1;
			if (tecla = k_down) and (posicion < 4) then posicion := posicion + 1;
			if tecla = enter then
				case posicion of
					1: CrearNuevoUsuario(arb_usuarios);
					2: Ingresar(arb_usuarios, lista_convers);
					3: VerUsuariosHiperconectados(arb_usuarios, lista_convers);
				end;
			PantallaMenu1(posicion);
		end;
	until ((tecla = enter) and (posicion = 4)) or (tecla = esc);
end;

var
	ArbUsuarios: PuntUsuarios;
	ListaConvers: PuntConvers;

begin
	Iniciar(ArbUsuarios, ListaConvers);
	Menu1(ArbUsuarios, ListaConvers);
	Cerrar(ArbUsuarios, ListaConvers);
end.