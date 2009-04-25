SRCDIR = source
MAPPEDDIR = mapped
WORKDIR = work
SCRIPTDIR = scripts
TESTVECTDIR = test_vectors
UTILSDIR = utils

CFLAGS = -quiet

ENTITIES =	add_round_key		\
				aes_rcu				\
				aes_top				\
				aes					\
				bridge				\
            fifo              \
				key_scheduler		\
				mix_columns			\
				reduce_pack			\
				pcie					\
				pcie_top				\
				sbox					\
				shift_rows			\
				state_filter_in	\
				state_filter_out	\
				state					\
				top_top

TEST_ENTITIES =	aes_textio           \
                  numeric_std_textio   \
                  tb_add_round_key	   \
                  tb_aes_top				\
                  tb_fifo              \
						tb_key_scheduler	   \
						tb_mix_columns		   \
						tb_sbox				   \
						tb_shift_rows			\
						tb_top_top

TEST_VECTORS =    tb_key_scheduler tb_mix_columns tb_shift_rows tb_aes_top 

ENTITY_DIRS = $(foreach ent,$(ENTITIES),$(WORKDIR)/$(ent))
TEST_ENTITY_DIRS = $(foreach test,$(TEST_ENTITIES),$(WORKDIR)/$(test))
ENTITY_SRCS = $(foreach ent,$(ENTITIES),$(SRCDIR)/$(ent).vhd)
TEST_ENTITY_SRCS = $(foreach test,$(TEST_ENTITES),$(SRCDIR)/$(test).vhd)
TEST_VECTOR_DATS = $(foreach vect,$(TEST_VECTORS),$(TESTVECTDIR)/$(vect).dat)

.PHONEY : clean_source clean_mapped all_source $(ENTITIES) $(TEST_ENTITIES)

clean_source:
	rm -rf work
	
clean_mapped:
	@echo fill me in

clean_test_vectors:
	rm -f $(TEST_VECTOR_DATS)

add_round_key: aes
aes_rcu: aes
aes_top: aes add_round_key aes_rcu key_scheduler	\
	mix_columns sbox shift_rows state_filter_in		\
	state_filter_out state
bridge: pcie aes
fifo: aes
key_scheduler: aes
mix_columns: aes
sbox: aes reduce_pack
shift_rows: aes
state_filter_in: aes
state_filter_out: aes
state: aes
pcie: aes

tb_add_round_key: aes
tb_fifo: aes
tb_mix_columns: aes
tb_sbox: aes
tb_shift_rows: aes
tb_aes_rcu: aes
tb_aes_top: aes
tb_key_scheduler: aes aes_textio
tb_top_top: aes pcie
aes_textio: aes numeric_std_textio

work:
	vlib $(WORKDIR)

$(TEST_VECTOR_DATS): $(TESTVECTDIR)/%.dat : $(TESTVECTDIR)/%.py
	PYTHONPATH=$(UTILSDIR) $< > $@

$(ENTITIES) : % : $(WORKDIR)/%
$(TEST_ENTITIES) : % : $(WORKDIR)/%

$(WORKDIR)/%: work
	vcom $(CFLAGS) -work $(WORKDIR) $(SRCDIR)/$(notdir $@).vhd

all_source: $(ENTITIES)

all_tests: $(TEST_ENTITIES)

all_test_vectors: $(TEST_VECTOR_DATS)

