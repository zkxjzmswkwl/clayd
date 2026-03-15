module clayd;

// clay bindings - clay is authored by Nic Barker and can be found at https://github.com/nicbarker/clay
// need to link w/ C obj that defines CLAY_IMPLEMENTATION and includes clay's header.

struct Clay_Context;

struct Clay_String
{
    bool isStaticallyAllocated;
    int length;
    const(char)* chars;
}

struct Clay_StringSlice
{
    int length;
    const(char)* chars;
    const(char)* baseChars;
}

struct Clay_Arena
{
    size_t nextAllocation;
    size_t capacity;
    char* memory;
}

struct Clay_Dimensions { float width, height; }
struct Clay_Vector2 { float x, y; }
struct Clay_BoundingBox { float x, y, width, height; }

struct Clay_Color
{
    float r, g, b, a;
}

struct Clay_ElementId
{
    uint id;
    uint offset;
    uint baseId;
    Clay_String stringId;
}

struct Clay_ElementIdArray
{
    int capacity;
    int length;
    Clay_ElementId* internalArray;
}

struct Clay_CornerRadius
{
    float topLeft, topRight, bottomLeft, bottomRight;
}

enum Clay_LayoutDirection : ubyte
{
    leftToRight,
    topToBottom,
}

enum Clay_LayoutAlignmentX : ubyte
{
    alignXLeft,
    alignXRight,
    alignXCenter,
}

enum Clay_LayoutAlignmentY : ubyte
{
    alignYTop,
    alignYBottom,
    alignYCenter,
}

enum Clay_SizingType : ubyte
{
    sizingTypeFit,
    sizingTypeGrow,
    sizingTypePercent,
    sizingTypeFixed,
}

struct Clay_ChildAlignment
{
    Clay_LayoutAlignmentX x;
    Clay_LayoutAlignmentY y;
}

struct Clay_SizingMinMax
{
    float min;
    float max;
}

union Clay_SizingAxisSize
{
    Clay_SizingMinMax minMax;
    float percent;
}
struct Clay_SizingAxis
{
    Clay_SizingAxisSize size;
    Clay_SizingType type;
}

struct Clay_Sizing
{
    Clay_SizingAxis width;
    Clay_SizingAxis height;
}

struct Clay_Padding
{
    ushort left, right, top, bottom;
}

struct Clay_LayoutConfig
{
    Clay_Sizing sizing;
    Clay_Padding padding;
    ushort childGap;
    Clay_ChildAlignment childAlignment;
    Clay_LayoutDirection layoutDirection;
}

enum Clay_TextElementConfigWrapMode : ubyte
{
    textWrapWords,
    textWrapNewlines,
    textWrapNone,
}

enum Clay_TextAlignment : ubyte
{
    textAlignLeft,
    textAlignCenter,
    textAlignRight,
}

struct Clay_TextElementConfig
{
    void* userData;
    Clay_Color textColor;
    ushort fontId;
    ushort fontSize;
    ushort letterSpacing;
    ushort lineHeight;
    Clay_TextElementConfigWrapMode wrapMode;
    Clay_TextAlignment textAlignment;
}

struct Clay_AspectRatioElementConfig
{
    float aspectRatio;
}

struct Clay_ImageElementConfig
{
    void* imageData;
}

enum Clay_FloatingAttachPointType : ubyte
{
    attachPointLeftTop,
    attachPointLeftCenter,
    attachPointLeftBottom,
    attachPointCenterTop,
    attachPointCenterCenter,
    attachPointCenterBottom,
    attachPointRightTop,
    attachPointRightCenter,
    attachPointRightBottom,
}

struct Clay_FloatingAttachPoints
{
    Clay_FloatingAttachPointType element;
    Clay_FloatingAttachPointType parent;
}

enum Clay_PointerCaptureMode : ubyte
{
    pointerCaptureModeCapture,
    pointerCaptureModePassthrough,
}

enum Clay_FloatingAttachToElement : ubyte
{
    attachToNone,
    attachToParent,
    attachToElementWithId,
    attachToRoot,
}

enum Clay_FloatingClipToElement : ubyte
{
    clipToNone,
    clipToAttachedParent,
}

