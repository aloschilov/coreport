DOWNLOADS_DIR := downloads
TEMP_DIR := temp

PYVERSION_WIN32 := 2.6
PYVERSION_WIN32_FULL := 2.6.5
PYTHON_WIN32 := python$(PYVERSION_WIN32)

PROJECT_BOOTSTRAP_MODULES := capp2.py capp1.py

PYTHON_URL := http://python.org/ftp/python/$(PYVERSION_WIN32_FULL)/python-$(PYVERSION_WIN32_FULL).msi
PYTHON_DOWNLOADED_MSI := $(DOWNLOADS_DIR)/python-$(PYVERSION_WIN32_FULL).msi
PYPREFIX := $(shell python$(PYVERSION_WIN32) -c "import sys; print(sys.prefix)")
LINKFORSHARED := $(shell python$(PYVERSION_WIN32) -c "import distutils.sysconfig; print(distutils.sysconfig.get_config_var('LINKFORSHARED'))")
WINPYTHON_DIR := $(TEMP_DIR)/python-$(PYVERSION_WIN32_FULL)
WINPYTHON_DLL := python26.dll
WINPYTHON_MANIFEST = Microsoft.VC90.CRT.manifest
INCLUDES_WIN32 := -I$(WINPYTHON_DIR)/include
WIN32_RELEASE := coreport-win32
WIN32_MODULES_DIR := $(WIN32_RELEASE)/libs
WIN32_MODULES_FILE := modules.dat

# What builtin python modules are minimally needed to function on Windows?

