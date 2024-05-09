WASM-TOOLS = wasm-tools
WASMTIME = wasmtime

SRC_FILES := $(wildcard *.wat)

all: $(SRC_FILES:.wat=.wasm)

%.wasm: %.wat
	$(WASM-TOOLS) parse $< -o $@
	$(WASM-TOOLS) dump $@
	ls -l $@
	$(WASMTIME) $@

clean:
	rm -rf $(SRC_FILES:.wat=.wasm)
