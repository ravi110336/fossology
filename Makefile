# FOSSology Makefile
# Copyright (C) 2008 Hewlett-Packard Development Company, L.P.

# pull in all our default variables
include Makefile.conf

# the directories we do things in by default
DIRS=devel scheduler agents ui cli

# create lists of targets for various operations
# these are phony targets (declared at bottom) of convenience so we can
# run 'make $(operation)-$(subdir)'. Yet another convenience, a target of
# '$(subdir)' is equivalent to 'build-$(subdir)'
BUILDDIRS = $(DIRS:%=build-%)
INSTALLDIRS = $(DIRS:%=install-%)
UNINSTALLDIRS = $(DIRS:%=uninstall-%)
CLEANDIRS = $(DIRS:%=clean-%)
TESTDIRS = $(DIRS:%=test-%)

## Targets
# build
all: $(BUILDDIRS) fo-postinstall
$(DIRS): $(BUILDDIRS)
$(BUILDDIRS):
	$(MAKE) -C $(@:build-%=%)

# include the preprocessing stuff
include Makefile.process
# generate the postinstall script
fo-postinstall: fo-postinstall-process
	chmod +x fo-postinstall

# high level dependencies:
# the scheduler and agents need the devel stuff built first
build-scheduler: build-devel
build-agents: build-devel

# cli needs the php include file built in ui
build-cli: build-ui

# utils is a separate target, since it isn't built by default yet
utils: build-utils

# install depends on everything being built first
install: all $(INSTALLDIRS)
$(INSTALLDIRS):
	$(MAKE) -C $(@:install-%=%) install

uninstall: $(UNINSTALLDIRS)
$(UNINSTALLDIRS):
	$(MAKE) -C $(@:uninstall-%=%) uninstall

# test depends on everything being built first
test: all $(TESTDIRS)
$(TESTDIRS):
	$(MAKE) -C $(@:test-%=%) test

clean: $(CLEANDIRS)
	rm -f variable.list fo-postinstall

$(CLEANDIRS):
	$(MAKE) -C $(@:clean-%=%) clean

# release stuff
tar: dist-testing
dist-testing:
	# Package into a tar file.
	chmod a+x ./mktar.sh
	./mktar.sh -s

tar-release: dist
dist:
	# Package into a tar file.
	chmod a+x ./mktar.sh
	./mktar.sh


.PHONY: $(BUILDDIRS) $(DIRS) $(INSTALLDIRS) $(UNINSTALLDIRS)
.PHONY: $(TESTDIRS) $(CLEANDIRS)
.PHONY: all install uninstall clean test utils
.PHONY: dist dist-testing tar tar-release
