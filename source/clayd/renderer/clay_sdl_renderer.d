module clayd.renderer.clay_sdl_renderer;
version (clay_sdl3)
{
    import bindbc.sdl;
    import core.stdc.stdlib : free, malloc;
    import clayd.base;

    T SDL_min(T)(T a, T b)
    {
        return a < b ? a : b;
    }

    T SDL_max(T)(T a, T b)
    {
        return a > b ? a : b;
    }

    private float colorChannelToUnitFloat(float channel)
    {
        return SDL_min(SDL_max(channel / 255.0f, 0.0f), 1.0f);
    }

    private SDL_FColor clayColorToSDLColor(Clay_Color color)
    {
        return SDL_FColor(
            colorChannelToUnitFloat(color.r),
            colorChannelToUnitFloat(color.g),
            colorChannelToUnitFloat(color.b),
            colorChannelToUnitFloat(color.a)
        );
    }

    struct Clay_SDL3RendererData
    {
        SDL_Renderer* renderer;
        TTF_TextEngine* textEngine;
        TTF_Font** fonts;
    }

    private __gshared int NUM_CIRCLE_SEGMENTS = 16;
    private __gshared SDL_Rect currentClippingRectangle;

extern (C):
    void SDL_Clay_RenderFillRoundedRect(Clay_SDL3RendererData* rendererData, const SDL_FRect rect, const float cornerRadius, const Clay_Color _color)
    {
        const SDL_FColor color = clayColorToSDLColor(_color);

        int indexCount = 0;
        int vertexCount = 0;

        const float minRadius = SDL_min(rect.w, rect.h) / 2.0f;
        const float clampedRadius = SDL_min(cornerRadius, minRadius);
        const int numCircleSegments = SDL_max(NUM_CIRCLE_SEGMENTS, cast(int)(clampedRadius * 0.5f));

        int totalVertices = 4 + (4 * (numCircleSegments * 2)) + 2 * 4;
        int totalIndices = 6 + (4 * (numCircleSegments * 3)) + 6 * 4;

        //SDL_Vertex[] vertices = new SDL_Vertex[](totalVertices);
        //int[] indices = new int[](totalIndices);
        SDL_Vertex* vptr = cast(SDL_Vertex*) malloc(SDL_Vertex.sizeof * totalVertices);
        auto vertices = vptr[0 .. totalVertices];

        int* iptr = cast(int*) malloc(int.sizeof * totalIndices);
        auto indices = iptr[0 .. totalIndices];

        scope (exit)
        {
            free(vptr);
            free(iptr);
        }

        vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(rect.x + clampedRadius, rect.y + clampedRadius), color, SDL_FPoint(
                0, 0));
        vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(rect.x + rect.w - clampedRadius, rect.y + clampedRadius), color, SDL_FPoint(
                1, 0));
        vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(rect.x + rect.w - clampedRadius, rect.y + rect.h - clampedRadius), color, SDL_FPoint(
                1, 1));
        vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(rect.x + clampedRadius, rect.y + rect.h - clampedRadius), color, SDL_FPoint(
                0, 1));

        indices[indexCount++] = 0;
        indices[indexCount++] = 1;
        indices[indexCount++] = 3;
        indices[indexCount++] = 1;
        indices[indexCount++] = 2;
        indices[indexCount++] = 3;

        // Define rounded corners
        const float step = (SDL_PI_F / 2.0f) / numCircleSegments;
        for (int i = 0; i < numCircleSegments; i++)
        {
            const float angle1 = cast(float) i * step;
            const float angle2 = (cast(float) i + 1.0f) * step;

            for (int j = 0; j < 4; j++)
            {
                float cx, cy, signX, signY;
                switch (j)
                {
                case 0:
                    cx = rect.x + clampedRadius;
                    cy = rect.y + clampedRadius;
                    signX = -1;
                    signY = -1;
                    break;
                case 1:
                    cx = rect.x + rect.w - clampedRadius;
                    cy = rect.y + clampedRadius;
                    signX = 1;
                    signY = -1;
                    break;
                case 2:
                    cx = rect.x + rect.w - clampedRadius;
                    cy = rect.y + rect.h - clampedRadius;
                    signX = 1;
                    signY = 1;
                    break;
                case 3:
                    cx = rect.x + clampedRadius;
                    cy = rect.y + rect.h - clampedRadius;
                    signX = -1;
                    signY = 1;
                    break;
                default:
                    return;
                }

                vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(cx + SDL_cosf(angle1) * clampedRadius * signX, cy + SDL_sinf(
                        angle1) * clampedRadius * signY), color, SDL_FPoint(0, 0));
                vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(cx + SDL_cosf(angle2) * clampedRadius * signX, cy + SDL_sinf(
                        angle2) * clampedRadius * signY), color, SDL_FPoint(0, 0));

                indices[indexCount++] = j;
                indices[indexCount++] = vertexCount - 2;
                indices[indexCount++] = vertexCount - 1;
            }
        }

        void addEdge(float x1, float y1, float x2, float y2, int v1, int v2, SDL_FPoint p1, SDL_FPoint p2)
        {
            vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(x1, y1), color, p1);
            vertices[vertexCount++] = SDL_Vertex(SDL_FPoint(x2, y2), color, p2);
            indices[indexCount++] = v1;
            indices[indexCount++] = vertexCount - 2;
            indices[indexCount++] = vertexCount - 1;
            indices[indexCount++] = v2;
            indices[indexCount++] = v1;
            indices[indexCount++] = vertexCount - 1;
        }

        // Top edge
        addEdge(rect.x + clampedRadius, rect.y, rect.x + rect.w - clampedRadius, rect.y, 0, 1, SDL_FPoint(0, 0), SDL_FPoint(
                1, 0));
        // Right edge
        addEdge(rect.x + rect.w, rect.y + clampedRadius, rect.x + rect.w, rect.y + rect.h - clampedRadius, 1, 2, SDL_FPoint(
                1, 0), SDL_FPoint(1, 1));
        // Bottom edge
        addEdge(rect.x + rect.w - clampedRadius, rect.y + rect.h, rect.x + clampedRadius, rect.y + rect.h, 2, 3, SDL_FPoint(
                1, 1), SDL_FPoint(0, 1));
        // Left edge
        addEdge(rect.x, rect.y + rect.h - clampedRadius, rect.x, rect.y + clampedRadius, 3, 0, SDL_FPoint(0, 1), SDL_FPoint(
                0, 0));

        SDL_RenderGeometry(rendererData.renderer, null, vertices.ptr, vertexCount, indices.ptr, indexCount);
    }

    void SDL_Clay_RenderArc(Clay_SDL3RendererData* rendererData, const SDL_FPoint center, const float radius, const float startAngle, const float endAngle, const float thickness, const Clay_Color color)
    {
        const SDL_FColor drawColor = clayColorToSDLColor(color);
        SDL_SetRenderDrawColorFloat(rendererData.renderer, drawColor.r, drawColor.g, drawColor.b, drawColor.a);

        const float radStart = startAngle * (SDL_PI_F / 180.0f);
        const float radEnd = endAngle * (SDL_PI_F / 180.0f);
        const int numCircleSegments = SDL_max(NUM_CIRCLE_SEGMENTS, cast(int)(radius * 1.5f));

        const float angleStep = (radEnd - radStart) / cast(float) numCircleSegments;
        const float thicknessStep = 0.4f;
        SDL_FPoint* p;
        for (float t = thicknessStep; t < thickness - thicknessStep; t += thicknessStep)
        {
            //auto points = new SDL_FPoint[](numCircleSegments + 1);
            p = cast(SDL_FPoint*) malloc(SDL_FPoint.sizeof * (numCircleSegments + 1));
            auto points = p[0 .. numCircleSegments + 1];

            const float clampedRadius = SDL_max(radius - t, 1.0f);

            for (int i = 0; i <= numCircleSegments; i++)
            {
                const float angle = radStart + i * angleStep;
                points[i] = SDL_FPoint(
                    SDL_roundf(center.x + SDL_cosf(angle) * clampedRadius),
                    SDL_roundf(center.y + SDL_sinf(angle) * clampedRadius)
                );
            }
            SDL_RenderLines(rendererData.renderer, points.ptr, cast(int) points.length);
        }
        scope (exit)
            free(p);
    }

    void SDL_Clay_RenderClayCommands(Clay_SDL3RendererData* rendererData, Clay_RenderCommandArray rcommands)
    {
        for (int i = 0; i < rcommands.length; i++)
        {
            Clay_RenderCommand* rcmd = clayRenderCommandArrayGet(
                cast(Clay_RenderCommandArray*)&rcommands, i);
            const Clay_BoundingBox bbox = rcmd.boundingBox;
            const SDL_FRect rect = SDL_FRect(bbox.x, bbox.y, bbox.width, bbox.height);

            switch (rcmd.commandType)
            {
            case Clay_RenderCommandType.renderCommandTypeRectangle:
                auto config = &rcmd.renderData.rectangle;
                SDL_SetRenderDrawBlendMode(rendererData.renderer, SDL_BLENDMODE_BLEND);
                const SDL_FColor bgColor = clayColorToSDLColor(config.backgroundColor);
                SDL_SetRenderDrawColorFloat(rendererData.renderer, bgColor.r, bgColor.g, bgColor.b, bgColor.a);

                if (config.cornerRadius.topLeft > 0)
                {
                    SDL_Clay_RenderFillRoundedRect(rendererData, rect, config.cornerRadius.topLeft, config
                            .backgroundColor);
                }
                else
                {
                    SDL_RenderFillRect(rendererData.renderer, &rect);
                }
                break;

            case Clay_RenderCommandType.renderCommandTypeText:
                const Clay_TextRenderData* config = &rcmd.renderData.text;
                TTF_Font* font = rendererData.fonts[config.fontId];
                TTF_SetFontSize(font, cast(int) config.fontSize);
                TTF_Text* text = TTF_CreateText(rendererData.textEngine, font, config.stringContents.chars, cast(
                        size_t) config.stringContents.length);
                const SDL_FColor textColor = clayColorToSDLColor(config.textColor);
                TTF_SetTextColorFloat(text, textColor.r, textColor.g, textColor.b, textColor.a);
                TTF_DrawRendererText(text, rect.x, rect.y);
                TTF_DestroyText(text);
                break;

            case Clay_RenderCommandType.renderCommandTypeBorder:
                const Clay_BorderRenderData* config = &rcmd.renderData.border;

                const float minRadius = SDL_min(rect.w, rect.h) / 2.0f;
                const Clay_CornerRadius clampedRadii = {
                    SDL_min(config.cornerRadius.topLeft, minRadius),
                    SDL_min(config.cornerRadius.topRight, minRadius),
                    SDL_min(config.cornerRadius.bottomLeft, minRadius),
                    SDL_min(config.cornerRadius.bottomRight, minRadius)
                };

                const SDL_FColor borderColor = clayColorToSDLColor(config.color);
                SDL_SetRenderDrawColorFloat(rendererData.renderer, borderColor.r, borderColor.g, borderColor.b, borderColor.a);

                // Left edge
                if (config.width.left > 0)
                {
                    const float starting_y = rect.y + clampedRadii.topLeft;
                    const float length = rect.h - clampedRadii.topLeft - clampedRadii.bottomLeft;
                    const SDL_FRect line = {
                        rect.x - 1, starting_y, cast(float) config.width.left, length
                    };
                    SDL_RenderFillRect(rendererData.renderer, &line);
                }

                // Right edge
                if (config.width.right > 0)
                {
                    const float starting_x = rect.x + rect.w - cast(float) config.width.right + 1;
                    const float starting_y = rect.y + clampedRadii.topRight;
                    const float length = rect.h - clampedRadii.topRight - clampedRadii.bottomRight;
                    const SDL_FRect line = {
                        starting_x, starting_y, cast(float) config.width.right, length
                    };
                    SDL_RenderFillRect(rendererData.renderer, &line);
                }

                // Top edge
                if (config.width.top > 0)
                {
                    const float starting_x = rect.x + clampedRadii.topLeft;
                    const float length = rect.w - clampedRadii.topLeft - clampedRadii.topRight;
                    const SDL_FRect line = {
                        starting_x, rect.y - 1, length, cast(float) config.width.top
                    };
                    SDL_RenderFillRect(rendererData.renderer, &line);
                }

                // Bottom edge
                if (config.width.bottom > 0)
                {
                    const float starting_x = rect.x + clampedRadii.bottomLeft;
                    const float starting_y = rect.y + rect.h - cast(float) config.width.bottom + 1;
                    const float length = rect.w - clampedRadii.bottomLeft - clampedRadii
                        .bottomRight;
                    const SDL_FRect line = {
                        starting_x, starting_y, length, cast(float) config.width.bottom
                    };
                    SDL_RenderFillRect(rendererData.renderer, &line);
                }

                // --- Corners (Arcs) ---

                if (config.cornerRadius.topLeft > 0)
                {
                    const float centerX = rect.x + clampedRadii.topLeft - 1;
                    const float centerY = rect.y + clampedRadii.topLeft - 1;
                    SDL_Clay_RenderArc(rendererData, SDL_FPoint(centerX, centerY), clampedRadii.topLeft,
                        180.0f, 270.0f, cast(float) config.width.top, config.color);
                }

                if (config.cornerRadius.topRight > 0)
                {
                    const float centerX = rect.x + rect.w - clampedRadii.topRight;
                    const float centerY = rect.y + clampedRadii.topRight - 1;
                    SDL_Clay_RenderArc(rendererData, SDL_FPoint(centerX, centerY), clampedRadii.topRight,
                        270.0f, 360.0f, cast(float) config.width.top, config.color);
                }

                if (config.cornerRadius.bottomLeft > 0)
                {
                    const float centerX = rect.x + clampedRadii.bottomLeft - 1;
                    const float centerY = rect.y + rect.h - clampedRadii.bottomLeft;
                    SDL_Clay_RenderArc(rendererData, SDL_FPoint(centerX, centerY), clampedRadii.bottomLeft,
                        90.0f, 180.0f, cast(float) config.width.bottom, config.color);
                }

                if (config.cornerRadius.bottomRight > 0)
                {
                    const float centerX = rect.x + rect.w - clampedRadii.bottomRight;
                    const float centerY = rect.y + rect.h - clampedRadii.bottomRight;
                    SDL_Clay_RenderArc(rendererData, SDL_FPoint(centerX, centerY), clampedRadii.bottomRight,
                        0.0f, 90.0f, cast(float) config.width.bottom, config.color);
                }
                break;

            case Clay_RenderCommandType.renderCommandTypeScissorStart:
                Clay_BoundingBox boundingBox = rcmd.boundingBox;
                currentClippingRectangle = SDL_Rect(
                    cast(int) boundingBox.x,
                    cast(int) boundingBox.y,
                    cast(int) boundingBox.width,
                    cast(int) boundingBox.height
                );
                SDL_SetRenderClipRect(rendererData.renderer, &currentClippingRectangle);
                break;

            case Clay_RenderCommandType.renderCommandTypeScissorEnd:
                SDL_SetRenderClipRect(rendererData.renderer, null);
                break;

            case Clay_RenderCommandType.renderCommandTypeImage:
                SDL_Texture* texture = cast(SDL_Texture*) rcmd.renderData.image.imageData;
                const SDL_FRect dest = SDL_FRect(rect.x, rect.y, rect.w, rect.h);
                SDL_RenderTexture(rendererData.renderer, texture, null, &dest);
                break;

            default:
                SDL_Log("Unknown render command type: %d", &rcmd.commandType);
                break;
            }
        }
    }

}
