.PHONY: sdl3

sdl3:
	dub build --config=SDL3 --compiler=ldc2

app:
	dub build --config=application --compiler=ldc2

# no renderer
libstandalone:
	dub build --config=library --compiler=ldc2