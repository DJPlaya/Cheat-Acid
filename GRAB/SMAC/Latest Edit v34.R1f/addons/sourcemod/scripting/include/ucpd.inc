
forward Action:UCP_OnClientAuthenticated(client);			// ���������� ����� ������������ �������
native bool:UCP_IsClientAuthenticated(client);				// ���������� true ���� ������ ��������������� ���������, ���� false - �� ��������� �������� ���� ����� false, �� ����� ����� ��� ������������
native bool:UCP_IsClientUCP(client);							// ���������� true ���� ������ ����� UCP, ���� false ����� �� �����.
native bool:UCP_GetClientVersion(client, String:ucpver[]);	// ���������� �� ������ ��������� ������ UCP ������� �������� (����. "8.1"). ��� ������ ����� ����������� 4.
native 		UCP_GetClientBulid(client);						// ���������� ���� ������� int-��, � ������ ������� ������ 0.
native bool:UCP_GetClientWindows(client, String:winid[]);	// ���������� true ����� ������ � UCP � ��� ������ ����� ��������� � �������, ��������� �� ������ ���������. ��� ������ ����� ����������� 16.
native bool:UCP_GetClientUCPID(client,String:ucpid[]);		// ���������� true ����� ������ � UCP � ��� UCPID ��������� � �������, ��������� �� ������ ���������. ��� ������ ����� ����������� 9.