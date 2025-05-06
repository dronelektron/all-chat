static ConVar g_pluginEnabled;

void Variable_Create() {
    g_pluginEnabled = CreateConVar("sm_allchat", "1", "Enable (1) or disable (0) the plugin");
    g_pluginEnabled.AddChangeHook(OnPluginEnabled);
}

static void OnPluginEnabled(ConVar variable, const char[] oldValue, const char[] newValue) {
    bool enabled = variable.BoolValue;

    UserMessage_SayText_Toggle(enabled);
}