struct Clay_FloatingElementConfig
{
    Clay_Vector2 offset;
    Clay_Dimensions expand;
    uint parentId;
    short zIndex;
    Clay_FloatingAttachPoints attachPoints;
    Clay_PointerCaptureMode pointerCaptureMode;
    Clay_FloatingAttachToElement attachTo;
    Clay_FloatingClipToElement clipTo;
}

struct Clay_CustomElementConfig
{
    void* customData;
}

struct Clay_ClipElementConfig
{
    bool horizontal;
    bool vertical;
    Clay_Vector2 childOffset;
}

struct Clay_BorderWidth
{
    ushort left, right, top, bottom, betweenChildren;
}

struct Clay_BorderElementConfig
{
    Clay_Color color;
    Clay_BorderWidth width;
}

struct Clay_TextRenderData
{
    Clay_StringSlice stringContents;
    Clay_Color textColor;
    ushort fontId, fontSize, letterSpacing, lineHeight;
}

struct Clay_RectangleRenderData
{
    Clay_Color backgroundColor;
    Clay_CornerRadius cornerRadius;
}

struct Clay_ImageRenderData
{
    Clay_Color backgroundColor;
    Clay_CornerRadius cornerRadius;
    void* imageData;
}

struct Clay_CustomRenderData
{
    Clay_Color backgroundColor;
    Clay_CornerRadius cornerRadius;
    void* customData;
}

struct Clay_ClipRenderData
{
    bool horizontal;
    bool vertical;
}

struct Clay_BorderRenderData
{
    Clay_Color color;
    Clay_CornerRadius cornerRadius;
    Clay_BorderWidth width;
}

union Clay_RenderData
{
    Clay_RectangleRenderData rectangle;
    Clay_TextRenderData text;
    Clay_ImageRenderData image;
    Clay_CustomRenderData custom;
    Clay_BorderRenderData border;
    Clay_ClipRenderData clip;
}

enum Clay_RenderCommandType : ubyte
{
    renderCommandTypeNone,
    renderCommandTypeRectangle,
    renderCommandTypeBorder,
    renderCommandTypeText,
    renderCommandTypeImage,
    renderCommandTypeScissorStart,
    renderCommandTypeScissorEnd,
    renderCommandTypeCustom,
}

struct Clay_RenderCommand
{
    Clay_BoundingBox boundingBox;
    Clay_RenderData renderData;
    void* userData;
    uint id;
    short zIndex;
    Clay_RenderCommandType commandType;
}

struct Clay_RenderCommandArray
{
    int capacity;
    int length;
    Clay_RenderCommand* internalArray;
}

struct Clay_ScrollContainerData
{
    Clay_Vector2* scrollPosition;
    Clay_Dimensions scrollContainerDimensions;
    Clay_Dimensions contentDimensions;
    Clay_ClipElementConfig config;
    bool found;
}

struct Clay_ElementData
{
    Clay_BoundingBox boundingBox;
    bool found;
}

enum Clay_PointerDataInteractionState : ubyte
{
    pointerDataPressedThisFrame,
    pointerDataPressed,
    pointerDataReleasedThisFrame,
    pointerDataReleased,
}

struct Clay_PointerData
{
    Clay_Vector2 position;
    Clay_PointerDataInteractionState state;
}

struct Clay_ElementDeclaration
{
    Clay_LayoutConfig layout;
    Clay_Color backgroundColor;
    Clay_CornerRadius cornerRadius;
    Clay_AspectRatioElementConfig aspectRatio;
    Clay_ImageElementConfig image;
    Clay_FloatingElementConfig floating;
    Clay_CustomElementConfig custom;
    Clay_ClipElementConfig clip;
    Clay_BorderElementConfig border;
    void* userData;
}

enum Clay_ErrorType : ubyte
{
    errorTypeTextMeasurementFunctionNotProvided,
    errorTypeArenaCapacityExceeded,
    errorTypeElementsCapacityExceeded,
    errorTypeTextMeasurementCapacityExceeded,
    errorTypeDuplicateId,
    errorTypeFloatingContainerParentNotFound,
    errorTypePercentageOver1,
    errorTypeInternalError,
    errorTypeUnbalancedOpenClose,
}

struct Clay_ErrorData
{
    Clay_ErrorType errorType;
    Clay_String errorText;
    void* userData;
}

