static ConVar g_spectators;

void Variable_Create() {
    g_spectators = CreateConVar("sm_allchat_spectators", "1", "Enable (1) or disable (0) spectators chat");
    g_spectators.AddChangeHook(OnSpectatorsChanged);
}

static void OnSpectatorsChanged(ConVar variable, const char[] oldValue, const char[] newValue) {
    bool enabled = variable.BoolValue;

    UserMessage_SetSayText(enabled);
}
