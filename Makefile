#**********************************************************************
#
# This file is part of a fork of NIST Biometric Image Software. 
# Modifications to the upstream source code are distributed under the
# following terms: 
#
#    Copyright 2013 Michael Chaberski
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# The original source code is a work in the public domain. The original 
# license and disclaimers are below.
#
# BEGIN ORIGINAL LICENSE TEXT
#*******************************************************************************
#
# License: 
# This software and/or related materials was developed at the National Institute
# of Standards and Technology (NIST) by employees of the Federal Government
# in the course of their official duties. Pursuant to title 17 Section 105
# of the United States Code, this software is not subject to copyright
# protection and is in the public domain. 
#
# This software and/or related materials have been determined to be not subject
# to the EAR (see Part 734.3 of the EAR for exact details) because it is
# a publicly available technology and software, and is freely distributed
# to any interested party with no licensing requirements.  Therefore, it is 
# permissible to distribute this software as a free download from the internet.
#
# Disclaimer: 
# This software and/or related materials was developed to promote biometric
# standards and biometric technology testing for the Federal Government
# in accordance with the USA PATRIOT Act and the Enhanced Border Security
# and Visa Entry Reform Act. Specific hardware and software products identified
# in this software were used in order to perform the software development.
# In no case does such identification imply recommendation or endorsement
# by the National Institute of Standards and Technology, nor does it imply that
# the products and equipment identified are necessarily the best available
# for the purpose.
#
# This software and/or related materials are provided "AS-IS" without warranty
# of any kind including NO WARRANTY OF PERFORMANCE, MERCHANTABILITY,
# NO WARRANTY OF NON-INFRINGEMENT OF ANY 3RD PARTY INTELLECTUAL PROPERTY
# or FITNESS FOR A PARTICULAR PURPOSE or for any purpose whatsoever, for the
# licensed product, however used. In no event shall NIST be liable for any
# damages and/or costs, including but not limited to incidental or consequential
# damages of any kind, including economic damage or injury to property and lost
# profits, regardless of whether NIST shall be advised, have reason to know,
# or in fact shall know of the possibility.
#
# By using this software, you agree to bear all risk relating to quality,
# use and performance of the software and/or related materials.  You agree
# to hold the Government harmless from any claim arising from your use
# of the software.
#
#*******************************************************************************
# Project:		NIST Fingerprint Software
# SubTree:		/NBIS/Main
# Filename:		Makefile
# Integrators:		Kenneth Ko
# Organization:		NIST/ITL
# Host System:		GNU GCC/GMAKE GENERIC (UNIX)
# Date Created:		08/20/2006
# Date Updated:		03/05/2007
#                       11/28/2007
#                       10/16/2008 Joseph C. Konczal
#			05/04/2011 Kenneth Ko
#			05/06/2011 Kenneth Ko
#			09/13/2011 Kenneth Ko
#
# ******************************************************************************
#
# Top-level make file to build all of the NBIS source code
# (libraries and binaries).
#
# ******************************************************************************
#
# config -- check to see if "nfis" have been installed by verifying
#           that all DIR_INSTALL directories are present.
#
# it -- Create a "obj" directory and compile/generate all the .o, .a
#       and executables under the "obj" directory.
#
# install -- Create "bin" and "lib" directories and install all the
#            .a and and executables from "obj" directory.
#
# clean -- cleanup all .o, .a and executables.
#
# catalog -- Create catalog file for all the libaraies and 
#            applications.
#
# help -- print help manual.
#
# ******************************************************************************

include ./rules.mak
#
# ******************************************************************************
# 
# Target:   all:
# Target to make all libraries and executables.
# 
# ******************************************************************************
all: config it

