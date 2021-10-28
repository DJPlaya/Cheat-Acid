
forward Action:UCP_OnClientAuthenticated(client);			// Вызывается после аунтефикации клиента
native bool:UCP_IsClientAuthenticated(client);				// Возвращает true если клиент авторизировался полностью, если false - всё остальные проверки тоже будут false, по этому лучше его использовать
native bool:UCP_IsClientUCP(client);							// Возвращает true если клиент имеет UCP, либо false когда не имеет.
native bool:UCP_GetClientVersion(client, String:ucpver[]);	// Возвращает во втором аргументе версию UCP клиента строчкой (напр. "8.1"). Она должна иметь размерность 4.
native 		UCP_GetClientBulid(client);						// Возвращает билд клиента int-ом, в случае неудачи выдает 0.
native bool:UCP_GetClientWindows(client, String:winid[]);	// Возвращает true когда клиент с UCP и его индекс винды записался в строчку, указанной во втором параметре. Она должна иметь размерность 16.
native bool:UCP_GetClientUCPID(client,String:ucpid[]);		// Возвращает true когда клиент с UCP и его UCPID записался в строчку, указанной во втором параметре. Она должна иметь размерность 9.