BUILTINS_RAW := distutils/ email/ email/mime/ encodings/ json/ logging/ multiprocessing/ sqlite3/ xml/ xml/dom/ xml/parsers ctypes/
BUILTINS_DIR := $(WINPYTHON_DIR)/Lib/
BUILTINS_PY := $(shell ls $(BUILTINS_DIR)/*.py)
BUILTINS_DLLS := $(shell ls $(WINPYTHON_DIR)/DLLs/*.dll)
BUILTINS_PYD := $(shell ls $(WINPYTHON_DIR)/DLLs/*.pyd)

# Couchdb

COUCHDB_REDIST_URL := https://github.com/downloads/dch/couchdb/couchdb-1.1.0+COUCHDB-1152_otp_R14B01+OTP-9139.7z
COUCHDB_DOWNLOADED_REDIST := $(DOWNLOADS_DIR)/couchdb_redist.7z
COUCHDB_REDIST_DIR := $(TEMP_DIR)/couchdb_redist

COUCHDB_HG_URL := https://couchdb-python.googlecode.com/hg/
COUCHDB_DIR := couchdb-python
COUCHDB_HG_CLONE := $(addprefix $(DOWNLOADS_DIR)/,$(COUCHDB_DIR))

# Eventlet
EVENTLET_VERSION := 0.9.15
EVENTLET_URL := http://pypi.python.org/packages/source/e/eventlet/eventlet-$(EVENTLET_VERSION).tar.gz
EVENTLET_DOWNLOADED := $(DOWNLOADS_DIR)/eventlet-$(EVENTLET_VERSION).tar.gz
EVENTLET_DIR := $(TEMP_DIR)/eventlet-$(EVENTLET_VERSION)

# Greenlet
GREENLET_URL := http://pypi.python.org/packages/2.6/g/greenlet/greenlet-0.3.1.win32-py2.6.exe
GREENLET_DOWNLOADED := $(DOWNLOADS_DIR)/greenlet-0.3.1-py2.6-win32.egg

# ZeroMQ
ZEROMQ_URL := https://github.com/downloads/zeromq/pyzmq/pyzmq-2.1.4.win32-py2.6.msi
ZEROMQ_DOWNLOADED_MSI := $(DOWNLOADS_DIR)/pyzmq-2.1.4.win32-py2.6.msi
ZEROMQ_TEMP_DIR := $(TEMP_DIR)/pyzmq


PYTHON_DIRS_WIN32 := coreport


all: $(PYTHON_DOWNLOADED_MSI) $(COUCHDB_HG_CLONE) $(COUCHDB_REDIST_DIR) $(EVENTLET_DIR) $(GREENLET_DOWNLOADED) $(ZEROMQ_TEMP_DIR) $(ZEROMQ_TEMP_DIR)

# Downloading prerequisites
$(DOWNLOADS_DIR):
	@echo "Creating directory for downloads"
	mkdir $(DOWNLOADS_DIR)


$(COUCHDB_HG_CLONE): $(DOWNLOADS_DIR)
	@echo "Cloning couchdb-python"
	ls $(COUCHDB_HG_CLONE) 1>/dev/null 2>/dev/null || hg clone $(COUCHDB_HG_URL) $(COUCHDB_HG_CLONE)


$(COUCHDB_REDIST_DIR): $(DOWNLOADS_DIR)
	@echo "Downloading precompiled couchdb-redistribulable"
	ls $(COUCHDB_DOWNLOADED_REDIST) 1>/dev/null 2>/dev/null || wget -O $(COUCHDB_DOWNLOADED_REDIST) $(COUCHDB_REDIST_URL)
	ls $(COUCHDB_REDIST_DIR) 1>/dev/null 2>/dev/null || (7z x -o$(TEMP_DIR) $(COUCHDB_DOWNLOADED_REDIST) && mv $(TEMP_DIR)/couch* $(COUCHDB_REDIST_DIR))


$(PYTHON_DOWNLOADED_MSI): $(DOWNLOADS_DIR)
	@echo "Downloading $(PYTHON_DOWNLOADED_MSI)"
	ls $(PYTHON_DOWNLOADED_MSI) 1>/dev/null 2>/dev/null || wget -O $(PYTHON_DOWNLOADED_MSI) "http://python.org/ftp/python/$(PYVERSION_WIN32_FULL)/python-$(PYVERSION_WIN32_FULL).msi"
	ls $(TEMP_DIR) 1>/dev/null 2>/dev/null || mkdir $(TEMP_DIR)
	ls $(WINPYTHON_DIR) 1>/dev/null 2>/dev/null || msiexec 2>/dev/null 1>/dev/null /a $(PYTHON_DOWNLOADED_MSI) /qb TARGETDIR=$(WINPYTHON_DIR)

$(EVENTLET_DIR): $(DOWNLOADS_DIR)
	@echo "Downloading eventlet package"
	ls $(EVENTLET_DOWNLOADED) || wget -O $(EVENTLET_DOWNLOADED) $(EVENTLET_URL)
	ls $(TEMP_DIR) 1>/dev/null 2</dev/null || mkdir $(TEMP_DIR)
	ls $(EVENTLET_DIR) 1>/dev/null 2>/dev/null || tar xvzf $(EVENTLET_DOWNLOADED) -C $(TEMP_DIR)

$(GREENLET_DOWNLOADED): $(DOWNLOADS_DIR)
	@echo "Downloading greenlet package"
	wget $(GREENLET_URL) -O $(GREENLET_DOWNLOADED)
	7z e $(GREENLET_DOWNLOADED) greenlet.pyd -r -o$(TEMP_DIR)

$(ZEROMQ_TEMP_DIR): $(DOWNLOADS_DIR)
	@echo "Downloading pyzmq"
	ls $(ZEROMQ_DOWNLOADED_MSI) 1>/dev/null 2>/dev/null || wget -O $(ZEROMQ_DOWNLOADED_MSI) $(ZEROMQ_URL)
	ls $(TEMP_DIR) 1>/dev/null 2>/dev/null || mkdir $(TEMP_DIR)
	ls $(ZEROMQ_TEMP_DIR) 1>/dev/null 2>/dev/null || msiexec 2>/dev/null 1>/dev/null /a $(ZEROMQ_DOWNLOADED_MSI) /qb TARGETDIR=$(ZEROMQ_TEMP_DIR)


prepare-win32:
	mkdir -p $(WIN32_RELEASE)
	mkdir -p $(WIN32_MODULES_DIR)

#	Project modules
	@for dir in $(PYTHON_DIRS_WIN32); do \
		mkdir -p $(WIN32_RELEASE)/$$dir; \
		find $$dir -maxdepth 1 -name "*.py" -not -path "*/test*" -exec cp {} $(WIN32_RELEASE)/$$dir \; ; \
	done

#	Python built-ins
	@for dir in $(BUILTINS_RAW); do \
		mkdir -p $(WIN32_RELEASE)/$$dir; \
		find $(BUILTINS_DIR)/$$dir -maxdepth 1 -name "*.py" -not -path "*/test*" -exec cp {} $(WIN32_RELEASE)/$$dir \; ; \
	done

	cp $(BUILTINS_PY) $(WIN32_RELEASE)
	cp -R $(BUILTINS_DLLS) $(WIN32_RELEASE)
	cp -R $(BUILTINS_PYD) $(WIN32_MODULES_DIR)

	cp -R $(COUCHDB_HG_CLONE)/couchdb $(WIN32_RELEASE)
	cp -R $(EVENTLET_DIR)/eventlet $(WIN32_RELEASE)

#	Python

	cp -f $(WINPYTHON_DIR)/*.exe $(WIN32_RELEASE)
	cp -f $(WINPYTHON_DIR)/*.dll $(WIN32_RELEASE)
	cp -f $(WINPYTHON_DIR)/*.manifest $(WIN32_RELEASE)

	cp -f $(TEMP_DIR)/greenlet.pyd $(WIN32_RELEASE)/libs
	rm -rf $(WIN32_RELEASE)/zmq


precompile-win32: prepare-win32
	@find $(WIN32_RELEASE) -name '*.py' | $(PYTHON_WIN32) -OO /usr/bin/py_compilefiles -


$(WIN32_MODULES_FILE): precompile-win32
	7z a -R -tzip -mx9 -mmt=on -mpass=15 -mm=Deflate $@ "./$(WIN32_RELEASE)/*.pyo" -x\!"./$(WIN32_MODULES_DIR)"


build-win32: $(WIN32_MODULES_FILE)
	cp -f $(WIN32_MODULES_FILE) $(WIN32_MODULES_DIR)
	$(PYTHON_WIN32) -OO /usr/bin/py_compilefiles capp1.py capp2.py capp3.py

# Remove the temporary files created during the Win32 build
postbuild-win32:
	rm -rf $(addprefix $(WIN32_RELEASE)/,$(PYTHON_DIRS_WIN32))
	rm -rf $(WIN32_RELEASE)/*.py

	find $(WIN32_RELEASE)/ -maxdepth 1 -name '*.pyo' | xargs rm -f
	find $(WIN32_RELEASE)/ -maxdepth 1 -name '*.pyc' | xargs rm -f
	rm -rf $(addprefix $(WIN32_RELEASE)/,$(BUILTINS_RAW))
	find $(WIN32_RELEASE) -name "*.py" | xargs rm -f

	rm -R $(WIN32_RELEASE)/couchdb
	rm -R $(WIN32_RELEASE)/eventlet

	cp capp1.pyo capp2.pyo capp3.pyo $(WIN32_RELEASE)
	rm -rf capp1.pyo capp2.pyo capp3.pyo

	rm -rf $(WIN32_RELEASE)/zmq
	cp -Rf $(ZEROMQ_TEMP_DIR)/Lib/site-packages/zmq $(WIN32_RELEASE)


# Build the win32 directory for future use
build-win32-dir: build-win32 postbuild-win32


# Having the Win32 files cross-compiled, create an installer using NSIS.
make-nsis-win32:
	makensis coreport.nsi

# Create the installer from scratch
binary-win32: build-win32-dir make-nsis-win32

build: binary-win32
