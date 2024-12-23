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
        SendMessageFromSpectator(client, buffer);

        return Plugin_Continue;
    }

    if (IsPlayerAlive(client)) {
        return Plugin_Continue;
    }
    // TODO
    PrintToServer("[DEBUG] Dead: %d", client);

    return Plugin_Continue;
}

static void SendMessageFromSpectator(int client, BfRead buffer) {
    int targets[MAXPLAYERS + 1];
    int targetsAmount = 0;
    int bytes[MESSAGE_SIZE];
    int bytesAmount = 0;

    FillTargets(targets, targetsAmount);

    if (targetsAmount == 0) {
        return;
    }

    FillBytes(client, buffer, bytes, bytesAmount);
    Frame_PrintMessage(targets, targetsAmount, bytes, bytesAmount);
}

static void FillTargets(int[] targets, int& targetsAmount) {
    for (int target = 1; target <= MaxClients; target++) {
        if (IsClientInGame(target) && IsPlayerAlive(target)) {
            targets[targetsAmount++] = target;
        }
    }
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
