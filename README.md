# WubsConsole

![Console](/images/console.gif)


WubsConsole is a console created for GMS:2.3+
you can use this console to handle custom commands in your games


Basic functions | Description
------------ | -------------
wubsConsoleInit(); | initialize the console
wubsConsoleStep(open_key,close_key); | Runs every step
wubsConsoleDraw(x,y);| Draws the console



Other functions | Description
------------ | -------------
wubsConsoleIsEnabled(); | returns if the console is enabled
wubsConsoleEnable(); | Enable the console
wubsConsoleDisable();| Disable the console
wubsConsoleAddLog(_text); | Adds text to the console's log
wubsConsoleHandleCommand(_command); | The function that handles custom commands