#
# ******************************************************************************
#
# Target: config:
# Target to verify all required project directories are present.
#
# ******************************************************************************
config:
	@echo "TOP = "$(TOP)
	@echo "DIR_ROOT = "$(DIR_ROOT)
	@echo "Start: Checking \"$(PROJ_NAME)\" directory structure...."
	@for dir in $(PACKAGES); do \
		echo "Verifying directory - \"$(DIR_ROOT)/$$dir\":"; \
		if [ ! -d $$dir ]; then \
			echo "[FAILED]"; \
			echo "Please check out the missing directory: \"$(DIR_ROOT)/$$dir\"!"; \
			date; \
			exit 2;\
		else \
			echo "[PASSED]"; \
		fi; \
	done
	@for dir in $(EXTRA_DIR) $(DOC_DIRS); do \
		echo "Verifying directory - \"$$dir\":"; \
		if [ ! -d $$dir ]; then \
			echo "[FAILED]"; \
			echo "Please check out the missing directory \"$$dir\"!"; \
			date; \
			exit 2;\
		else \
			echo "[PASSED]"; \
		fi; \
	done
	@echo "End: Checking \"$(PROJ_NAME)\" directory structure."
	@echo "Start: Checking exports and calatogs directories structure...."
	@for dir in $(EXPORTS_DIRS) $(DOC_CATS_DIR); do \
		status=0; \
		if [ ! -d $$dir ]; then \
			echo "Creating \"$$dir\" directory...."; \
			status=1; \
			$(MKDIR) $$dir; \
			echo "[PASSED]"; \
		fi; \
		if [ -d $$dir ]; then \
			if [ $$status = 0 ]; then \
				echo "Directory \"$$dir\" already exist:"; \
				echo "[PASSED]"; \
			fi; \
		else \
			echo "[-FAILED]"; \
			exit 2; \
		fi; \
	done
	@echo "End: Checking exports and calatogs directories structure"
	@for package in $(PACKAGES); do \
		(cd $(DIR_ROOT)/$$package && $(MAKE) config) || exit 1; \
	done
#
# ******************************************************************************
#
# Target: it:
# Target to make all the .o, .a and executables in obj directory.
#
# ******************************************************************************
it:
	@for package in $(PACKAGES); do \
		(cd $(DIR_ROOT)/$$package && $(MAKE) cpheaders) || exit 1; \
	done 
	@for package in $(PACKAGES); do \
		(cd $(DIR_ROOT)/$$package && $(MAKE) libs) || exit 1; \
	done
	@for package in $(PACKAGES); do \
		(cd $(DIR_ROOT)/$$package && $(MAKE) bins) || exit 1; \
	done

