Snapshot GDC psqlgraph into Neo4j
=================================

## How it works

* Neo4j is stopped.
* Each node and edge table is dumped by a simple `SELECT` statement.
(Table names are de-mangled by [edge-tbls.pl](./helpers/edge-tbls.pl).
* Each table is converted to CSV with [tbl-cvt.pl](./helpers/tbl-cvt.pl).
** Each node csv represents one node table. The rels csv contains all  relationships.
** CSVs are in the format required by the script `neo4j-import` that ships with
Neo4j.
* The `neo4j-import`script is run on the csv files, which creates a neo4j backend
database.
* Neo4j is pointed at this database using `update-alternatives` (basically, by
symbolic links)
* Neo4j is started
* A number of indexes are created

## How to do it

Run
    $ sudo neoupdater

All files and data are created in directories in /tmp by default.

Works pretty fast
=================

```
ubuntu@majvm:~/Code/neoupdater/neoupdater$ time neoupdater

do nodes
aggregated_somatic_mutation
aligned_reads
aligned_reads_index
aligned_reads_metric
alignment_cocleaning_workflow
alignment_workflow
aliquot
analysis_metadata
analyte
annotated_somatic_mutation
annotation
archive
biospecimen_supplement
case
center
clinical
clinical_supplement
copy_number_liftover_workflow
copy_number_segment
data_format
data_subtype
data_type
demographic
diagnosis
exon_expression
experimental_strategy
experiment_metadata
exposure
family_history
file
filtered_copy_number_segment
filtered_somatic_mutation
gene_expression
germline_mutation_calling_workflow
mirna_expression
mirna_expression_workflow
pathology_report
platform
portion
program
project
publication
read_group
read_group_qc
rna_expression_workflow
run_metadata
sample
simple_germline_variation
simple_somatic_mutation
slide
slide_image
somatic_annotation_workflow
somatic_masking_workflow
somatic_mutation_calling_workflow
submitted_aligned_reads
submitted_tangent_copy_number
submitted_unaligned_reads
tag
tissue_source_site
treatment
do edges
convert ids
batch import
Usage: Importer data/dir nodes.csv relationships.csv [node_index node-index-name fulltext|exact nodes_index.csv rel_index rel-index-name fulltext|exact rels_index.csv ....]
Using: Importer batch.properties /mnt/tmp/tmp.9EkFGKRugN/data /mnt/tmp/tmp.9EkFGKRugN/csv/nodes000.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes001.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes002.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes004.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes005.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes006.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes007.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes008.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes009.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes010.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes011.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes012.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes013.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes014.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes015.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes016.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes017.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes018.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes019.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes020.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes021.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes022.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes023.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes025.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes026.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes027.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes029.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes032.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes034.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes035.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes037.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes038.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes039.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes040.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes041.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes042.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes043.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes044.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes045.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes046.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes048.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes049.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes051.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes053.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes054.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes055.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes056.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes057.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes058.csv,/mnt/tmp/tmp.9EkFGKRugN/csv/nodes059.csv /mnt/tmp/tmp.9EkFGKRugN/csv/rels.csv

Using Existing Configuration File

Importing 144 Nodes took 0 seconds 

Importing 46107 Nodes took 2 seconds 

Importing 46107 Nodes took 0 seconds 

Importing 10827 Nodes took 0 seconds 

Importing 23249 Nodes took 0 seconds 
.
Importing 156889 Nodes took 0 seconds 

Importing 50202 Nodes took 0 seconds 

Importing 63262 Nodes took 0 seconds 

Importing 45577 Nodes took 0 seconds 

Importing 27264 Nodes took 0 seconds 

Importing 6549 Nodes took 0 seconds 

Importing 11368 Nodes took 0 seconds 

Importing 15288 Nodes took 0 seconds 

Importing 37 Nodes took 0 seconds 

Importing 9550 Nodes took 0 seconds 

Importing 11173 Nodes took 0 seconds 

Importing 16567 Nodes took 0 seconds 

Importing 33134 Nodes took 0 seconds 

Importing 34 Nodes took 0 seconds 

Importing 53 Nodes took 0 seconds 

Importing 10 Nodes took 0 seconds 

Importing 13017 Nodes took 0 seconds 

Importing 13012 Nodes took 0 seconds 

Importing 21 Nodes took 0 seconds 

Importing 50202 Nodes took 0 seconds 

Importing 11164 Nodes took 0 seconds 
..........
Importing 1027006 Nodes took 40 seconds 

Importing 34725 Nodes took 2 seconds 

Importing 23202 Nodes took 1 seconds 

Importing 11601 Nodes took 0 seconds 

Importing 33 Nodes took 0 seconds 

Importing 32574 Nodes took 0 seconds 

Importing 4 Nodes took 0 seconds 

Importing 49 Nodes took 0 seconds 

Importing 9 Nodes took 0 seconds 
....
Importing 403527 Nodes took 25 seconds 
.......
Importing 788310 Nodes took 48 seconds 

Importing 34725 Nodes took 2 seconds 

Importing 50202 Nodes took 2 seconds 

Importing 29754 Nodes took 0 seconds 

Importing 45577 Nodes took 3 seconds 

Importing 18839 Nodes took 0 seconds 

Importing 45577 Nodes took 2 seconds 

Importing 45577 Nodes took 4 seconds 

Importing 34498 Nodes took 1 seconds 

Importing 16567 Nodes took 1 seconds 

Importing 11657 Nodes took 0 seconds 

Importing 76 Nodes took 0 seconds 

Importing 1052 Nodes took 0 seconds 

Importing 11191 Nodes took 0 seconds 
.................................................................................................... 13352 ms for 10000000
......
Importing 10640232 Relationships took 14 seconds 

Total import time: 173 seconds 
*** create /usr/local/share/data/graph.db_201606052147/graph.db
batch_importer helpers install.sh neostart neoupdater neoupdater-cron p2n.sh p2n.sh~ copy neo4j data
*** update alternative graph.db location to /usr/local/share/data/graph.db_201606052147
update-alternatives: warning: alternative /usr/local/share/data/graph.db_201605192201 (part of link group neo4j_graph_db) doesn't exist; removing from list of alternatives
update-alternatives: warning: alternative /usr/local/share/data/graph.db_201606022230 (part of link group neo4j_graph_db) doesn't exist; removing from list of alternatives
update-alternatives: warning: alternative /usr/local/share/data/graph.db_201606052126 (part of link group neo4j_graph_db) doesn't exist; removing from list of alternatives
update-alternatives: warning: /etc/alternatives/neo4j_graph_db is dangling; it will be updated with best choice
update-alternatives: using /usr/local/share/data/graph.db_201605261913 to provide /usr/local/share/neo4j/data (neo4j_graph_db) in auto mode
update-alternatives: using /usr/local/share/data/graph.db_201606052147 to provide /usr/local/share/neo4j/data (neo4j_graph_db) in manual mode
*** start neo4j server
Starting Neo4j Server.../usr/local/share/neo4j/data/log was missing, recreating...
process [25004]... waiting for server to be ready.......................................................................................... OK.
http://localhost:7474/ is ready.
Welcome to the Neo4j Shell! Enter 'help' for a list of commands
NOTE: Remote Neo4j graph database service 'shell' at port 1337

neo4j-sh (?)$ merge (n:View { source:"/usr/local/share/data/graph.db_201606052147" });
+-------------------+
| No data returned. |
+-------------------+
Nodes created: 1
Properties set: 1
Labels added: 1
353 ms
neo4j-sh (?)$ workdir:/mnt/tmp/tmp.9EkFGKRugN
graphdb:/usr/local/share/data/graph.db_201606052147/graph.db

real	7m12.459s
user	2m44.295s
sys	0m26.370s
```
