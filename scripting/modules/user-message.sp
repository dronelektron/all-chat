static bool g_sayTextEnabled = false;
static bool g_isTeamChat = false;

void UserMessage_SetTeamChat(bool isTeamChat) {
    g_isTeamChat = isTeamChat;
}

void UserMessage_SayText_Toggle(bool enabled) {
    if (enabled == g_sayTextEnabled) {
        return;
    }

    g_sayTextEnabled = enabled;

    UserMsg id = GetUserMessageId(MESSAGE_SAY_TEXT);

    if (enabled) {
        HookUserMessage(id, OnSayText);
    } else {
        UnhookUserMessage(id, OnSayText);
    }
}

static Action OnSayText(UserMsg id, BfRead buffer, const int[] players, int playersAmount, bool reliable, bool init) {
    int client = buffer.ReadByte();

    if (IsRecipient(client, players) || IsConsole(client) || IsPlayerAlive(client)) {
        return Plugin_Continue;
    }

    if (IsSpectator(client)) {
        SendMessage(client, buffer, TEAM_CHAT_NO);
    } else {
        SendMessage(client, buffer, g_isTeamChat);
    }

    return Plugin_Continue;
}

static bool IsRecipient(int client, const int[] players) {
    return client != players[0];
}

static bool IsConsole(int client) {
    return client == CONSOLE;
}

static bool IsSpectator(int client) {
    int team = GetClientTeam(client);

    return team < TEAM_ALLIES;
}

static void SendMessage(int client, BfRead buffer, bool teamChat) {
    int targets[MAXPLAYERS + 1];
    int targetsAmount = 0;

    FillAllTargets(targets, targetsAmount);
    FillAliveTargets(targets, targetsAmount);

    if (teamChat) {
        FillTeamTargets(client, targets, targetsAmount);
    }

    if (targetsAmount == 0) {
        return;
    }

    int bytes[MESSAGE_SIZE];
    int bytesAmount = 0;

    FillBytes(client, buffer, bytes, bytesAmount);
    Frame_PrintMessage(targets, targetsAmount, bytes, bytesAmount);
}

static void FillAllTargets(int[] targets, int& targetsAmount) {
    targetsAmount = 0;

    for (int target = 1; target <= MaxClients; target++) {
        targets[targetsAmount++] = target;
    }
}

static void FillAliveTargets(int[] targets, int& targetsAmount) {
    int freeIndex = 0;

    for (int i = 0; i < targetsAmount; i++) {
        int target = targets[i];

        if (IsClientInGame(target) && IsPlayerAlive(target)) {
            targets[freeIndex++] = target;
        }
    }

    targetsAmount = freeIndex;
}

static void FillTeamTargets(int client, int[] targets, int& targetsAmount) {
    int freeIndex = 0;
    int clientTeam = GetClientTeam(client);

    for (int i = 0; i < targetsAmount; i++) {
        int target = targets[i];
        int targetTeam = GetClientTeam(target);

        if (clientTeam == targetTeam) {
            targets[freeIndex++] = target;
        }
    }

    targetsAmount = freeIndex;
}

static void FillBytes(int client, BfRead buffer, int[] bytes, int& bytesAmount) {
    bytes[0] = client;
    bytesAmount = 1;

    while (buffer.BytesLeft > 0) {
        bytes[bytesAmount++] = buffer.ReadByte();
    }
}

void UserMessage_SayText(const int[] targets, int targetsAmount, const int[] bytes, int bytesAmount) {
    Handle buffer = StartMessage(MESSAGE_SAY_TEXT, targets, targetsAmount);

    for (int i = 0; i < bytesAmount; i++) {
        BfWriteByte(buffer, bytes[i]);
    }

    EndMessage();
}
