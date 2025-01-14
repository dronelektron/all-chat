#include <sourcemod>

#include "all-chat/use-case"
#include "all-chat/user-message"

#include "modules/console-variable.sp"
#include "modules/frame.sp"
#include "modules/use-case.sp"
#include "modules/user-message.sp"

public Plugin myinfo = {
    name = "All chat",
    author = "Dron-elektron",
    description = "Allows you to see messages from dead players and spectators",
    version = "0.1.0",
    url = "https://github.com/dronelektron/all-chat"
};

public void OnPluginStart() {
    Variable_Create();
    UserMessage_SetSayText(ENABLED_YES);
    AutoExecConfig(_, "all-chat");
}
