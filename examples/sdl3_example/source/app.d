import clayd;
import core.stdc.stdlib : malloc, free;
import core.stdc.stdio : printf;
import bindbc.sdl;

extern (C) void handleError(Clay_ErrorData data)
{
    if (data.errorText.chars && data.errorText.length > 0)
    {
        printf("error: %d chard\n", data.errorText.length);
    }
}

extern (C) Clay_Dimensions measureText(Clay_StringSlice text, Clay_TextElementConfig* config, void* userData)
{
    Clay_Dimensions d;
    ushort fontSize = (config !is null) ? config.fontSize : 16;
    d.width = text.length * fontSize;
    d.height = fontSize;
    return d;
}

extern (C) void main()
{
    uint size = clayMinMemorySize();
    void* mem = malloc(size);
    if (!mem)
        return;
    scope (exit)
        free(mem);

    Clay_Arena arena = clayCreateArenaWithCapacityAndMemory(size, mem);
    Clay_Dimensions dims = {800, 600};
    Clay_ErrorHandler err;
    err.errorHandlerFunction = &handleError;
    err.userData = null;
    clayInitialize(arena, dims, err);
    claySetMeasureTextFunction(&measureText, null);

    claySetLayoutDimensions(dims);
    Clay_Vector2 ptr;
    ptr.x = 100;
    ptr.y = 100;
    claySetPointerState(ptr, false);
    clayBeginLayout();

    Clay_ElementDeclaration rootDecl = clayElementDeclaration();
    rootDecl.layout.sizing.width = claySizingGrow();
    rootDecl.layout.sizing.height = claySizingGrow();
    // rootDecl.layout.padding = clayPaddingAll(16);
    rootDecl.layout.childGap = 16;
    rootDecl.backgroundColor = clayColor(28, 24, 20);

    clayElementScope(clayId("Root"), rootDecl, {
        Clay_ElementDeclaration sideDecl = clayElementDeclaration();
        sideDecl.layout.layoutDirection = Clay_LayoutDirection.topToBottom;
        sideDecl.layout.sizing.width = claySizingFixed(200);
        sideDecl.layout.sizing.height = claySizingGrow();
        sideDecl.layout.padding = clayPaddingAll(16);
        sideDecl.backgroundColor = clayColor(56, 27, 52);
        clayElementScope(clayId("Sidebar"), sideDecl, {
            Clay_TextElementConfig textCfg;
            textCfg.fontSize = 24;
            textCfg.textColor = clayColor(255, 255, 255);
            clayText(clayString("ClayD"), *clayTextConfig(textCfg));
        });
    });

    Clay_RenderCommandArray commands = clayEndLayout();
    printf("clay's layout engine produced %d render commands\n", commands.length);

    SDL_Init(SDL_INIT_VIDEO);
    TTF_Init();

    auto window = SDL_CreateWindow("sdl3_renderer", 1024, 768, SDL_WINDOW_RESIZABLE);
    auto renderer = SDL_CreateRenderer(window, null);
    auto fonts = TTF_OpenFont("Arial Unicode.ttf", 20);
    auto textEngine = TTF_CreateRendererTextEngine(renderer);

    SDL_SetEventEnabled(SDL_EVENT_DROP_FILE, true);
    auto clay_renderer = Clay_SDL3RendererData(renderer, textEngine, &fonts);
    bool running = true;
    SDL_Event event;

    while (running)
    {
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_EVENT_QUIT)
            {
                running = false;
            }
        }

        SDL_RenderClear(renderer);
        SDL_Clay_RenderClayCommands(&clay_renderer, commands);

        SDL_RenderPresent(renderer);
    }
}
