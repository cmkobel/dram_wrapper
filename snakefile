# snakemake --profile profiles/local
# snakemake --profile profiles/slurm-sigma2-saga

activate_arturos_dram_environment = """
# Use preinstalled environment. Ode to Arturo
set +eu # https://github.com/conda/conda/issues/8186#issuecomment-532874667
source /cluster/projects/nn9864k/cmkobel/miniconda3/etc/profile.d/conda.sh
conda activate ~/memo/shared/condaenvironments/DRAM/
set -eu
"""

batch = "batch_1"

genome_dir = "../../06_FNC/08_FNC_bloof_species_wise-Comparisons-2nd"
genomes = ["B13_272687.fasta", "B18_293302.fasta", "B19_876542.fasta", "B20_258348.fasta", "B20_501593.fasta", "B20_507854.fasta", "EB15_08105.fasta", "EB17_37350.fasta", "EB17_60835.fasta", "EB17_96439.fasta", "EB18_67636.fasta", "ESB_B21_214227.fasta", "ESB_B21_214965.fasta", "F_hwasookii_F128T.fasta", "F_nucleatum_ATCC25586T.fasta", "F_nuc_ssp_animalis_ATCC51191.fasta", "Fnuc_ssp_pmph_ATCC10953T.fasta", "Fnuc_ssp_vincentii_NCTC11326.fasta", "F_pariodonticum_ATCC33693.fasta", "Fsp_oral370_strF0437.fasta", "Fusobacterium_watanabei_PAGU_1796.fasta", "OUH_B11_313193.fasta", "OUH_B12_335041.fasta", "OUH_B14_301112.fasta", "OUH_B14_911830.fasta", "OUH_B17_978058.fasta", "OUH_B18_909122.fasta", "OUH_B19_805646.fasta", "OUH_B19_829639.fasta", "OUH_B20_834232.fasta", "OUH_B20_845268.fasta", "OUH_B20_894008.fasta", "OUH_B21_804847.fasta", "OUH_B21_946994.fasta", "Sj_06_2019.fasta", "Sj_08_2019.fasta", "Sj_17_2017.fasta", "Sj_19_2016.fasta", "Sj_20_2016.fasta", "SLB_Vejle_B16_B160574.fasta", "SLB_Vejle_B19_B479977.fasta", "SLB_Vejle_B20_B586122.fasta"]

rule all:
	input:
		expand(["output/{batch}/annotation/done.flag", "output/{batch}/distill/done.flag"], batch = batch)


rule dram_annotate:
	input: expand("{genome_dir}/{genomes}", genome_dir = genome_dir, genomes = genomes)
	output: 
		flag = touch("output/{batch}/annotation/done.flag"),
		dir = directory("output/{batch}/annotation")
	benchmark: "output/{batch}/benchmarks/benchmark.dram_annotate.tsv"
	resources:
		mem_mb = 128000
	#conda: "conda_definitions/mashtree.yaml"
	shell: """

		# DRAM is confused about existing dirs, which snakemake creates.
		rm -r {output.dir} || echo "output never existed in the first place"

		{activate_arturos_dram_environment}

		DRAM.py --help > ~/help.dram.txt


		# Alternatively
		#source activate ~/memo/shared/condaenvironments/DRAM/

		DRAM.py annotate -i '{genome_dir}/*' -o {output.dir}


	"""


rule distill:
	input:
		flag = touch("output/{batch}/annotation/done.flag"),
	output:
		flag = touch("output/{batch}/distill/done.flag"),
	params:
		annotation_dir = f"output/{batch}/annotation"
	benchmark: "output/{batch}/benchmarks/benchmark.distill.tsv"
	shell: """

		{activate_arturos_dram_environment}

		DRAM.py distill \
			-i {params.annotation_dir}/annotations.tsv \
			--trna_path {params.annotation_dir}/trnas.tsv \
			--rrna_path {params.annotation_dir}/rrnas.tsv \
			-o distill 

	"""
