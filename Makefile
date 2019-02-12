src_dir := $(dir $(lastword $(MAKEFILE_LIST)))
RUN_DIR := ${PWD}
TOP     := top
GRID_SIZE := 3

MD := mkdir
CD := cd
RD := rm -rf

default: compile

analyze:
	vlogan \
	+define+NOT_USE_UNIQUE \
	-assert svaext \
	-simprofile time \
	-simprofile mem \
	-full64 \
	-lca \
	-sverilog \
	-notice \
	+lint=all,noVCDE \
	-timescale=1ns/1ps \
	-nc \
	-debug_all \
	$(src_dir)\*.sv

elaborate:
	vcs \
	-assert svaext \
	-simprofile time \
	-simprofile mem \
	-full64 \
	-lca \
	-sverilog \
	-notice \
	-CFLAGS -DVCS \
	+lint=all,noVCDE \
	-timescale=1ns/1ps \
	-nc \
	-debug_all \
	${TOP}

compile: analyze elaborate

run:
	./simv +GRID_SIZE=${GRID_SIZE}

run_all:
	for i in {3..6}; \
		do \
			./simv +GRID_SIZE=$$i -l GRID_SIZE_M$$i.log -simprofile_report GRID_SIZE_PROFILE_$$i; \
		done

run_all_ver:
	array=( L-2016.06-SP1-1 M-2017.03-SP2-10 ); \
	for i in "$${array[@]}"; \
		do \
		  $(RD) $$i ; \
			$(MD) $$i ; \
			$(CD) $$i ; \
			export VCS_HOME=/opt/vcs-mx/$$i; \
			make -f $(src_dir)/Makefile compile ; \
			make -f $(src_dir)/Makefile run_all ; \
			$(CD) .. ; \
		done

clear:
	rm -rf GRID_SIZE_PROFILE_* simprofile* *.txt *.log

.PHONY: analyze elaborate compile run run_all clear run_all_ver
