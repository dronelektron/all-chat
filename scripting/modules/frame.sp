void Frame_PrintMessage(const int[] targets, int targetsAmount, const int[] bytes, int bytesAmount) {
    DataPack data = new DataPack();

    data.WriteCell(targetsAmount);
    data.WriteCellArray(targets, targetsAmount);
    data.WriteCell(bytesAmount);
    data.WriteCellArray(bytes, bytesAmount);
    data.Reset();

    RequestFrame(OnPrintMessage, data);
}

static void OnPrintMessage(DataPack data) {
    int targetsAmount = data.ReadCell();
    int targets[MAXPLAYERS + 1];

    data.ReadCellArray(targets, targetsAmount);

    int bytesAmount = data.ReadCell();
    int bytes[MESSAGE_SIZE];

    data.ReadCellArray(bytes, bytesAmount);

    CloseHandle(data);
    UserMessage_SayText(targets, targetsAmount, bytes, bytesAmount);
}