alias Clay_ErrorHandlerFn = extern(C) void function(Clay_ErrorData);

struct Clay_ErrorHandler
{
    Clay_ErrorHandlerFn errorHandlerFunction;
    void* userData;
}
alias Clay_OnHoverFn = extern(C) void function(Clay_ElementId, Clay_PointerData, void*);
alias Clay_MeasureTextFn = extern(C) Clay_Dimensions function(Clay_StringSlice, Clay_TextElementConfig*, void*);
alias Clay_QueryScrollOffsetFn = extern(C) Clay_Vector2 function(uint, void*);

private extern(C) @system nothrow @nogc
{
    uint Clay_MinMemorySize();
    Clay_Arena Clay_CreateArenaWithCapacityAndMemory(size_t capacity, void* memory);
    void Clay_SetPointerState(Clay_Vector2 position, bool pointerDown);
    Clay_Context* Clay_Initialize(Clay_Arena arena, Clay_Dimensions layoutDimensions, Clay_ErrorHandler errorHandler);
    Clay_Context* Clay_GetCurrentContext();
    void Clay_SetCurrentContext(Clay_Context* context);
    void Clay_UpdateScrollContainers(bool enableDragScrolling, Clay_Vector2 scrollDelta, float deltaTime);
    Clay_Vector2 Clay_GetScrollOffset();
    void Clay_SetLayoutDimensions(Clay_Dimensions dimensions);
    void Clay_BeginLayout();
    Clay_RenderCommandArray Clay_EndLayout();
    Clay_ElementId Clay_GetElementId(Clay_String idString);
    Clay_ElementId Clay_GetElementIdWithIndex(Clay_String idString, uint index);
    Clay_ElementData Clay_GetElementData(Clay_ElementId id);
    bool Clay_Hovered();
    void Clay_OnHover(Clay_OnHoverFn onHoverFunction, void* userData);
    bool Clay_PointerOver(Clay_ElementId elementId);
    Clay_ElementIdArray Clay_GetPointerOverIds();
    Clay_PointerData Clay_GetPointerData();
    Clay_ScrollContainerData Clay_GetScrollContainerData(Clay_ElementId id);
    void Clay_SetMeasureTextFunction(Clay_MeasureTextFn measureTextFunction, void* userData);
    void Clay_SetQueryScrollOffsetFunction(Clay_QueryScrollOffsetFn queryScrollOffsetFunction, void* userData);
    Clay_RenderCommand* Clay_RenderCommandArray_Get(Clay_RenderCommandArray* array, int index);
    void Clay_SetDebugModeEnabled(bool enabled);
    bool Clay_IsDebugModeEnabled();
    void Clay_SetCullingEnabled(bool enabled);
    int Clay_GetMaxElementCount();
    void Clay_SetMaxElementCount(int maxElementCount);
    int Clay_GetMaxMeasureTextCacheWordCount();
    void Clay_SetMaxMeasureTextCacheWordCount(int maxMeasureTextCacheWordCount);
    void Clay_ResetMeasureTextCache();
    void Clay__OpenElement();
    void Clay__OpenElementWithId(Clay_ElementId elementId);
    void Clay__ConfigureOpenElement(const Clay_ElementDeclaration config);
    void Clay__ConfigureOpenElementPtr(const Clay_ElementDeclaration* config);
    void Clay__CloseElement();
    Clay_ElementId Clay__HashString(Clay_String key, uint seed);
    Clay_ElementId Clay__HashStringWithOffset(Clay_String key, uint offset, uint seed);
    void Clay__OpenTextElement(Clay_String text, Clay_TextElementConfig* textConfig);
    Clay_TextElementConfig* Clay__StoreTextElementConfig(Clay_TextElementConfig config);
    uint Clay__GetParentElementId();
}

