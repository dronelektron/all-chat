static bool g_sayTextEnabled = false;

void UserMessage_SetSayText(bool enabled) {
    if (enabled == g_sayTextEnabled) {
        return;
    }

    g_sayTextEnabled = enabled;

    UserMsg id = GetUserMessageId(MESSAGE_SAY_TEXT);

    if (enabled) {
        HookUserMessage(id, UserMessage_OnSayText);
    } else {
        UnhookUserMessage(id, UserMessage_OnSayText);
    }
}

public Action UserMessage_OnSayText(UserMsg id, BfRead buffer, const int[] players, int playersAmount, bool reliable, bool init) {
    int client = buffer.ReadByte();

    if (client != players[0]) {
        return Plugin_Continue;
    }

    if (UseCase_IsConsole(client)) {
        return Plugin_Continue;
    }

    if (UseCase_IsSpectator(client)) {
        SendMessage(client, buffer, TEAM_ONLY_NO);

        return Plugin_Continue;
    }

    if (IsPlayerAlive(client)) {
        return Plugin_Continue;
    }

    SendMessage(client, buffer, TEAM_ONLY_YES);

    return Plugin_Continue;
}

static void SendMessage(int client, BfRead buffer, bool teamOnly) {
    int targets[MAXPLAYERS + 1];
    int targetsAmount = 0;
    int bytes[MESSAGE_SIZE];
    int bytesAmount = 0;

    FillTargetsInGame(targets, targetsAmount);
    FillTargetsOnlyAlive(targets, targetsAmount);

    if (teamOnly) {
        FillTargetsTeamOnly(client, targets, targetsAmount);
    }

    if (targetsAmount == 0) {
        return;
    }

    FillBytes(client, buffer, bytes, bytesAmount);
    Frame_PrintMessage(targets, targetsAmount, bytes, bytesAmount);
}

static void FillTargetsInGame(int[] targets, int& targetsAmount) {
    for (int target = 1; target <= MaxClients; target++) {
        if (IsClientInGame(target)) {
            targets[targetsAmount++] = target;
        }
    }
}

static void FillTargetsOnlyAlive(int[] targets, int& targetsAmount) {
    int freeIndex = 0;

    for (int i = 0; i < targetsAmount; i++) {
        int target = targets[i];

        if (IsPlayerAlive(target)) {
            targets[freeIndex++] = target;
        }
    }

    targetsAmount = freeIndex;
}

static void FillTargetsTeamOnly(int client, int[] targets, int& targetsAmount) {
    int clientTeam = GetClientTeam(client);
    int freeIndex = 0;

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