install-libnbis:
	@echo "Start: Creating libnbis.a..."; 
	$(MKDIR_P) -v $(INSTALL_ROOT_LIB_DIR)
	$(RM) $(INSTALL_ROOT_LIB_DIR)/libnbis.a
	@for package in $(PACKAGES); do \
		$(AR) -r $(INSTALL_ROOT_LIB_DIR)/libnbis.a $$package/lib/*.a ; \
	done
	@echo "End: Creating libnbis.a."; \

#
# ******************************************************************************
#
# Target: install
# Target to install the the .a in the lib and executables in the bin
# directory.
#
# ******************************************************************************

install: install-runtimedata install-bins install-man

install-headers:
	@echo "Start: Copying header files for each package to \"$(INSTALL_ROOT_INC_DIR)\"...."
	$(MKDIR_P) -v $(INSTALL_ROOT_INC_DIR)
	@for package in $(PACKAGES); do \
		if [ $$package = "ijg" ]; then \
#			echo "$(CP) -Rpf $(DIR_ROOT)/$$package/src/lib/jpegb/*.h $(INSTALL_ROOT_INC_DIR)"; \
			($(CP) -vRpf $(DIR_ROOT)/$$package/src/lib/jpegb/*.h $(INSTALL_ROOT_INC_DIR)) || exit 1; \
		else \
#			echo "$(CP) -Rpf $(DIR_ROOT)/$$package/include/* $(INSTALL_ROOT_INC_DIR)"; \
			($(CP) -vRpf $(DIR_ROOT)/$$package/include/* $(INSTALL_ROOT_INC_DIR)) || exit 1; \
		fi; \
	done
	$(RM) $(INSTALL_ROOT_INC_DIR)/little.h.src 
	@echo "End: Copying header files for each package to \"$(INSTALL_ROOT_INC_DIR)\"."

install-bins:
	@echo "Start: Installing binaries to target directory: "$(INSTALL_ROOT_BIN_DIR)
	$(MKDIR_P) -v $(INSTALL_ROOT_BIN_DIR)
	@for package in $(PACKAGES); do \
		if [ $$package != "ijg" -a $$package != "commonnbis" ]; then \
			echo "installing " $$package/bin/* ; \
			$(INSTALL_CMD) -t $(INSTALL_ROOT_BIN_DIR) $$package/bin/* || exit 1 ; \
		fi ; \
	done
#	@for ijgbinary in cjpeg djpeg jpegtran wrjpgcom rdjpgcom ; do \
#		$(INSTALL_CMD) -t $(INSTALL_ROOT_BIN_DIR) ijg/src/lib/jpegb/$$ijgbinary ; \
#	done
	@echo "End: Installing binaries"

install-man:
	@echo "Start: Installing man pages to \"$(INSTALL_ROOT_MAN_DIR)\"...."
	$(MKDIR_P) $(INSTALL_ROOT_MAN_DIR)
	@for manpage in $(MANPAGES) ; do \
		$(INSTALL_CMD) -m0644 -t $(INSTALL_ROOT_MAN_DIR) \
				$(MAN_SRC_DIR)/$$manpage || exit 1 ; \
	done
	@echo "End: Installing man pages to \"$(INSTALL_ROOT_MAN_DIR)\"."

install-runtimedata:
	@echo "Start: Copying runtime data directories to \"$(INSTALL_RUNTIME_DATA_DIR)\"...."
	$(MKDIR_P) -v $(INSTALL_RUNTIME_DATA_DIR)
	@for datadir in $(RUNTIME_DATA_PACKAGES); do \
		echo "$(CP) -Rf $(DIR_ROOT)/$$datadir/$(RUNTIME_DATA_DIR) $(INSTALL_RUNTIME_DATA_DIR)/$$datadir"; \
		($(CP) -Rf \
			$(DIR_ROOT)/$$datadir/$(RUNTIME_DATA_DIR) \
			$(INSTALL_RUNTIME_DATA_DIR)/$$datadir) || exit 1; \
	done
	find "$(INSTALL_RUNTIME_DATA_DIR)" -type f -print0 | xargs -0 chmod 0644
	@echo "End: Copying runtime data directories to \"$(INSTALL_RUNTIME_DATA_DIR)\"."

#
# ******************************************************************************
#
# Target: clean
# Target to cleanup all .o,  .a and executables.
#
# ******************************************************************************
clean:
	$(RM) $(DOC_CATS_DIR)/*txt
	@for package in $(PACKAGES); do \
#		echo "Start: Cleaning up $$package...."; \
		(cd $(DIR_ROOT)/$$package && $(MAKE) clean) || exit 1; \
		echo "Cleaned $$package."; \
	done
	@find * -type f -name "*.d" -delete
	$(RM) -r exports doc/catalogs
	@for package in an2k bozorth3 commonnbis imgtools mindtct nfiq nfseg pcasys ; do \
		$(RM) -r $$package/bin $$package/lib $$package/obj ; \
	done
#	$(RM) -r ijg/dummy

#
# ******************************************************************************
# 
# Target: catalog
# Target to create catalog file for all the libaraies and 
# applications.
#
# ******************************************************************************
catalog:
	@echo "Start: Generating \"$(PROJ_NAME)\" catalogs...."
	$(RM) $(DOC_CATS_DIR)/*txt
	$(TOUCH) $(DOC_CATS_DIR)/catalog_apps.txt
	@for package in $(PACKAGES); do \
		(cd $(DIR_ROOT)/$$package && $(MAKE) catalog) || exit 1; \
	done
	@echo "End: Generating \"$(PROJ_NAME)\" catalogs."
#
# ******************************************************************************
#
# Target: help
# Target to print help manual.
#
# ******************************************************************************
help:
	@echo "For individuals wanting to build the NBIS Open Source Software,"
	@echo "the simple instructions are:"
	@echo "1.  \`make config\`"
	@echo "2.  \`make it\`"
	@echo "3.  \`make install\`"
	@echo "4.  \`make catalog\`"
#