uint clayMinMemorySize() { return Clay_MinMemorySize(); }
Clay_Arena clayCreateArenaWithCapacityAndMemory(size_t capacity, void* memory) { return Clay_CreateArenaWithCapacityAndMemory(capacity, memory); }
void claySetPointerState(Clay_Vector2 position, bool pointerDown) { Clay_SetPointerState(position, pointerDown); }
Clay_Context* clayInitialize(Clay_Arena arena, Clay_Dimensions layoutDimensions, Clay_ErrorHandler errorHandler) { return Clay_Initialize(arena, layoutDimensions, errorHandler); }
Clay_Context* clayGetCurrentContext() { return Clay_GetCurrentContext(); }
void claySetCurrentContext(Clay_Context* context) { Clay_SetCurrentContext(context); }
void clayUpdateScrollContainers(bool enableDragScrolling, Clay_Vector2 scrollDelta, float deltaTime) { Clay_UpdateScrollContainers(enableDragScrolling, scrollDelta, deltaTime); }
Clay_Vector2 clayGetScrollOffset() { return Clay_GetScrollOffset(); }
void claySetLayoutDimensions(Clay_Dimensions dimensions) { Clay_SetLayoutDimensions(dimensions); }
void clayBeginLayout() { Clay_BeginLayout(); }
Clay_RenderCommandArray clayEndLayout() { return Clay_EndLayout(); }
Clay_ElementId clayGetElementId(Clay_String idString) { return Clay_GetElementId(idString); }
Clay_ElementId clayGetElementIdWithIndex(Clay_String idString, uint index) { return Clay_GetElementIdWithIndex(idString, index); }
Clay_ElementData clayGetElementData(Clay_ElementId id) { return Clay_GetElementData(id); }
bool clayHovered() { return Clay_Hovered(); }
void clayOnHover(Clay_OnHoverFn onHoverFunction, void* userData) { Clay_OnHover(onHoverFunction, userData); }
bool clayPointerOver(Clay_ElementId elementId) { return Clay_PointerOver(elementId); }
Clay_ElementIdArray clayGetPointerOverIds() { return Clay_GetPointerOverIds(); }
Clay_PointerData clayGetPointerData() { return Clay_GetPointerData(); }
Clay_ScrollContainerData clayGetScrollContainerData(Clay_ElementId id) { return Clay_GetScrollContainerData(id); }
void claySetMeasureTextFunction(Clay_MeasureTextFn measureTextFunction, void* userData) { Clay_SetMeasureTextFunction(measureTextFunction, userData); }
void claySetQueryScrollOffsetFunction(Clay_QueryScrollOffsetFn queryScrollOffsetFunction, void* userData) { Clay_SetQueryScrollOffsetFunction(queryScrollOffsetFunction, userData); }
Clay_RenderCommand* clayRenderCommandArrayGet(Clay_RenderCommandArray* array, int index) { return Clay_RenderCommandArray_Get(array, index); }
void claySetDebugModeEnabled(bool enabled) { Clay_SetDebugModeEnabled(enabled); }
bool clayIsDebugModeEnabled() { return Clay_IsDebugModeEnabled(); }
void claySetCullingEnabled(bool enabled) { Clay_SetCullingEnabled(enabled); }
int clayGetMaxElementCount() { return Clay_GetMaxElementCount(); }
void claySetMaxElementCount(int maxElementCount) { Clay_SetMaxElementCount(maxElementCount); }
int clayGetMaxMeasureTextCacheWordCount() { return Clay_GetMaxMeasureTextCacheWordCount(); }
void claySetMaxMeasureTextCacheWordCount(int c) { Clay_SetMaxMeasureTextCacheWordCount(c); }
void clayResetMeasureTextCache() { Clay_ResetMeasureTextCache(); }
void clayOpenElement() { Clay__OpenElement(); }
void clayOpenElementWithId(Clay_ElementId elementId) { Clay__OpenElementWithId(elementId); }
void clayConfigureOpenElement(const Clay_ElementDeclaration* config) { Clay__ConfigureOpenElementPtr(config); }
void clayCloseElement() { Clay__CloseElement(); }
Clay_ElementId clayHashString(Clay_String key, uint seed) nothrow @nogc { return Clay__HashString(key, seed); }
Clay_ElementId clayHashStringWithOffset(Clay_String key, uint offset, uint seed) nothrow @nogc { return Clay__HashStringWithOffset(key, offset, seed); }
void clayOpenTextElement(Clay_String text, Clay_TextElementConfig* textConfig) { Clay__OpenTextElement(text, textConfig); }
Clay_TextElementConfig* clayStoreTextElementConfig(Clay_TextElementConfig config) { return Clay__StoreTextElementConfig(config); }
uint clayGetParentElementId() nothrow @nogc { return Clay__GetParentElementId(); }

