DOWNLOADS_DIR := downloads
TEMP_DIR := temp

PYVERSION_WIN32 := 2.6
PYVERSION_WIN32_FULL := 2.6.5
PYTHON_WIN32 := python$(PYVERSION_WIN32)
PYTHON_DIRS_WIN32 := coreport
PYTHON_URL := http://python.org/ftp/python/$(PYVERSION_WIN32_FULL)/python-$(PYVERSION_WIN32_FULL).msi
PYTHON_DOWNLOADED_MSI := $(DOWNLOADS_DIR)/python-$(PYVERSION_WIN32_FULL).msi
PYPREFIX := $(shell python$(PYVERSION_WIN32) -c "import sys; print(sys.prefix)")
LINKFORSHARED := $(shell python$(PYVERSION_WIN32) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LINKFORSHARED'))")
WINPYTHON_DIR := $(TEMP_DIR)/python-$(PYVERSION_WIN32_FULL)
WINPYTHON_DLL := python26.dll
WINPYTHON_MANIFEST = Microsoft.VC90.CRT.manifest
INCLUDES_WIN32 := -I$(WINPYTHON_DIR)/include
WIN32_RELEASE := app1-win32
TARGET_EXE := capp1.exe
TARGET_EXE_PY := $(patsubst %.exe,%.py,$(TARGET_EXE))
TARGET_EXE_C := $(patsubst %.exe,%.c,$(TARGET_EXE))
MINGW32 := /usr/bin/i586-mingw32msvc-cc
MINGW32_NONCONSOLE_TARGET_OPT := -Wl,-subsystem,windows
WIN32_MODULES_DIR := $(WIN32_RELEASE)/libs
WIN32_MODULES_FILE := modules.dat

# What builtin python modules are minimally needed to function on Windows?
BUILTINS_RAW := distutils/ email/ email/mime/ encodings/ json/ logging/ multiprocessing/ sqlite3/ xml/ xml/dom/ xml/parsers
BUILTINS_DIR := $(WINPYTHON_DIR)/Lib/
BUILTINS_PY := $(shell ls $(BUILTINS_DIR)/*.py)
BUILTINS_DLLS := $(shell ls $(WINPYTHON_DIR)/DLLs/*.dll)
BUILTINS_PYD := $(shell ls $(WINPYTHON_DIR)/DLLs/*.pyd)

# MinGW32 runtime
MINGWREDIST_DLL_DIR := /usr/share/doc/mingw32-runtime/
MINGWREDIST_DLL := mingwm10.dll
MINGWREDIST_DLL_GZ := $(addsuffix .gz,$(MINGWREDIST_DLL))

# Couchdb
COUCHDB_REDIST_URL := https://github.com/downloads/dch/couchdb/couchdb-1.1.0+COUCHDB-1152_otp_R14B01+OTP-9139.7z
COUCHDB_DOWNLOADED_REDIST := $(DOWNLOADS_DIR)/couchdb_redist.7z
COUCHDB_REDIST_DIR := $(TEMP_DIR)/couchdb_redist
COUCHDB_HG_URL := https://couchdb-python.googlecode.com/hg/
COUCHDB_DIR := couchdb-python
COUCHDB_HG_CLONE := $(addprefix $(DOWNLOADS_DIR)/,$(COUCHDB_DIR))


all: $(PYTHON_DOWNLOADED_MSI) $(COUCHDB_HG_CLONE) $(COUCHDB_REDIST_DIR)

# Downloading prerequisites
$(DOWNLOADS_DIR):
	@echo "Creating directory for downloads"
	mkdir $(DOWNLOADS_DIR)


$(COUCHDB_HG_CLONE): $(DOWNLOADS_DIR) 
	@echo "Cloning couchdb-python"
	ls $(COUCHDB_HG_CLONE) || hg clone $(COUCHDB_HG_URL) $(COUCHDB_HG_CLONE)


$(COUCHDB_REDIST_DIR): $(DOWNLOADS_DIR)
	@echo "Downloading precompiled couchdb-redistribulable"
	ls $(COUCHDB_DOWNLOADED_REDIST) || wget -O $(COUCHDB_DOWNLOADED_REDIST) $(COUCHDB_REDIST_URL)
	ls $(COUCHDB_REDIST_DIR) || 7z x -o$(TEMP_DIR) $(COUCHDB_DOWNLOADED_REDIST) && mv $(TEMP_DIR)/couch* $(COUCHDB_REDIST_DIR) 


$(PYTHON_DOWNLOADED_MSI): $(DOWNLOADS_DIR)
	@echo "Downloading $(PYTHON_DOWNLOADED_MSI)"
	ls $(PYTHON_DOWNLOADED_MSI) || wget -O $(PYTHON_DOWNLOADED_MSI) "http://python.org/ftp/python/$(PYVERSION_WIN32_FULL)/python-$(PYVERSION_WIN32_FULL).msi"
	ls $(TEMP_DIR) 1>&2 2>/dev/null || mkdir $(TEMP_DIR)
	ls $(WINPYTHON_DIR) 1>&2 2>/dev/null || mkdir $(WINPYTHON_DIR)
	ls $(WINPYTHON_DIR) 1>&2 2>/dev/null && msiexec /a $(PYTHON_DOWNLOADED_MSI) /qb TARGETDIR=$(WINPYTHON_DIR)


# Compile *.py boot file to *.exe
%.exe: %.c
	$(MINGW32) -c $(patsubst %.exe,%.c,$@) $(INCLUDES_WIN32)
	$(MINGW32) -o $@ $(patsubst %.exe,%.o,$@) $(LINKFORSHARED) $(if $(findstring chostgui.exe,$@),$(MINGW32_NONCONSOLE_TARGET_OPT)) -lpython26 -lm -lmingwthrd -L$(WINPYTHON_DIR)/libs


%.c: %.py
	$(PYTHON) `which cython` --embed $^ -o $@
	sed --in-place -r -e 's/(    Py_SetProgramName\(argv\[0\]\);)/    Py_OptimizeFlag = 2;\n    Py_NoSiteFlag = 1;\n\1/' $@


prepare-win32:
	mkdir -p $(WIN32_RELEASE)
	mkdir -p $(WIN32_MODULES_DIR)
#	Project modules
	@for dir in $(PYTHON_DIRS_WIN32); do \
		mkdir -p $(WIN32_RELEASE)/$$dir; \
		find $$dir -maxdepth 1 -name "*.py" -not -path "*/test*" -exec cp {} $(WIN32_RELEASE)/$$dir \; ; \
	done
#	Python builtins
	@for dir in $(BUILTINS_RAW); do \
		mkdir -p $(WIN32_RELEASE)/$$dir; \
		find $(BUILTINS_DIR)/$$dir -maxdepth 1 -name "*.py" -not -path "*/test*" -exec cp {} $(WIN32_RELEASE)/$$dir \; ; \
	done
	cp $(BUILTINS_PY) $(WIN32_RELEASE)
	cp -R $(BUILTINS_DLLS) $(WIN32_RELEASE)
	cp -R $(BUILTINS_PYD) $(WIN32_MODULES_DIR)

	cp -R $(COUCHDB_HG_CLONE)/couchdb $(WIN32_RELEASE)

#	MinGW32 runtime
	gunzip --stdout $(MINGWREDIST_DLL_DIR)/$(MINGWREDIST_DLL_GZ) > $(WIN32_RELEASE)/$(MINGWREDIST_DLL)


precompile-win32: prepare-win32
	@find $(WIN32_RELEASE) -name '*.py' -and -not -name 'cnode.*' | $(PYTHON_WIN32) -OO /usr/bin/py_compilefiles -


$(WIN32_MODULES_FILE): precompile-win32
	7z a -R -tzip -mx9 -mmt=on -mpass=15 -mm=Deflate $@ "./$(WIN32_RELEASE)/*.pyo" -x\!"./$(WIN32_MODULES_DIR)"


build-win32: $(WIN32_MODULES_FILE) $(TARGET_EXE)
	cp -f $(TARGET_EXE) $(WINPYTHON_DIR)/$(WINPYTHON_DLL) $(WIN32_RELEASE)
	cp -f $(TARGET_EXE) $(WINPYTHON_DIR)/$(WINPYTHON_MANIFEST) $(WIN32_RELEASE)
	cp -f $(WIN32_MODULES_FILE) $(WIN32_MODULES_DIR)


# Remove the temporary files created during the Win32 build
postbuild-win32:
	rm -rf $(TARGET_EXE) $(WIN32_MODULES_FILE)
	rm -rf $(addprefix $(WIN32_RELEASE)/,$(PYTHON_DIRS_HOSTONLY))
	rm -rf $(WIN32_RELEASE)/*.py
# 	Special case for hostgui.pyo, which needs to be included into the toplevel directory.
	find $(WIN32_RELEASE)/ -maxdepth 1 -name '*.pyo' -and -not -name 'chostgui.pyo' | xargs rm -f
	find $(WIN32_RELEASE)/ -maxdepth 1 -name '*.pyc' -and -not -name 'chostgui.pyo' | xargs rm -f
	rm -rf $(addprefix $(WIN32_RELEASE)/,$(BUILTINS_RAW))
	find $(WIN32_RELEASE) -name "*.py" | xargs rm -f


# Build the win32 directory for future use
build-win32-dir: build-win32 postbuild-win32


# Having the Win32 files cross-compiled, create an installer using NSIS.
make-nsis-win32:
	makensis app1.nsi


# Create the installer from scratch
binary-win32: build-win32-dir make-nsis-win32

build: binary-win32
