pep8:
	autopep8 -i *.py

stat:
	ansible -i ~/svs.txt all -m shell -a 'gpustat'

all:
	$(MAKE) copy_py
	$(MAKE) fetch_db
	$(MAKE) plot_week_local

all_month:
	$(MAKE) copy_py
	$(MAKE) fetch_db
	$(MAKE) plot_month_local

stat_%:
	ansible -i ~/svs.txt all -m shell -a '~/anaconda3/bin/python3 gpuwatch.py stat -s $(shell echo $@ | sed -e "s/stat_//")'

plot_week:
	ansible -i ~/svs.txt all -m shell -a "~/anaconda3/bin/python3 gpuwatch.py stat -s week --plot --plot_title '{{inventory_hostname}}'"

plot_week_local:
	for DB in $$(ls *_gpuwatch.db); do \
		IP="$$(echo $${DB} | sed -e 's/_gpuwatch.db$$//g')"; \
		SVG="$${IP}_gpuwatch.svg"; \
		echo $${IP} $${SVG}; \
		python3 gpuwatch.py stat -s week --plot --plot_title "$${IP}" -B"$${DB}"; \
		mv gpuwatch.svg $${SVG}; \
		done
	python3 gpuwatch.py svgreduce
	-evince svgreduce.pdf

plot_month_local:
	for DB in $$(ls *_gpuwatch.db); do \
		IP="$$(echo $${DB} | sed -e 's/_gpuwatch.db$$//g')"; \
		SVG="$${IP}_gpuwatch.svg"; \
		echo $${IP} $${SVG}; \
		python3 gpuwatch.py stat -s month --plot --plot_title "$${IP}" -B"$${DB}"; \
		mv gpuwatch.svg $${SVG}; \
		done
	python3 gpuwatch.py svgreduce
	-evince svgreduce.pdf

fetch_svg:
	ansible -i ~/svs.txt all -m fetch -a "src=~/gpuwatch.svg dest={{inventory_hostname}}_gpuwatch.svg flat=yes"
	python3 gpuwatch.py svgreduce 2>/dev/null
	@echo
	@echo Check svgreduce.pdf for the gathered plots.

fetch_db:
	ansible -i ~/svs.txt all -m fetch -a "src=~/__gpuwatch__.db dest={{inventory_hostname}}_gpuwatch.db flat=yes"

copy_py:
	ansible -i ~/svs.txt all -m copy -a "src=gpuwatch.py dest=~/gpuwatch.py"