Clay_String clayString(const char[] literal) pure nothrow @nogc
{
    Clay_String s;
    s.isStaticallyAllocated = true;
    s.length = cast(int) literal.length;
    s.chars = literal.ptr;
    return s;
}

Clay_ElementId clayId(const char[] label) nothrow @nogc
{
    return clayHashString(clayString(label), 0);
}

Clay_ElementId clayIdWithIndex(const char[] label, uint index) nothrow @nogc
{
    return clayHashStringWithOffset(clayString(label), index, 0);
}

Clay_ElementId clayIdLocal(const char[] label) nothrow @nogc
{
    return clayHashString(clayString(label), clayGetParentElementId());
}

Clay_ElementId clayIdLocalWithIndex(const char[] label, uint index) nothrow @nogc
{
    return clayHashStringWithOffset(clayString(label), index, clayGetParentElementId());
}

Clay_SizingAxis claySizingFit(float min = 0, float max = float.max) nothrow @nogc
{
    Clay_SizingAxis a;
    a.size.minMax.min = min;
    a.size.minMax.max = max;
    a.type = Clay_SizingType.sizingTypeFit;
    return a;
}

Clay_SizingAxis claySizingGrow(float min = 0, float max = float.max) nothrow @nogc
{
    Clay_SizingAxis a;
    a.size.minMax.min = min;
    a.size.minMax.max = max;
    a.type = Clay_SizingType.sizingTypeGrow;
    return a;
}

Clay_SizingAxis claySizingFixed(float fixedSize) nothrow @nogc
{
    Clay_SizingAxis a;
    a.size.minMax.min = fixedSize;
    a.size.minMax.max = fixedSize;
    a.type = Clay_SizingType.sizingTypeFixed;
    return a;
}

Clay_SizingAxis claySizingPercent(float percentOfParent) nothrow @nogc
{
    Clay_SizingAxis a;
    a.size.percent = percentOfParent;
    a.type = Clay_SizingType.sizingTypePercent;
    return a;
}

Clay_Padding clayPaddingAll(ushort padding) nothrow @nogc
{
    Clay_Padding p;
    p.left = p.right = p.top = p.bottom = padding;
    return p;
}

Clay_CornerRadius clayCornerRadius(float radius) nothrow @nogc
{
    Clay_CornerRadius r;
    r.topLeft = r.topRight = r.bottomLeft = r.bottomRight = radius;
    return r;
}

Clay_Color clayColor(float r, float g, float b, float a = 255) nothrow @nogc
{
    Clay_Color c;
    c.r = r; c.g = g; c.b = b; c.a = a;
    return c;
}

Clay_ElementDeclaration clayElementDeclaration() nothrow @nogc
{
    Clay_ElementDeclaration d;
    d.layout.sizing.width = claySizingFit();
    d.layout.sizing.height = claySizingFit();
    d.layout.layoutDirection = Clay_LayoutDirection.leftToRight;
    return d;
}

void clayElement(Clay_ElementId id, ref const Clay_ElementDeclaration decl)
{
    clayOpenElementWithId(id);
    clayConfigureOpenElement(&decl);
}

void clayElementAutoId(ref const Clay_ElementDeclaration decl)
{
    clayOpenElement();
    clayConfigureOpenElement(&decl);
}

void clayText(Clay_String text, ref Clay_TextElementConfig config)
{
    clayOpenTextElement(text, &config);
}

Clay_TextElementConfig* clayTextConfig(Clay_TextElementConfig config)
{
    return clayStoreTextElementConfig(config);
}

void clayElementScope(Clay_ElementId id, ref const Clay_ElementDeclaration decl, void delegate() dg)
{
    clayOpenElementWithId(id);
    clayConfigureOpenElement(&decl);
    scope (exit) clayCloseElement();
    dg();
}

void clayElementScopeAutoId(ref const Clay_ElementDeclaration decl, void delegate() dg)
{
    clayOpenElement();
    clayConfigureOpenElement(&decl);
    scope (exit) clayCloseElement();
    dg();
}
