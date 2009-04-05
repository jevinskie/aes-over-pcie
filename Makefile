SRCDIR = source
MAPPEDDIR = mapped
WORKDIR = work
SCRIPTDIR = scripts

CFLAGS = -quiet

ENTITIES =	add_round_key		\
				aes_rcu				\
				aes_top				\
				aes					\
				key_scheduler		\
				mix_columns			\
				reduce_pack			\
				sbox					\
				shift_rows			\
				state_filter_in	\
				state_filter_out	\
				state					\
				top_top

TEST_ENTITIES =	tb_add_round_key	\
						tb_aes_rcu			\
						tb_key_scheduler	\
						tb_mix_columns		\
						tb_sbox				\
						tb_shift_rows


ENTITY_DIRS = $(foreach ent,$(ENTITIES),$(WORKDIR)/$(ent))
TEST_ENTITY_DIRS = $(foreach test,$(TEST_ENTITIES),$(WORKDIR)/$(test))
ENTITY_SRCS = $(foreach ent,$(ENTITIES),$(SRCDIR)/$(ent).vhd)
TEST_ENTITY_SRCS = $(foreach test,$(TEST_ENTITES),$(SRCDIR)/$(test).vhd)

.PHONEY : clean_source clean_mapped all_source $(ENTITIES) $(TEST_ENTITIES)

clean_source:
	rm -rf work
	
clean_mapped:
	@echo fill me in

add_round_key: aes
aes_rcu: aes
aes_top: aes add_round_key aes_rcu key_scheduler	\
	mix_columns sbox shift_rows state_filter_in		\
	state_filter_out state
key_scheduler: aes
mix_columns: aes
sbox: aes reduce_pack
shift_rows: aes
state_filter_in: aes
state_filter_out: aes
state: aes

tb_add_round_key: aes
tb_mix_columns: aes
tb_sbox: aes
tb_shift_rows: aes
tb_aes_rcu: aes

work:
	vlib $(WORKDIR)

$(ENTITIES) : % : $(WORKDIR)/%
$(TEST_ENTITIES) : % : $(WORKDIR)/%

$(WORKDIR)/%: work
	vcom $(CFLAGS) -work $(WORKDIR) $(SRCDIR)/$(notdir $@).vhd

all_source: $(ENTITIES)

all_test: $(TEST_ENTITIES)

