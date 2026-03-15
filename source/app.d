import clayd;
import core.stdc.stdlib : malloc, free;
import std.stdio;

extern(C) void handleError(Clay_ErrorData data)
{
    if (data.errorText.chars && data.errorText.length > 0) {
        writeln("error: ", data.errorText.length, " chars");
    }
}

extern(C) Clay_Dimensions measureText(Clay_StringSlice text, Clay_TextElementConfig* config, void* userData)
{
    Clay_Dimensions d;
    ushort fontSize = (config !is null) ? config.fontSize : 16;
    d.width = text.length * fontSize;
    d.height = fontSize;
    return d;
}

// no renderer hooked up - just here to test layout engine functionality
void main()
{
    uint size = clayMinMemorySize();
    void* mem = malloc(size);
    if (!mem) return;
    scope (exit) free(mem);

    Clay_Arena arena = clayCreateArenaWithCapacityAndMemory(size, mem);
    Clay_Dimensions dims = { 800, 600 };
    Clay_ErrorHandler err;
    err.errorHandlerFunction = &handleError;
    err.userData = null;
    clayInitialize(arena, dims, err);
    claySetMeasureTextFunction(&measureText, null);

    claySetLayoutDimensions(dims);
    Clay_Vector2 ptr;
    ptr.x = 100; ptr.y = 100;
    claySetPointerState(ptr, false);
    clayBeginLayout();

    Clay_ElementDeclaration rootDecl = clayElementDeclaration();
    rootDecl.layout.sizing.width = claySizingGrow();
    rootDecl.layout.sizing.height = claySizingGrow();
    rootDecl.layout.padding = clayPaddingAll(16);
    rootDecl.layout.childGap = 16;
    rootDecl.backgroundColor = clayColor(250, 250, 255);

    clayElementScope(clayId("Root"), rootDecl, {
        Clay_ElementDeclaration sideDecl = clayElementDeclaration();
        sideDecl.layout.layoutDirection = Clay_LayoutDirection.topToBottom;
        sideDecl.layout.sizing.width = claySizingFixed(200);
        sideDecl.layout.sizing.height = claySizingGrow();
        sideDecl.layout.padding = clayPaddingAll(16);
        sideDecl.backgroundColor = clayColor(224, 215, 210);
        clayElementScope(clayId("Sidebar"), sideDecl, {
            Clay_TextElementConfig textCfg;
            textCfg.fontSize = 24;
            textCfg.textColor = clayColor(0, 0, 0);
            clayText(clayString("ClayD"), *clayTextConfig(textCfg));
        });
    });

    Clay_RenderCommandArray commands = clayEndLayout();
    writeln("clay's layout engine produced ", commands.length, " render commands");
}
