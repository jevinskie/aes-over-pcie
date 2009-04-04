SRCDIR = source
MAPPEDDIR = mapped
WORKDIR = work
SCRIPTDIR = scripts

ENTITIES =	add_round_key		\
				aes_rcu				\
				aes_top				\
				aes					\
				bus_test				\
				cntr					\
				enc					\
				key_scheduler		\
				lfsr					\
				mix_columns			\
				reduce_pack			\
				sbox					\
				shift_rows			\
				state_filter_in	\
				state_filter_out	\
				state

TEST_ENTITIES =	tb_add_round_key	\
						tb_bus_test			\
						tb_counters			\
						tb_mix_columns		\
						tb_sbox				\
						tb_shift_rows



clean_source:
	reg_dirs := $(foreach ent,$(ENTITIES),$(WORKDIR)/$(ent))
	test_dirs := $(foreach test,$(TEST_ENTITIES),$(WORKDIR)/$(test))
	rm -rf $(reg_dirs) $(test_dirs)

clean_mapped:
	@echo fill me in


